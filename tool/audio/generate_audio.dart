// Generates every bundled sound effect and music loop from code: no
// recordings, no licences, no credits needed. Stand-ins until real audio
// exists (docs/audio.md).
//
// Usage (needs ffmpeg on PATH for the Ogg Vorbis encode):
//   fvm dart run tool/audio/generate_audio.dart [id ...]
//
// With no ids, writes all of them to assets/audio/{sfx,music,ui}/<id>.ogg.
// Everything is seeded, so a rerun gives the same files.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const rate = 44100;
const tau = 2 * math.pi;

int n(double seconds) => (seconds * rate).round();

// ---------------------------------------------------------------------------
// Buffers

/// A stereo buffer of samples in -1..1.
final class Buf {
  Buf(double seconds) : this.samples(n(seconds));

  Buf.samples(int length) : l = Float64List(length), r = Float64List(length);

  final Float64List l;
  final Float64List r;

  int get length => l.length;

  /// Mixes mono [x] in at [at] seconds; [pan] -1 (left) to 1 (right).
  void add(Float64List x, {double at = 0, double gain = 1, double pan = 0}) {
    final start = n(at);
    final angle = (pan + 1) * math.pi / 4;
    final gl = gain * math.cos(angle) * math.sqrt2;
    final gr = gain * math.sin(angle) * math.sqrt2;
    for (var i = 0; i < x.length; i++) {
      final j = start + i;
      if (j < 0 || j >= length) continue;
      l[j] += x[i] * gl;
      r[j] += x[i] * gr;
    }
  }

  void mix(Buf other, {double at = 0, double gain = 1}) {
    final start = n(at);
    for (var i = 0; i < other.length; i++) {
      final j = start + i;
      if (j < 0 || j >= length) continue;
      l[j] += other.l[i] * gain;
      r[j] += other.r[i] * gain;
    }
  }

  /// Scales so the loudest sample sits at [db] dBFS.
  void normalize(double db) {
    var peak = 1e-9;
    for (var i = 0; i < length; i++) {
      peak = math.max(peak, math.max(l[i].abs(), r[i].abs()));
    }
    final g = math.pow(10, db / 20) / peak;
    for (var i = 0; i < length; i++) {
      l[i] *= g;
      r[i] *= g;
    }
  }

  /// Short fades at both ends, so nothing clicks.
  void edges({double fadeIn = 0.002, double fadeOut = 0.05}) {
    final a = n(fadeIn);
    final b = n(fadeOut);
    for (var i = 0; i < a && i < length; i++) {
      l[i] *= i / a;
      r[i] *= i / a;
    }
    for (var i = 0; i < b && i < length; i++) {
      final k = length - 1 - i;
      l[k] *= i / b;
      r[k] *= i / b;
    }
  }
}

// ---------------------------------------------------------------------------
// Sources and filters (mono)

Float64List noise(double seconds, math.Random rng) => Float64List.fromList([
  for (var i = 0; i < n(seconds); i++) rng.nextDouble() * 2 - 1,
]);

/// Brown-ish noise: integrated white noise, for rumble and room tone.
Float64List brown(double seconds, math.Random rng) {
  final x = Float64List(n(seconds));
  var v = 0.0;
  for (var i = 0; i < x.length; i++) {
    v = (v + (rng.nextDouble() * 2 - 1) * 0.02) * 0.998;
    x[i] = v * 8;
  }
  return x;
}

/// A sine whose frequency may change over time ([freq] takes seconds).
Float64List tone(
  double seconds,
  double Function(double t) freq, {
  double phase = 0,
}) {
  final x = Float64List(n(seconds));
  var p = phase;
  for (var i = 0; i < x.length; i++) {
    x[i] = math.sin(p);
    p += tau * freq(i / rate) / rate;
  }
  return x;
}

/// Struck object: partials (ratio to [base], amplitude, decay time).
Float64List modal(
  double seconds,
  double base,
  List<(double, double, double)> partials, {
  double attack = 0.001,
}) {
  final x = Float64List(n(seconds));
  for (final (ratio, amp, decay) in partials) {
    final f = base * ratio;
    if (f >= rate / 2) continue;
    for (var i = 0; i < x.length; i++) {
      final t = i / rate;
      final env = math.exp(-t / decay) * math.min(1, t / attack);
      x[i] += amp * env * math.sin(tau * f * t);
    }
  }
  return x;
}

/// Multiplies [x] by an envelope over time.
Float64List shape(Float64List x, double Function(double t) env) {
  for (var i = 0; i < x.length; i++) {
    x[i] *= env(i / rate);
  }
  return x;
}

double decay(double t, double time) => math.exp(-t / time);

/// Rises over [attack], holds, falls over [release] before [total].
double swell(double t, double attack, double release, double total) {
  if (t < attack) return t / attack;
  if (t > total - release) return math.max(0, (total - t) / release);
  return 1;
}

Float64List lowpass(Float64List x, double Function(double t) cutoff) {
  final y = Float64List(x.length);
  var v = 0.0;
  for (var i = 0; i < x.length; i++) {
    final a = 1 - math.exp(-tau * cutoff(i / rate) / rate);
    v += a * (x[i] - v);
    y[i] = v;
  }
  return y;
}

Float64List highpass(Float64List x, double cutoff) {
  final low = lowpass(x, (_) => cutoff);
  return Float64List.fromList([
    for (var i = 0; i < x.length; i++) x[i] - low[i],
  ]);
}

/// Resonant band-pass (RBJ biquad), centre may move over time.
Float64List bandpass(
  Float64List x,
  double Function(double t) centre,
  double q,
) {
  final y = Float64List(x.length);
  var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0;
  for (var i = 0; i < x.length; i++) {
    final w = tau * math.min(centre(i / rate), rate * 0.45) / rate;
    final alpha = math.sin(w) / (2 * q);
    final a0 = 1 + alpha;
    final b0 = alpha / a0;
    final b2 = -alpha / a0;
    final a1 = -2 * math.cos(w) / a0;
    final a2 = (1 - alpha) / a0;
    final out = b0 * x[i] + b2 * x2 - a1 * y1 - a2 * y2;
    x2 = x1;
    x1 = x[i];
    y2 = y1;
    y1 = out;
    y[i] = out;
  }
  return y;
}

Float64List sum(List<Float64List> parts) {
  final length = parts.map((p) => p.length).reduce(math.max);
  final y = Float64List(length);
  for (final p in parts) {
    for (var i = 0; i < p.length; i++) {
      y[i] += p[i];
    }
  }
  return y;
}

Float64List gain(Float64List x, double g) {
  for (var i = 0; i < x.length; i++) {
    x[i] *= g;
  }
  return x;
}

/// A dry click: a few milliseconds of filtered noise.
Float64List click(
  math.Random rng, {
  double centre = 3000,
  double time = 0.002,
}) => shape(
  bandpass(noise(time * 6, rng), (_) => centre, 1.2),
  (t) => decay(t, time),
);

// ---------------------------------------------------------------------------
// Space

/// Schroeder reverb (four combs, two all-passes per side); [size] 0..1
/// stretches the room, [mix] is the wet share.
Buf reverb(Buf dry, {double size = 0.5, double mix = 0.25, double damp = 0.4}) {
  final out = Buf.samples(dry.length);
  const combsL = [1116, 1188, 1277, 1356];
  const combsR = [1139, 1211, 1300, 1379];
  const passes = [556, 441];
  final feedback = 0.7 + 0.28 * size;
  Float64List side(Float64List x, List<int> combs, int spread) {
    final wet = Float64List(x.length);
    for (final d0 in combs) {
      final d = (d0 * (0.6 + size)).round();
      final line = Float64List(d);
      var idx = 0;
      var filt = 0.0;
      for (var i = 0; i < x.length; i++) {
        final o = line[idx];
        filt = o * (1 - damp) + filt * damp;
        line[idx] = x[i] + filt * feedback;
        idx = (idx + 1) % d;
        wet[i] += o / combs.length;
      }
    }
    var y = wet;
    for (final d0 in passes) {
      final d = d0 + spread;
      final line = Float64List(d);
      var idx = 0;
      final z = Float64List(y.length);
      for (var i = 0; i < y.length; i++) {
        final b = line[idx];
        z[i] = -y[i] + b;
        line[idx] = y[i] + b * 0.5;
        idx = (idx + 1) % d;
      }
      y = z;
    }
    return y;
  }

  final wl = side(dry.l, combsL, 0);
  final wr = side(dry.r, combsR, 23);
  for (var i = 0; i < dry.length; i++) {
    out.l[i] = dry.l[i] * (1 - mix) + wl[i] * mix * 2;
    out.r[i] = dry.r[i] * (1 - mix) + wr[i] * mix * 2;
  }
  return out;
}

/// Makes [total] seconds of [render] loop seamlessly: renders a little
/// longer and crossfades the overhang into the start.
Buf loop(
  double total,
  Buf Function(double seconds) render, {
  double overlap = 3,
}) {
  final long = render(total + overlap);
  final out = Buf(total);
  final x = n(overlap);
  for (var i = 0; i < out.length; i++) {
    if (i < x) {
      final f = i / x;
      out.l[i] = long.l[i] * f + long.l[out.length + i] * (1 - f);
      out.r[i] = long.r[i] * f + long.r[out.length + i] * (1 - f);
    } else {
      out.l[i] = long.l[i];
      out.r[i] = long.r[i];
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// Building blocks shared by several sounds

/// Pendulum clock: tick, or the lower tock.
Float64List tick(math.Random rng, {bool tock = false}) {
  final pitch = tock ? 1650.0 : 2350.0;
  return sum([
    gain(click(rng, centre: pitch * 1.6, time: 0.0015), 0.6),
    modal(0.08, pitch, const [
      (1, 1, 0.012),
      (2.71, 0.45, 0.007),
      (4.1, 0.2, 0.004),
    ]),
    gain(modal(0.1, 420, const [(1, 1, 0.02)]), 0.25),
  ]);
}

/// A church bell (hum, prime, minor third, fifth, nominal and above).
Float64List bell(double base, double seconds, {double length = 1}) =>
    modal(seconds, base, [
      (0.5, 0.45, 3.2 * length),
      (0.501, 0.2, 3.0 * length),
      (1, 0.9, 2.6 * length),
      (1.19, 0.55, 2.1 * length),
      (1.5, 0.35, 1.7 * length),
      (2, 0.6, 1.4 * length),
      (2.51, 0.28, 0.9 * length),
      (2.66, 0.22, 0.8 * length),
      (3.01, 0.18, 0.7 * length),
      (4.1, 0.12, 0.45 * length),
    ], attack: 0.002);

Float64List glassNote(double f, double seconds) => modal(seconds, f, const [
  (1, 1, 1.4),
  (2.76, 0.3, 0.6),
  (5.4, 0.12, 0.3),
  (1.003, 0.4, 1.2),
]);

/// Telegraph sounder: armature down (clack) and up (click).
Float64List sounderDown(math.Random rng) => sum([
  modal(0.06, 1500, const [
    (1, 1, 0.012),
    (2.4, 0.6, 0.008),
    (4.1, 0.3, 0.005),
  ]),
  gain(click(rng, centre: 2500, time: 0.002), 0.7),
]);

Float64List sounderUp(math.Random rng) => gain(
  sum([
    modal(0.04, 2300, const [(1, 1, 0.008), (2.2, 0.4, 0.005)]),
    click(rng, centre: 4000, time: 0.0012),
  ]),
  0.55,
);

/// Morse for letters, as dot (1) and dash (3) lengths.
const morse = {
  'N': [3, 1],
  'I': [1, 1],
  'S': [1, 1, 1],
};

void tapOut(
  Buf b,
  String word,
  math.Random rng, {
  double at = 0,
  double unit = 0.085,
  double gainDb = 0,
}) {
  final g = math.pow(10, gainDb / 20).toDouble();
  var t = at;
  for (final letter in word.split('')) {
    for (final len in morse[letter]!) {
      b
        ..add(sounderDown(rng), at: t, gain: g)
        ..add(sounderUp(rng), at: t + len * unit, gain: g);
      t += (len + 1) * unit;
    }
    t += 2 * unit;
  }
}

Float64List footstep(math.Random rng) => sum([
  shape(tone(0.2, (_) => 70), (t) => decay(t, 0.04)),
  gain(
    shape(lowpass(noise(0.15, rng), (_) => 500), (t) => decay(t, 0.025)),
    1.5,
  ),
]);

// ---------------------------------------------------------------------------
// Sound effects

Buf clockTick() {
  final rng = math.Random(1);
  final b = Buf(1.1)
    ..add(tick(rng), at: 0.02, pan: -0.1)
    ..add(tick(rng, tock: true), at: 0.52, pan: 0.1);
  return reverb(b, size: 0.2, mix: 0.15);
}

Buf matchStrike() {
  final rng = math.Random(2);
  final b = Buf(1.4);
  final scratch = shape(
    bandpass(noise(0.3, rng), (t) => 1400 + t * 14000, 1.4),
    (t) => swell(t, 0.01, 0.12, 0.3),
  );
  b.add(gain(scratch, 1.4));
  for (var i = 0; i < 14; i++) {
    b.add(
      click(rng, centre: 2000 + rng.nextDouble() * 3000),
      at: rng.nextDouble() * 0.28,
      gain: 0.5 + rng.nextDouble(),
    );
  }
  final flare = shape(
    lowpass(noise(1.2, rng), (t) => 500 + 900 * decay(t, 0.3)),
    (t) => swell(t, 0.12, 0.8, 1.2),
  );
  b.add(gain(flare, 2.2), at: 0.18);
  return reverb(b, size: 0.2, mix: 0.12);
}

Buf doorRattle() {
  final rng = math.Random(3);
  final b = Buf(1.4);
  for (final (at, g) in [
    (0.0, 1.0),
    (0.12, 0.8),
    (0.23, 0.9),
    (0.48, 0.7),
    (0.61, 1.0),
    (0.7, 0.6),
  ]) {
    final thud = sum([
      shape(tone(0.3, (_) => 88), (t) => decay(t, 0.06)),
      gain(
        shape(lowpass(noise(0.2, rng), (_) => 350), (t) => decay(t, 0.03)),
        2,
      ),
    ]);
    final latch = modal(0.2, 1180 + rng.nextDouble() * 80, const [
      (1, 1, 0.04),
      (2.3, 0.6, 0.03),
      (3.9, 0.3, 0.02),
    ]);
    b
      ..add(thud, at: at, gain: g)
      ..add(latch, at: at + 0.004, gain: g * 0.35, pan: 0.2);
  }
  return reverb(b, size: 0.35, mix: 0.2);
}

Buf doorCreak() {
  final rng = math.Random(4);
  const seconds = 2.2;
  final pulses = Float64List(n(seconds));
  var phase = 0.0;
  for (var i = 0; i < pulses.length; i++) {
    final t = i / rate;
    final f =
        38 +
        55 * math.pow(math.sin(math.pi * t / seconds), 2) +
        12 * math.sin(t * 7) +
        rng.nextDouble() * 6;
    phase += f / rate;
    if (phase >= 1) {
      phase -= 1;
      pulses[i] = 1;
    }
  }
  final body = sum([
    bandpass(pulses, (_) => 540, 14),
    gain(bandpass(pulses, (_) => 1010, 14), 0.8),
    gain(bandpass(pulses, (t) => 1750 + 200 * math.sin(t * 2), 12), 0.6),
    gain(bandpass(pulses, (_) => 2900, 10), 0.35),
  ]);
  final b = Buf(seconds + 0.6)
    ..add(shape(body, (t) => swell(t, 0.25, 0.5, seconds)), gain: 3);
  return reverb(b, size: 0.45, mix: 0.25);
}

Buf bellToll() {
  final rng = math.Random(5);
  final b = Buf(7)
    ..add(bell(196, 7), gain: 0.8)
    ..add(
      gain(
        shape(lowpass(noise(0.05, rng), (_) => 2000), (t) => decay(t, 0.008)),
        0.6,
      ),
    );
  return reverb(b, size: 0.85, mix: 0.35, damp: 0.5);
}

Buf drawerOpen() {
  final rng = math.Random(6);
  final b = Buf(1.3);
  final judder = Float64List(n(0.7));
  for (var i = 0; i < judder.length; i++) {
    final t = i / rate;
    judder[i] =
        (0.4 + 0.6 * math.sin(t * tau * 23).abs()) *
        (0.7 + 0.3 * rng.nextDouble());
  }
  final slide = shape(
    lowpass(noise(0.7, rng), (_) => 900),
    (t) => swell(t, 0.05, 0.2, 0.7) * judder[math.min(n(t), judder.length - 1)],
  );
  b
    ..add(gain(slide, 2.5))
    ..add(footstep(rng), at: 0.72, gain: 0.8);
  for (var i = 0; i < 4; i++) {
    b.add(
      modal(0.1, 2000 + rng.nextDouble() * 900, const [
        (1, 1, 0.02),
        (2.5, 0.4, 0.01),
      ]),
      at: 0.75 + i * 0.035 + rng.nextDouble() * 0.02,
      gain: 0.25,
    );
  }
  return reverb(b, size: 0.25, mix: 0.15);
}

Buf paper() {
  final rng = math.Random(7);
  final b = Buf(0.8);
  b.add(
    gain(
      shape(highpass(noise(0.6, rng), 2500), (t) => swell(t, 0.08, 0.3, 0.6)),
      0.25,
    ),
  );
  for (var i = 0; i < 60; i++) {
    final t = math.pow(rng.nextDouble(), 1.4) * 0.6;
    b.add(
      click(
        rng,
        centre: 2500 + rng.nextDouble() * 5000,
        time: 0.0008 + rng.nextDouble() * 0.002,
      ),
      at: t.toDouble(),
      gain: 0.2 + rng.nextDouble() * 0.6,
      pan: rng.nextDouble() * 0.6 - 0.3,
    );
  }
  return reverb(b, size: 0.15, mix: 0.1);
}

Buf pageTurn() {
  final rng = math.Random(8);
  final b = Buf(0.9);
  final whoosh = shape(
    bandpass(
      noise(0.6, rng),
      (t) => t < 0.3 ? 700 + t * 6000 : 2500 - (t - 0.3) * 4000,
      0.8,
    ),
    (t) => math.pow(math.sin(math.pi * math.min(t / 0.6, 1)), 2).toDouble(),
  );
  b
    ..add(gain(whoosh, 1.4), pan: -0.2)
    ..add(
      gain(
        shape(lowpass(noise(0.08, rng), (_) => 1200), (t) => decay(t, 0.012)),
        1.2,
      ),
      at: 0.52,
      pan: 0.2,
    );
  for (var i = 0; i < 12; i++) {
    b.add(
      click(rng, centre: 3000 + rng.nextDouble() * 3000, time: 0.001),
      at: 0.05 + rng.nextDouble() * 0.5,
      gain: 0.25,
    );
  }
  return reverb(b, size: 0.15, mix: 0.1);
}

Float64List plip(double pitch) => sum([
  shape(
    tone(0.12, (t) => pitch * (0.55 + 0.45 * (1 - math.exp(-t / 0.012)))),
    (t) => decay(t, 0.03),
  ),
]);

Buf waterDrip() {
  final b = Buf(3)
    ..add(plip(1500), at: 0.05, pan: -0.2)
    ..add(plip(1250), at: 1.25, gain: 0.6, pan: 0.3)
    ..add(plip(1700), at: 2.05, gain: 0.35, pan: 0.1);
  return reverb(b, size: 0.95, mix: 0.5, damp: 0.3);
}

Buf lanternLight() {
  final rng = math.Random(9);
  final b = Buf(1.8)
    ..add(
      modal(0.3, 3100, const [
        (1, 1, 0.05),
        (1.6, 0.5, 0.04),
        (2.9, 0.2, 0.02),
      ]),
      gain: 0.3,
      pan: 0.2,
    );
  final whoosh = shape(
    lowpass(noise(1.5, rng), (t) => 300 + 500 * decay(t, 0.4)),
    (t) => swell(t, 0.25, 1.0, 1.5) * (0.8 + 0.2 * math.sin(t * tau * 8)),
  );
  b.add(gain(whoosh, 2.4), at: 0.15);
  for (var i = 0; i < 10; i++) {
    b.add(
      click(rng, centre: 1500 + rng.nextDouble() * 2500),
      at: 0.15 + rng.nextDouble() * 0.6,
      gain: 0.3 + rng.nextDouble() * 0.4,
    );
  }
  return reverb(b, size: 0.6, mix: 0.25);
}

Buf distantBells() {
  final rng = math.Random(10);
  final b = Buf(8);
  const notes = [349.2, 311.1, 261.6, 233.1, 392.0, 349.2, 311.1, 261.6];
  for (final (i, f) in notes.indexed) {
    b.add(
      bell(f, 4, length: 0.7),
      at: i * 0.62 + rng.nextDouble() * 0.05,
      gain: 0.35,
      pan: -0.3 + i * 0.08,
    );
  }
  b.add(
    gain(
      shape(lowpass(brown(8, rng), (_) => 90), (t) => swell(t, 2.5, 3, 8)),
      0.5,
    ),
  );
  final far = Buf.samples(b.length);
  far.l.setAll(0, lowpass(b.l, (_) => 1400));
  far.r.setAll(0, lowpass(b.r, (_) => 1400));
  return reverb(far, size: 0.95, mix: 0.45, damp: 0.6);
}

Buf lockerClose() {
  final rng = math.Random(11);
  final b = Buf(1.4)
    ..add(
      gain(shape(highpass(noise(0.1, rng), 200), (t) => decay(t, 0.015)), 0.8),
    )
    ..add(
      modal(1.3, 160, const [
        (1, 1, 0.35),
        (2.56, 0.7, 0.25),
        (4.3, 0.45, 0.18),
        (6.9, 0.3, 0.12),
        (9.8, 0.2, 0.08),
      ]),
      gain: 0.7,
    )
    ..add(
      modal(0.2, 2600, const [(1, 1, 0.02), (2.3, 0.5, 0.012)]),
      at: 0.11,
      gain: 0.35,
      pan: 0.3,
    );
  return reverb(b, size: 0.4, mix: 0.2);
}

Buf glassChime() {
  final b = Buf(5);
  const notes = [1318.5, 1568.0, 1975.5, 2637.0, 1975.5, 3136.0];
  for (final (i, f) in notes.indexed) {
    b.add(
      glassNote(f, 3.5),
      at: i * 0.17,
      gain: 0.5 - i * 0.04,
      pan: -0.5 + i * 0.2,
    );
  }
  return reverb(b, size: 0.8, mix: 0.4);
}

Buf telegraphClick() {
  final rng = math.Random(12);
  final b = Buf(2.2);
  tapOut(b, 'NIS', rng, at: 0.05);
  return reverb(b, size: 0.25, mix: 0.15);
}

Buf stationBell() {
  final rng = math.Random(13);
  final b = Buf(3);
  for (final at in [0.0, 0.26, 0.52, 0.78]) {
    b
      ..add(
        modal(2.2, 880, const [
          (1, 1, 0.9),
          (2.0, 0.45, 0.6),
          (2.7, 0.4, 0.4),
          (4.2, 0.2, 0.25),
        ]),
        at: at,
        gain: 0.5,
      )
      ..add(click(rng, centre: 5000, time: 0.001), at: at, gain: 0.3);
  }
  return reverb(b, size: 0.5, mix: 0.25);
}

// ---------------------------------------------------------------------------
// Music loops

/// A soft chord that breathes: each note (frequency, amplitude, swell
/// period) swells on its own. Frequencies are nudged to whole cycles per
/// [loopSeconds], so the loop's crossfade never cancels a note.
Float64List drone(
  double seconds,
  List<(double, double, double)> notes, {
  required double loopSeconds,
}) {
  double whole(double f) => (f * loopSeconds).roundToDouble() / loopSeconds;
  return sum([
    for (final (f, amp, period) in notes)
      shape(
        sum([
          tone(seconds, (_) => whole(f)),
          gain(tone(seconds, (_) => whole(f * 1.003)), 0.6),
          gain(tone(seconds, (_) => whole(f * 2)), 0.15),
        ]),
        (t) => amp * (0.55 + 0.45 * math.sin(tau * t / period)),
      ),
  ]);
}

Buf menuMusic() => loop(36, (seconds) {
  final rng = math.Random(20);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 36, const [
        (55, 0.5, 18),
        (82.41, 0.3, 12),
        (110.2, 0.18, 9),
      ]),
      gain: 0.5,
    )
    ..add(gain(lowpass(brown(seconds, rng), (_) => 220), 0.35));
  for (var s = 0; s < seconds; s++) {
    b.add(tick(rng, tock: s.isOdd), at: s + 0.3, gain: 0.12, pan: 0.6);
  }
  for (final (at, f) in [(6.0, 2637.0), (24.0, 2349.3)]) {
    b.add(glassNote(f, 3), at: at, gain: 0.05, pan: -0.6);
  }
  return reverb(b, size: 0.7, mix: 0.3);
});

Buf whitechapelFog() => loop(48, (seconds) {
  final rng = math.Random(21);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (73.42, 0.5, 24),
        (110, 0.3, 16),
        (174.6, 0.12, 12),
      ]),
      gain: 0.45,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 450 + 300 * math.sin(tau * t / 12),
      0.7,
    ),
    (t) => 0.5 + 0.5 * math.sin(tau * t / 16 + 1),
  );
  b
    ..add(gain(wind, 0.35), pan: -0.3)
    ..add(lowpass(bell(130.8, 7), (_) => 700), at: 20, gain: 0.25, pan: 0.5);
  for (var i = 0; i < 6; i++) {
    b.add(
      lowpass(footstep(rng), (_) => 400),
      at: 33 + i * 0.62,
      gain: 0.35 * (1 - i * 0.05),
      pan: -0.6,
    );
  }
  return reverb(b, size: 0.9, mix: 0.4, damp: 0.55);
});

Float64List chirp(double pitch) {
  final x = Float64List(n(0.12));
  for (var k = 0; k < 3; k++) {
    final pulse = shape(
      tone(0.018, (_) => pitch),
      (t) => math.sin(math.pi * t / 0.018),
    );
    x.setAll(n(k * 0.034), [
      for (var i = 0; i < pulse.length && n(k * 0.034) + i < x.length; i++)
        pulse[i],
    ]);
  }
  return x;
}

Buf lawangSewuNight() => loop(48, (seconds) {
  final rng = math.Random(22);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (65.41, 0.5, 24),
        (98, 0.28, 16),
        (155.6, 0.12, 12),
      ]),
      gain: 0.45,
    )
    ..add(gain(lowpass(brown(seconds, rng), (_) => 150), 0.3));
  for (final (pitch, every, pan) in [(4600.0, 0.9, -0.5), (5150.0, 1.3, 0.6)]) {
    for (
      var t = rng.nextDouble();
      t < seconds;
      t += every + rng.nextDouble() * 0.2
    ) {
      b.add(chirp(pitch), at: t, gain: 0.05, pan: pan);
    }
  }
  // A train whistle, far off.
  final whistle = shape(
    sum([
      for (final f in [440.0, 554.4, 659.3])
        gain(tone(3, (t) => f * (1 + 0.004 * math.sin(t * 5))), 0.33),
    ]),
    (t) => swell(t, 0.6, 1.4, 3),
  );
  b.add(lowpass(whistle, (_) => 900), at: 28, gain: 0.12, pan: 0.4);
  return reverb(b, size: 0.95, mix: 0.45, damp: 0.5);
});

Buf lawangSewu1907() => loop(32, (seconds) {
  final rng = math.Random(23);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 32, const [
        (87.31, 0.45, 16),
        (130.8, 0.3, 32 / 3),
        (174.6, 0.18, 8),
        (220, 0.12, 32 / 5),
      ]),
      gain: 0.45,
    );
  for (var s = 0; s < seconds; s++) {
    b.add(tick(rng, tock: s.isOdd), at: s + 0.5, gain: 0.1, pan: -0.5);
  }
  for (var i = 0; i < 220; i++) {
    b.add(
      lowpass(click(rng, centre: 3000, time: 0.0006), (_) => 3500),
      at: rng.nextDouble() * seconds,
      gain: 0.04 + rng.nextDouble() * 0.05,
      pan: rng.nextDouble() - 0.5,
    );
  }
  final far = Buf(3);
  tapOut(far, 'NIS', rng);
  b
    ..mix(far, at: 9, gain: 0.12)
    ..mix(far, at: 23, gain: 0.08);
  return reverb(b, size: 0.4, mix: 0.25);
});

// ---------------------------------------------------------------------------

final sfx = <String, Buf Function()>{
  'clock_tick': clockTick,
  'match_strike': matchStrike,
  'door_rattle': doorRattle,
  'door_creak': doorCreak,
  'bell_toll': bellToll,
  'drawer_open': drawerOpen,
  'paper': paper,
  'page_turn': pageTurn,
  'water_drip': waterDrip,
  'lantern_light': lanternLight,
  'distant_bells': distantBells,
  'locker_close': lockerClose,
  'glass_chime': glassChime,
  'telegraph_click': telegraphClick,
  'station_bell': stationBell,
};

final music = <String, Buf Function()>{
  'stillroom_menu': menuMusic,
  'whitechapel_fog': whitechapelFog,
  'lawang_sewu_night': lawangSewuNight,
  'lawang_sewu_1907': lawangSewu1907,
};

// ---------------------------------------------------------------------------
// Interface sounds (assets/audio/ui): short, soft, played for every touch.

Buf tapSound() {
  final rng = math.Random(30);
  final b = Buf(0.25)
    ..add(modal(0.2, 620, const [(1, 1, 0.02), (2.3, 0.4, 0.012)]), gain: 0.6)
    ..add(click(rng, centre: 1800, time: 0.0015), gain: 0.5);
  return reverb(b, size: 0.15, mix: 0.12);
}

Buf dialSound() {
  final rng = math.Random(31);
  final b = Buf(0.25);
  for (final (at, f) in [(0.0, 3200.0), (0.035, 2700.0)]) {
    b
      ..add(
        modal(0.1, f, const [(1, 1, 0.01), (1.9, 0.5, 0.006)]),
        at: at,
        gain: 0.6,
      )
      ..add(click(rng, centre: f, time: 0.001), at: at, gain: 0.4);
  }
  return reverb(b, size: 0.1, mix: 0.1);
}

Buf pressSound() {
  final rng = math.Random(32);
  final b = Buf(0.3)
    ..add(
      shape(tone(0.15, (t) => 180 - 60 * t), (t) => decay(t, 0.03)),
      gain: 0.8,
    )
    ..add(click(rng, centre: 2400, time: 0.0012), gain: 0.35);
  return reverb(b, size: 0.2, mix: 0.15);
}

Buf mistakeSound() {
  final rng = math.Random(33);
  final b = Buf(0.6)
    ..add(
      shape(tone(0.5, (t) => 92 - 20 * t), (t) => decay(t, 0.12)),
      gain: 0.9,
    )
    ..add(shape(tone(0.5, (t) => 97 - 22 * t), (t) => decay(t, 0.1)), gain: 0.5)
    ..add(
      gain(
        shape(lowpass(noise(0.2, rng), (_) => 500), (t) => decay(t, 0.03)),
        1.2,
      ),
    );
  return reverb(b, size: 0.35, mix: 0.2);
}

Buf liftSound() {
  final rng = math.Random(34);
  final b = Buf(0.3)
    ..add(
      gain(
        shape(
          bandpass(noise(0.2, rng), (t) => 1500 + 6000 * t, 1),
          (t) => swell(t, 0.02, 0.12, 0.2),
        ),
        0.8,
      ),
    );
  return reverb(b, size: 0.1, mix: 0.1);
}

Buf placeSound() {
  final rng = math.Random(35);
  final b = Buf(0.4)
    ..add(
      gain(
        shape(
          bandpass(noise(0.12, rng), (t) => 3000 - 12000 * t, 1),
          (t) => swell(t, 0.01, 0.06, 0.12),
        ),
        0.6,
      ),
    )
    ..add(
      shape(tone(0.2, (_) => 140), (t) => decay(t, 0.035)),
      at: 0.1,
      gain: 0.7,
    )
    ..add(click(rng, centre: 1500, time: 0.002), at: 0.1, gain: 0.4);
  return reverb(b, size: 0.2, mix: 0.12);
}

Buf turnSound() {
  final rng = math.Random(36);
  final b = Buf(0.4)
    ..add(
      gain(
        shape(
          bandpass(noise(0.22, rng), (_) => 900, 3),
          (t) => swell(t, 0.03, 0.1, 0.22),
        ),
        1.2,
      ),
    )
    ..add(
      modal(0.15, 1400, const [(1, 1, 0.015), (2.6, 0.5, 0.01)]),
      at: 0.2,
      gain: 0.5,
    );
  return reverb(b, size: 0.25, mix: 0.15);
}

Buf solvedSound() {
  final rng = math.Random(37);
  final b = Buf(1.6)
    ..add(modal(0.2, 1900, const [(1, 1, 0.02), (2.2, 0.5, 0.012)]), gain: 0.5)
    ..add(click(rng, centre: 2500, time: 0.002), gain: 0.4)
    ..add(glassNote(1046.5, 1.4), at: 0.08, gain: 0.25)
    ..add(glassNote(1568, 1.2), at: 0.16, gain: 0.18);
  return reverb(b, size: 0.5, mix: 0.3);
}

Buf pickupSound() {
  final rng = math.Random(38);
  final b = Buf(0.9)
    ..add(
      gain(
        shape(
          bandpass(noise(0.3, rng), (t) => 800 + 3000 * t, 0.9),
          (t) => swell(t, 0.05, 0.2, 0.3),
        ),
        0.7,
      ),
    )
    ..add(glassNote(1318.5, 0.8), at: 0.12, gain: 0.18);
  return reverb(b, size: 0.3, mix: 0.2);
}

Buf combineSound() {
  final rng = math.Random(39);
  final b = Buf(1.2)
    ..add(modal(0.3, 1100, const [(1, 1, 0.05), (2.4, 0.5, 0.03)]), gain: 0.5)
    ..add(
      modal(0.3, 1500, const [(1, 1, 0.04), (2.1, 0.4, 0.025)]),
      at: 0.07,
      gain: 0.5,
    )
    ..add(click(rng, centre: 3000, time: 0.0015), at: 0.07, gain: 0.3)
    ..add(glassNote(1760, 0.9), at: 0.15, gain: 0.15)
    ..add(glassNote(2217.5, 0.8), at: 0.22, gain: 0.12);
  return reverb(b, size: 0.4, mix: 0.25);
}

Buf rejectSound() {
  final rng = math.Random(40);
  final b = Buf(0.35)
    ..add(shape(tone(0.25, (_) => 110), (t) => decay(t, 0.05)), gain: 0.7)
    ..add(
      gain(
        shape(lowpass(noise(0.1, rng), (_) => 700), (t) => decay(t, 0.02)),
        0.9,
      ),
    );
  return reverb(b, size: 0.2, mix: 0.12);
}

Float64List air(math.Random rng, double seconds, {required bool rising}) =>
    shape(
      bandpass(
        noise(seconds, rng),
        (t) => rising ? 400 + 2500 * t / seconds : 2900 - 2500 * t / seconds,
        0.7,
      ),
      (t) => math.pow(math.sin(math.pi * t / seconds), 2).toDouble(),
    );

Buf openSound() {
  final rng = math.Random(41);
  final b = Buf(0.6)..add(gain(air(rng, 0.4, rising: true), 0.8));
  return reverb(b, size: 0.3, mix: 0.2);
}

Buf closeSound() {
  final rng = math.Random(42);
  final b = Buf(0.6)
    ..add(gain(air(rng, 0.35, rising: false), 0.8))
    ..add(
      shape(tone(0.15, (_) => 130), (t) => decay(t, 0.03)),
      at: 0.3,
      gain: 0.4,
    );
  return reverb(b, size: 0.3, mix: 0.2);
}

Buf pageSound() {
  final rng = math.Random(43);
  final b = Buf(0.4)
    ..add(
      gain(
        shape(
          bandpass(noise(0.25, rng), (t) => 1200 + 5000 * t, 0.8),
          (t) => math.pow(math.sin(math.pi * t / 0.25), 2).toDouble(),
        ),
        0.6,
      ),
    );
  for (var i = 0; i < 5; i++) {
    b.add(
      click(rng, centre: 4000, time: 0.001),
      at: 0.03 + rng.nextDouble() * 0.2,
      gain: 0.2,
    );
  }
  return reverb(b, size: 0.1, mix: 0.08);
}

Buf stepSound() {
  final rng = math.Random(44);
  final b = Buf(0.6)
    ..add(lowpass(footstep(rng), (_) => 900), gain: 0.6)
    ..add(
      modal(0.3, 240, const [(1, 1, 0.05), (1.7, 0.4, 0.04)]),
      at: 0.02,
      gain: 0.08,
    );
  return reverb(b, size: 0.45, mix: 0.25);
}

Buf jarOpenSound() {
  final rng = math.Random(45);
  final pop = shape(tone(0.08, (t) => 900 - 5000 * t), (t) => decay(t, 0.012));
  final b = Buf(2.2)
    ..add(
      gain(
        shape(
          bandpass(noise(0.15, rng), (_) => 1800, 2),
          (t) => swell(t, 0.1, 0.02, 0.15),
        ),
        0.4,
      ),
    )
    ..add(pop, at: 0.15, gain: 0.9)
    ..add(glassNote(1174.7, 1.8), at: 0.17, gain: 0.3)
    ..add(glassNote(1760, 1.5), at: 0.19, gain: 0.15)
    ..add(gain(air(rng, 1.2, rising: false), 0.25), at: 0.25);
  return reverb(b, size: 0.6, mix: 0.3);
}

final ui = <String, Buf Function()>{
  'tap': tapSound,
  'dial': dialSound,
  'press': pressSound,
  'mistake': mistakeSound,
  'lift': liftSound,
  'place': placeSound,
  'turn': turnSound,
  'solved': solvedSound,
  'pickup': pickupSound,
  'combine': combineSound,
  'reject': rejectSound,
  'open': openSound,
  'close': closeSound,
  'page': pageSound,
  'step': stepSound,
  'jar_open': jarOpenSound,
};

Future<void> main(List<String> args) async {
  final temp = await Directory.systemTemp.createTemp('stillroom_audio');
  try {
    for (final (folder, table, peak) in [
      ('sfx', sfx, -3.0),
      ('music', music, -6.0),
      ('ui', ui, -9.0),
    ]) {
      for (final MapEntry(key: id, value: render) in table.entries) {
        if (args.isNotEmpty && !args.contains(id)) continue;
        final b = render()
          ..normalize(peak)
          ..edges(
            fadeOut: switch (folder) {
              'sfx' => 0.05,
              'ui' => 0.03,
              _ => 0.0,
            },
          );
        final wav = File('${temp.path}/$id.wav');
        await wav.writeAsBytes(encodeWav(b));
        final out = 'assets/audio/$folder/$id.ogg';
        final result = await Process.run('ffmpeg', [
          '-y',
          '-hide_banner',
          '-loglevel',
          'error',
          '-i',
          wav.path,
          '-c:a',
          'vorbis',
          '-strict',
          '-2',
          '-q:a',
          folder == 'music' ? '3' : '4',
          out,
        ]);
        if (result.exitCode != 0) {
          stderr.writeln('ffmpeg failed for $id: ${result.stderr}');
          exitCode = 1;
          return;
        }
        stdout.writeln('$out  ${(b.length / rate).toStringAsFixed(1)} s');
      }
    }
  } finally {
    await temp.delete(recursive: true);
  }
}

Uint8List encodeWav(Buf b) {
  final data = ByteData(44 + b.length * 4);
  void text(int at, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  text(0, 'RIFF');
  data.setUint32(4, 36 + b.length * 4, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  data
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little)
    ..setUint16(22, 2, Endian.little)
    ..setUint32(24, rate, Endian.little)
    ..setUint32(28, rate * 4, Endian.little)
    ..setUint16(32, 4, Endian.little)
    ..setUint16(34, 16, Endian.little);
  text(36, 'data');
  data.setUint32(40, b.length * 4, Endian.little);
  int s16(double v) => (v.clamp(-1.0, 1.0) * 32767).round();
  for (var i = 0; i < b.length; i++) {
    data
      ..setInt16(44 + i * 4, s16(b.l[i]), Endian.little)
      ..setInt16(46 + i * 4, s16(b.r[i]), Endian.little);
  }
  return data.buffer.asUint8List();
}
