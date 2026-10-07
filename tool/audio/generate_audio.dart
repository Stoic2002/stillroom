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

/// A ship's steam horn, far off in fog: two long, low blasts.
Buf shipHorn() {
  final b = Buf(6);
  for (final at in [0.1, 2.6]) {
    final horn = shape(
      sum([
        for (final (f, g) in [
          (110.0, 1.0),
          (220.0, 0.5),
          (330.0, 0.3),
          (138.6, 0.6),
        ])
          gain(tone(2.0, (t) => f * (1 + 0.003 * math.sin(t * 6))), g),
      ]),
      (t) => swell(t, 0.25, 0.5, 2.0),
    );
    b.add(lowpass(horn, (_) => 700), at: at, gain: 0.5, pan: -0.3);
  }
  return reverb(b, size: 0.95, mix: 0.45, damp: 0.6);
}

/// A heavy wave breaking against rock.
Buf waveCrash() {
  final rng = math.Random(14);
  final b = Buf(4.5);
  final crash = shape(
    lowpass(noise(4, rng), (t) => 300 + 2500 * math.exp(-t / 0.5)),
    (t) => swell(t, 0.15, 3.0, 4.0),
  );
  b
    ..add(gain(crash, 2.2))
    ..add(
      gain(
        shape(lowpass(brown(4, rng), (_) => 120), (t) => swell(t, 0.3, 3, 4)),
        0.8,
      ),
    );
  for (var i = 0; i < 40; i++) {
    b.add(
      click(rng, centre: 2000 + rng.nextDouble() * 4000, time: 0.003),
      at: 0.6 + rng.nextDouble() * 2.5,
      gain: 0.15,
      pan: rng.nextDouble() - 0.5,
    );
  }
  return reverb(b, size: 0.7, mix: 0.3);
}

/// A great lamp taking its flame: a soft rush, then a steady roar.
Buf lampLight() {
  final rng = math.Random(15);
  final b = Buf(3)
    ..add(modal(0.3, 2800, const [(1, 1, 0.05), (1.7, 0.4, 0.03)]), gain: 0.25)
    ..add(
      gain(
        shape(
          lowpass(noise(2.8, rng), (t) => 250 + 900 * math.exp(-t / 0.3)),
          (t) => swell(t, 0.1, 1.2, 2.8),
        ),
        2.4,
      ),
      at: 0.1,
    )
    ..add(glassNote(880, 2.5), at: 0.4, gain: 0.08);
  return reverb(b, size: 0.5, mix: 0.3);
}

/// A house gecko (cicak): a quick run of dry chirps.
Buf geckoCall() {
  final rng = math.Random(16);
  final b = Buf(1.2);
  const count = 5;
  for (var i = 0; i < count; i++) {
    final at = 0.05 + i * 0.1;
    b
      ..add(
        shape(
          sum([
            tone(0.05, (t) => 1900 - 900 * t),
            gain(tone(0.05, (t) => 3800 - 1800 * t), 0.35),
          ]),
          (t) => decay(t, 0.012),
        ),
        at: at,
        gain: 0.6 - i * 0.06,
      )
      ..add(click(rng, centre: 3500, time: 0.001), at: at, gain: 0.3);
  }
  return reverb(b, size: 0.35, mix: 0.25);
}

/// A gull crying, far off: a few falling calls.
Buf gullCry() {
  final b = Buf(2.4);
  for (final (at, g) in [(0.0, 1.0), (0.42, 0.8), (0.8, 0.6)]) {
    final call = shape(
      sum([
        for (final (h, amp) in [(1, 1.0), (2, 0.5), (3, 0.3), (4, 0.15)])
          gain(tone(0.34, (t) => (1450 - 650 * t / 0.34) * h), amp),
      ]),
      (t) => swell(t, 0.03, 0.18, 0.34),
    );
    b.add(bandpass(call, (_) => 1800, 0.9), at: at, gain: g * 0.6, pan: 0.2);
  }
  return reverb(b, size: 0.8, mix: 0.4);
}

/// Wings beating as a bird or bat takes off.
Buf wingsFlutter() {
  final rng = math.Random(17);
  final b = Buf(0.9);
  for (var i = 0; i < 9; i++) {
    b.add(
      gain(
        shape(
          bandpass(noise(0.06, rng), (_) => 700 + rng.nextDouble() * 300, 1.2),
          (t) => decay(t, 0.02),
        ),
        1.2 - i * 0.1,
      ),
      at: i * 0.075,
      pan: -0.2 + i * 0.05,
    );
  }
  return reverb(b, size: 0.3, mix: 0.2);
}

/// An iron oven door dragged open over grit.
Buf ovenDoor() {
  final rng = math.Random(18);
  final b = Buf(2.2);
  final scrape = shape(
    bandpass(noise(1.1, rng), (t) => 420 + 260 * math.sin(t * 9), 3),
    (t) =>
        swell(t, 0.05, 0.3, 1.1) * (0.5 + 0.5 * math.sin(t * tau * 17).abs()),
  );
  b
    ..add(gain(scrape, 2.2))
    ..add(
      modal(1.2, 180, const [(1, 1, 0.4), (2.3, 0.5, 0.25), (3.9, 0.3, 0.15)]),
      at: 1.05,
      gain: 0.5,
    )
    ..add(gain(lowpass(noise(0.3, rng), (_) => 600), 0.4), at: 1.05);
  for (var i = 0; i < 25; i++) {
    b.add(
      click(rng, centre: 1500 + rng.nextDouble() * 2500, time: 0.002),
      at: 1.1 + rng.nextDouble() * 0.6,
      gain: 0.1,
      pan: rng.nextDouble() - 0.5,
    );
  }
  return reverb(b, size: 0.35, mix: 0.2);
}

/// The mountain, far off: a long, low rumble.
Buf rumble() {
  final rng = math.Random(19);
  final b = Buf(5.5)
    ..add(
      gain(
        shape(
          lowpass(brown(5, rng), (t) => 60 + 60 * math.exp(-t / 1.5)),
          (t) => swell(t, 0.8, 3, 5),
        ),
        3,
      ),
    )
    ..add(
      gain(
        shape(lowpass(noise(5, rng), (_) => 160), (t) => swell(t, 1, 2.5, 5)),
        0.5,
      ),
      pan: 0.3,
    );
  return reverb(b, size: 0.95, mix: 0.4, damp: 0.7);
}

/// Pumice falling: light stones pattering on tiles and into water.
Buf pumiceFall() {
  final rng = math.Random(26);
  final b = Buf(3.5)
    ..add(
      gain(
        shape(highpass(noise(3.2, rng), 1500), (t) => swell(t, 0.5, 1, 3.2)),
        0.08,
      ),
    );
  for (var i = 0; i < 140; i++) {
    final at = rng.nextDouble() * 3.1;
    final edge = math.min(1.0, math.min(at / 0.6, (3.1 - at) / 0.8));
    b.add(
      modal(0.06, 900 + rng.nextDouble() * 1800, const [
        (1, 1, 0.008),
        (2.2, 0.4, 0.004),
      ]),
      at: at,
      gain: (0.1 + rng.nextDouble() * 0.3) * edge,
      pan: rng.nextDouble() * 1.4 - 0.7,
    );
  }
  return reverb(b, size: 0.4, mix: 0.25);
}

/// A lava-stone mill turned a little: stone grinding on stone.
Buf millstone() {
  final rng = math.Random(27);
  final b = Buf(2.4);
  final grind = shape(
    lowpass(noise(2, rng), (t) => 380 + 120 * math.sin(t * tau * 1.3)),
    (t) => swell(t, 0.3, 0.6, 2) * (0.6 + 0.4 * math.sin(t * tau * 5.5).abs()),
  );
  b
    ..add(gain(grind, 2.4))
    ..add(gain(lowpass(brown(2, rng), (_) => 90), 0.8));
  return reverb(b, size: 0.3, mix: 0.15);
}

/// A shovel biting into hard ash, three times, and the bank giving way.
Buf shovelDig() {
  final rng = math.Random(28);
  final b = Buf(2.6);
  for (final at in [0.0, 0.55, 1.1]) {
    b
      ..add(
        modal(0.2, 1300 + rng.nextDouble() * 200, const [
          (1, 1, 0.03),
          (2.4, 0.5, 0.015),
        ]),
        at: at,
        gain: 0.4,
      )
      ..add(
        gain(
          shape(
            bandpass(noise(0.35, rng), (_) => 900, 1.5),
            (t) => swell(t, 0.01, 0.25, 0.35),
          ),
          1.2,
        ),
        at: at + 0.02,
      );
  }
  b.add(
    gain(
      shape(
        lowpass(noise(0.9, rng), (t) => 1500 - 1000 * t),
        (t) => swell(t, 0.05, 0.7, 0.9),
      ),
      1.6,
    ),
    at: 1.6,
  );
  return reverb(b, size: 0.3, mix: 0.15);
}

// ---------------------------------------------------------------------------

/// Bastille: a big key goes in, turns against the wards, and the bolt
/// shoots back.
Buf keyTurn() {
  final rng = math.Random(40);
  final b = Buf(1.4);
  // In: a short metal scrape.
  b.add(
    gain(
      shape(
        bandpass(noise(0.18, rng), (t) => 2600 - t * 4000, 3),
        (t) => swell(t, 0.02, 0.08, 0.18),
      ),
      1.2,
    ),
  );
  // The turn: wards grinding.
  b.add(
    gain(
      shape(
        bandpass(noise(0.35, rng), (t) => 900 + 300 * math.sin(t * 30), 2),
        (t) => swell(t, 0.05, 0.1, 0.35),
      ),
      1.4,
    ),
    at: 0.25,
  );
  // The bolt: a heavy iron clunk, and its lighter echo from the strike.
  final clunk = sum([
    modal(0.5, 310, const [(1, 1, 0.08), (2.2, 0.6, 0.05), (3.7, 0.3, 0.03)]),
    gain(
      shape(lowpass(noise(0.1, rng), (_) => 700), (t) => decay(t, 0.015)),
      1.5,
    ),
  ]);
  b
    ..add(clunk, at: 0.62)
    ..add(
      modal(0.3, 820, const [(1, 1, 0.04), (2.6, 0.5, 0.02)]),
      at: 0.66,
      gain: 0.35,
      pan: 0.2,
    );
  return reverb(b, size: 0.55, mix: 0.3);
}

/// Bastille: a heavy iron-bound door, low on its hinges, closing on stone.
Buf doorHeavy() {
  final rng = math.Random(41);
  const seconds = 1.8;
  final pulses = Float64List(n(seconds));
  var phase = 0.0;
  for (var i = 0; i < pulses.length; i++) {
    final t = i / rate;
    final f = 22 + 30 * math.pow(math.sin(math.pi * t / seconds), 2);
    phase += (f + rng.nextDouble() * 4) / rate;
    if (phase >= 1) {
      phase -= 1;
      pulses[i] = 1;
    }
  }
  final groan = sum([
    bandpass(pulses, (_) => 280, 12),
    gain(bandpass(pulses, (_) => 610, 12), 0.7),
    gain(bandpass(pulses, (_) => 1150, 10), 0.3),
  ]);
  final thud = sum([
    shape(tone(0.5, (_) => 62), (t) => decay(t, 0.1)),
    gain(
      shape(lowpass(noise(0.3, rng), (_) => 300), (t) => decay(t, 0.05)),
      2.5,
    ),
  ]);
  final b = Buf(seconds + 1.2)
    ..add(shape(groan, (t) => swell(t, 0.2, 0.3, seconds)), gain: 3)
    ..add(thud, at: seconds - 0.05, gain: 1.2);
  return reverb(b, size: 0.75, mix: 0.35, damp: 0.5);
}

/// The bell of Saint-Paul, across the rooftops: two strokes, higher and
/// further off than the bell that tolls elsewhere.
Buf bellSaintPaul() {
  final rng = math.Random(42);
  final b = Buf(9);
  for (final at in [0.0, 3.4]) {
    b
      ..add(lowpass(bell(247, 5.5), (_) => 2400), at: at, gain: 0.7)
      ..add(
        gain(
          shape(lowpass(noise(0.05, rng), (_) => 1500), (t) => decay(t, 0.008)),
          0.4,
        ),
        at: at,
      );
  }
  return reverb(b, size: 0.95, mix: 0.45, damp: 0.55);
}

/// A goose quill writing a line: short scratches, a dip, then more.
Buf quill() {
  final rng = math.Random(43);
  final b = Buf(1.8);
  var t = 0.05;
  while (t < 1.6) {
    final len = 0.04 + rng.nextDouble() * 0.12;
    b.add(
      gain(
        shape(
          bandpass(noise(len, rng), (_) => 3500 + rng.nextDouble() * 2500, 2.5),
          (x) => swell(x, 0.008, 0.02, len),
        ),
        0.8 + rng.nextDouble() * 0.5,
      ),
      at: t,
      pan: -0.2 + t * 0.2,
    );
    t += len + 0.02 + rng.nextDouble() * 0.06;
    // Halfway, the pen goes back to the ink.
    if (t > 0.8 && t < 0.95) {
      b.add(click(rng, centre: 1800, time: 0.003), at: t + 0.05, gain: 0.6);
      t += 0.2;
    }
  }
  return reverb(b, size: 0.2, mix: 0.12);
}

/// Gyeongju: bronze poured into the mould, a long rush and a settling.
Buf bronzePour() {
  final rng = math.Random(44);
  const seconds = 4.0;
  final b = Buf(seconds + 1)
    ..add(
      gain(
        shape(
          lowpass(noise(seconds, rng), (t) => 700 + 400 * math.sin(t * 3)),
          (t) => swell(t, 0.4, 1.2, seconds),
        ),
        1.6,
      ),
    );
  for (var i = 0; i < 40; i++) {
    b.add(
      modal(0.15, 70 + rng.nextDouble() * 120, const [(1, 1, 0.05)]),
      at: rng.nextDouble() * (seconds - 0.3),
      gain: 0.5,
      pan: rng.nextDouble() - 0.5,
    );
  }
  return reverb(b, size: 0.6, mix: 0.3);
}

/// Gyeongju: the great bell's full ring, its beat swelling and fading.
Buf greatBell() {
  final rng = math.Random(45);
  final b = Buf(20)
    ..add(greatBellRing(20))
    ..add(
      gain(
        shape(lowpass(noise(0.1, rng), (_) => 500), (t) => decay(t, 0.025)),
        1.4,
      ),
    );
  return reverb(b, size: 0.9, mix: 0.35, damp: 0.55);
}

/// Gyeongju: the log striker drawn back on its ropes.
Buf strikerCreak() {
  final rng = math.Random(46);
  const seconds = 1.2;
  final pulses = Float64List(n(seconds));
  var phase = 0.0;
  for (var i = 0; i < pulses.length; i++) {
    final t = i / rate;
    phase +=
        (30 + 25 * math.sin(math.pi * t / seconds) + rng.nextDouble() * 5) /
        rate;
    if (phase >= 1) {
      phase -= 1;
      pulses[i] = 1;
    }
  }
  final b = Buf(seconds + 0.5)
    ..add(
      shape(
        sum([
          bandpass(pulses, (_) => 420, 10),
          gain(bandpass(pulses, (_) => 900, 10), 0.6),
        ]),
        (t) => swell(t, 0.2, 0.3, seconds),
      ),
      gain: 2.5,
    );
  return reverb(b, size: 0.5, mix: 0.25);
}

/// Whitechapel 1891: a man's footsteps on wet stone, walking away.
Buf footstepsAway() {
  final rng = math.Random(47);
  final b = Buf(4.2);
  for (var i = 0; i < 7; i++) {
    final far = i / 6;
    b.add(
      lowpass(footstep(rng), (_) => 900 - far * 600),
      at: 0.1 + i * 0.52,
      gain: 0.9 * (1 - far * 0.8),
      pan: 0.2 + far * 0.5,
    );
  }
  return reverb(b, size: 0.7, mix: 0.35);
}

/// Whitechapel 1891: a police whistle, two long blasts.
Buf policeWhistle() {
  final rng = math.Random(48);
  final b = Buf(2.6);
  for (final at in [0.05, 1.1]) {
    final trill = shape(
      sum([
        tone(0.8, (t) => 2900 + 90 * math.sin(tau * 32 * t)),
        gain(tone(0.8, (t) => 3150 + 90 * math.sin(tau * 32 * t)), 0.6),
        gain(bandpass(noise(0.8, rng), (_) => 3000, 2), 0.3),
      ]),
      (t) => swell(t, 0.03, 0.1, 0.8),
    );
    b.add(gain(trill, 0.5), at: at);
  }
  return reverb(b, size: 0.6, mix: 0.3);
}

/// Whitechapel 1891: a train over the railway arch, heard from under it.
Buf trainArch() {
  final rng = math.Random(49);
  const seconds = 6.0;
  final b = Buf(seconds)
    ..add(
      gain(
        shape(
          lowpass(brown(seconds, rng), (_) => 160),
          (t) => math.sin(math.pi * t / seconds),
        ),
        1.4,
      ),
    );
  // Wheels over the rail joints.
  for (var t = 0.8; t < seconds - 0.8; t += 0.42) {
    final loud = math.sin(math.pi * t / seconds);
    b
      ..add(lowpass(footstep(rng), (_) => 300), at: t, gain: 0.8 * loud)
      ..add(lowpass(footstep(rng), (_) => 300), at: t + 0.09, gain: 0.7 * loud);
  }
  return reverb(b, size: 0.8, mix: 0.35);
}

/// Chongling: a marble door leaf grinding on its stone socket, then
/// settling.
Buf stoneDoor() {
  final rng = math.Random(50);
  const seconds = 2.2;
  final grind = shape(
    sum([
      bandpass(brown(seconds, rng), (t) => 180 + 60 * math.sin(tau * t * 3), 3),
      gain(bandpass(noise(seconds, rng), (_) => 900, 4), 0.25),
    ]),
    (t) =>
        swell(t, 0.3, 0.4, seconds) * (0.6 + 0.4 * math.sin(tau * 7 * t).abs()),
  );
  final settle = sum([
    shape(tone(0.6, (_) => 48), (t) => decay(t, 0.12)),
    gain(shape(lowpass(noise(0.3, rng), (_) => 250), (t) => decay(t, 0.05)), 2),
  ]);
  final b = Buf(seconds + 1.4)
    ..add(gain(grind, 2.2))
    ..add(settle, at: seconds - 0.1, gain: 1.1);
  return reverb(b, size: 0.85, mix: 0.4, damp: 0.5);
}

/// Chongling: a counter over a sample, the clicks quickening to a
/// chatter, then the reader's short tone.
Buf reactorCount() {
  final rng = math.Random(51);
  final b = Buf(2.4);
  var t = 0.05;
  while (t < 1.6) {
    final perSecond = 6 + 70 * math.pow(t / 1.6, 2);
    b.add(
      click(rng, centre: 3200 + rng.nextDouble() * 800, time: 0.001),
      at: t,
      gain: 0.7,
      pan: (rng.nextDouble() - 0.5) * 0.2,
    );
    t += -math.log(1 - rng.nextDouble()) / perSecond;
  }
  b.add(
    shape(tone(0.18, (_) => 1320), (t) => swell(t, 0.005, 0.04, 0.18)),
    at: 1.75,
    gain: 0.18,
  );
  return reverb(b, size: 0.2, mix: 0.1);
}

/// Chongling: wind through the pines round the tombs, rising and falling
/// like water.
Buf windPines() {
  final rng = math.Random(52);
  const seconds = 4.5;
  final b = Buf(seconds)
    ..add(
      gain(
        shape(
          bandpass(
            noise(seconds, rng),
            (t) => 450 + 500 * math.sin(math.pi * t / seconds),
            1.1,
          ),
          (t) => swell(t, 1.4, 1.8, seconds),
        ),
        0.8,
      ),
    )
    ..add(
      gain(
        shape(
          highpass(noise(seconds, rng), 3500),
          (t) => swell(t, 1.8, 1.6, seconds) * 0.5,
        ),
        0.12,
      ),
      pan: 0.3,
    );
  return reverb(b, size: 0.8, mix: 0.35);
}

/// Alamut: wind over the bare rock, in gusts, with a low moan under it.
Buf windRock() {
  final rng = math.Random(53);
  const seconds = 4.5;
  final b = Buf(seconds)
    ..add(
      gain(
        shape(
          bandpass(
            noise(seconds, rng),
            (t) => 700 + 600 * math.sin(math.pi * t / seconds),
            1.6,
          ),
          (t) =>
              swell(t, 1.2, 1.6, seconds) *
              (0.6 + 0.4 * math.sin(tau * t * 0.7).abs()),
        ),
        0.9,
      ),
      pan: -0.3,
    )
    ..add(
      shape(
        tone(seconds, (t) => 180 + 25 * math.sin(tau * t / 3)),
        (t) => swell(t, 1.5, 1.5, seconds) * 0.5,
      ),
      gain: 0.05,
    );
  return reverb(b, size: 0.85, mix: 0.4);
}

/// Alamut: a heavy wooden cover dragged aside over stone, then set down.
Buf tankCover() {
  final rng = math.Random(54);
  final drag = shape(
    bandpass(brown(0.9, rng), (t) => 260 + 120 * math.sin(tau * t * 9), 2.5),
    (t) => swell(t, 0.1, 0.2, 0.9) * (0.7 + 0.3 * math.sin(tau * t * 14).abs()),
  );
  final thud = sum([
    shape(tone(0.4, (_) => 70), (t) => decay(t, 0.08)),
    gain(shape(lowpass(noise(0.2, rng), (_) => 400), (t) => decay(t, 0.03)), 2),
  ]);
  final b = Buf(1.8)
    ..add(gain(drag, 2), at: 0.02)
    ..add(thud, at: 0.95, gain: 1.2);
  return reverb(b, size: 0.7, mix: 0.35, damp: 0.5);
}

/// Alamut: a ring of iron keys lifted from its hook.
Buf keysJingle() {
  final rng = math.Random(55);
  final b = Buf(1);
  for (var i = 0; i < 9; i++) {
    b.add(
      modal(0.35, 1900 + rng.nextDouble() * 1800, const [
        (1, 1, 0.06),
        (2.4, 0.5, 0.04),
        (4.1, 0.25, 0.02),
      ]),
      at: 0.02 + i * 0.05 + rng.nextDouble() * 0.04,
      gain: 0.18 + rng.nextDouble() * 0.12,
      pan: (rng.nextDouble() - 0.5) * 0.4,
    );
  }
  return reverb(b, size: 0.4, mix: 0.25);
}

/// Alamut: an eagle's cry far over the gorge, a thin falling scream.
Buf eagleCry() {
  final b = Buf(2.6);
  for (final (at, g, len) in [(0.0, 1.0, 0.7), (0.85, 0.6, 0.5)]) {
    final call = shape(
      sum([
        for (final (h, amp) in [(1, 1.0), (2, 0.35), (3, 0.12)])
          gain(
            tone(
              len,
              (t) => (2300 - 900 * t / len + 60 * math.sin(tau * t * 22)) * h,
            ),
            amp,
          ),
      ]),
      (t) => swell(t, 0.04, 0.3, len),
    );
    b.add(bandpass(call, (_) => 2400, 0.8), at: at, gain: g * 0.4, pan: 0.3);
  }
  return reverb(b, size: 0.95, mix: 0.55);
}

/// Great Zimbabwe: a granite block set down on another, a dull knock and
/// grit.
Buf stoneSet() {
  final rng = math.Random(56);
  final knock = sum([
    modal(0.5, 180, const [(1, 1, 0.06), (2.3, 0.5, 0.04), (3.9, 0.2, 0.02)]),
    gain(
      shape(lowpass(noise(0.15, rng), (_) => 900), (t) => decay(t, 0.02)),
      1.6,
    ),
  ]);
  final grit = shape(
    bandpass(noise(0.3, rng), (_) => 2400, 2),
    (t) => decay(t, 0.08),
  );
  final b = Buf(1)
    ..add(knock, at: 0.02, gain: 1.2)
    ..add(grit, at: 0.03, gain: 0.25);
  return reverb(b, size: 0.4, mix: 0.2);
}

/// Great Zimbabwe: cicadas in dry grass, a shimmering buzz that swells and
/// falls.
Buf cicadas() {
  final rng = math.Random(57);
  const seconds = 4.0;
  final buzz = shape(
    bandpass(noise(seconds, rng), (_) => 5200, 6),
    (t) =>
        swell(t, 0.6, 1.2, seconds) *
        (0.55 + 0.45 * math.sin(tau * t * 38).abs()),
  );
  final b = Buf(seconds)
    ..add(gain(buzz, 1.4), pan: 0.3)
    ..add(
      gain(
        shape(
          bandpass(noise(seconds, rng), (_) => 4700, 6),
          (t) => swell(t, 1.2, 1.0, seconds) * 0.6,
        ),
        1.0,
      ),
      pan: -0.4,
    );
  return reverb(b, size: 0.5, mix: 0.2);
}

/// Great Zimbabwe: a stiff field notebook opened, its pages flicked.
Buf notebook() {
  final rng = math.Random(58);
  final b = Buf(0.9);
  for (var i = 0; i < 4; i++) {
    b.add(
      shape(
        bandpass(noise(0.12, rng), (_) => 1800 + i * 300, 1.4),
        (t) => swell(t, 0.01, 0.08, 0.12),
      ),
      at: 0.05 + i * 0.12,
      gain: 0.5 - i * 0.08,
    );
  }
  b.add(click(rng, centre: 900, time: 0.004), at: 0.02, gain: 0.5);
  return reverb(b, size: 0.2, mix: 0.12);
}

/// Dyatlov Pass: wind over a bare ridge, thin and high, gusting.
Buf windRidge() {
  final rng = math.Random(59);
  const seconds = 4.5;
  final b = Buf(seconds)
    ..add(
      gain(
        shape(
          bandpass(
            noise(seconds, rng),
            (t) => 1100 + 700 * math.sin(math.pi * t / seconds),
            2.2,
          ),
          (t) =>
              swell(t, 1.0, 1.6, seconds) *
              (0.5 + 0.5 * math.sin(tau * t * 0.9).abs()),
        ),
        1.0,
      ),
      pan: 0.35,
    )
    ..add(
      gain(
        shape(
          lowpass(brown(seconds, rng), (_) => 220),
          (t) => swell(t, 1.5, 1.5, seconds),
        ),
        0.6,
      ),
    );
  return reverb(b, size: 0.7, mix: 0.3);
}

/// Dyatlov Pass: slit tent canvas snapping in the wind.
Buf canvasFlap() {
  final rng = math.Random(60);
  final b = Buf(1.6);
  for (var i = 0; i < 5; i++) {
    b.add(
      shape(
        bandpass(noise(0.14, rng), (_) => 700 + rng.nextDouble() * 500, 1.4),
        (t) => decay(t, 0.03),
      ),
      at: 0.05 + i * 0.22 + rng.nextDouble() * 0.08,
      gain: 0.9 - i * 0.1,
      pan: (rng.nextDouble() - 0.5) * 0.3,
    );
  }
  return reverb(b, size: 0.5, mix: 0.25);
}

/// Dyatlov Pass: a field radio's static, a carrier whistle drifting in it.
Buf radioStatic() {
  final rng = math.Random(61);
  const seconds = 2.2;
  final hiss = shape(
    bandpass(noise(seconds, rng), (_) => 2200, 0.8),
    (t) =>
        swell(t, 0.05, 0.3, seconds) *
        (0.6 + 0.4 * math.sin(tau * t * 3).abs()),
  );
  final whistle = shape(
    tone(seconds, (t) => 1400 + 300 * math.sin(tau * t * 0.6)),
    (t) => swell(t, 0.4, 0.6, seconds) * 0.4,
  );
  return Buf(seconds)
    ..add(gain(hiss, 0.6))
    ..add(gain(whistle, 0.05));
}

/// Honnō-ji: a temple bell struck with a swung beam, low, wavering, the
/// hum dying away for a long time.
Buf templeBell() {
  final rng = math.Random(62);
  const seconds = 14.0;
  final b = Buf(seconds)
    ..add(
      modal(seconds, 98, const [
        (1, 1, 6),
        (1.007, 0.6, 5.5),
        (2.04, 0.45, 3.5),
        (2.76, 0.3, 2.6),
        (3.9, 0.18, 1.6),
        (5.4, 0.08, 0.7),
      ]),
      gain: 0.5,
    )
    // The beam's soft thud on the bronze.
    ..add(
      gain(
        shape(lowpass(noise(0.15, rng), (_) => 400), (t) => decay(t, 0.03)),
        1.2,
      ),
    );
  return reverb(b, size: 0.9, mix: 0.35, damp: 0.6);
}

/// Honnō-ji: a trowel drawn across damp clay, three strokes, grit in it.
Buf trowel() {
  final rng = math.Random(63);
  final b = Buf(1.8);
  for (final (i, at) in [0.0, 0.5, 1.0].indexed) {
    b.add(
      shape(
        bandpass(noise(0.4, rng), (t) => 2600 - t * 1800, 1.6),
        (t) => swell(t, 0.04, 0.2, 0.4),
      ),
      at: at,
      gain: 0.7 - i * 0.1,
      pan: -0.1 + i * 0.1,
    );
    for (var k = 0; k < 4; k++) {
      b.add(
        click(rng, centre: 3500, time: 0.0015),
        at: at + 0.05 + rng.nextDouble() * 0.3,
        gain: 0.12,
      );
    }
  }
  return reverb(b, size: 0.3, mix: 0.12);
}

/// A natural trumpet (no valves) playing a note: harmonics of brass, a
/// quick attack, a little vibrato.
Float64List _brass(double seconds, double pitch, math.Random rng) {
  final out = Float64List(n(seconds));
  const partials = [
    (1, 1.0),
    (2, 0.7),
    (3, 0.5),
    (4, 0.32),
    (5, 0.2),
    (6, 0.12),
  ];
  for (final (k, amp) in partials) {
    final part = shape(
      tone(seconds, (t) => pitch * k * (1 + 0.004 * math.sin(tau * t * 5.5))),
      (t) => swell(t, 0.04 + 0.01 * k, 0.12, seconds) * amp,
    );
    for (var i = 0; i < out.length; i++) {
      out[i] += part[i];
    }
  }
  return out;
}

/// Roanoke: a call sounded on a natural trumpet across the water at night:
/// up the harmonics and down, held, then a long last note.
Buf trumpetCall() {
  final rng = math.Random(64);
  const notes = [
    (392.0, 0.35),
    (523.3, 0.35),
    (659.3, 0.35),
    (784.0, 0.8),
    (523.3, 1.4),
  ];
  final b = Buf(4.6);
  var at = 0.1;
  for (final (pitch, length) in notes) {
    b.add(_brass(length, pitch, rng), at: at, gain: 0.07);
    at += length + 0.06;
  }
  return reverb(b, size: 0.95, mix: 0.45, damp: 0.5);
}

/// Roanoke: low surf on the banks far off, swelling and falling.
Buf surfLow() {
  final rng = math.Random(65);
  const seconds = 4.5;
  final b = Buf(seconds)
    ..add(
      gain(
        shape(
          lowpass(
            noise(seconds, rng),
            (t) => 500 + 400 * math.sin(math.pi * t / seconds),
          ),
          (t) => swell(t, 1.4, 1.8, seconds),
        ),
        1.4,
      ),
      pan: -0.2,
    )
    ..add(
      gain(
        shape(
          bandpass(noise(seconds, rng), (_) => 2200, 1),
          (t) => swell(t, 1.8, 1.4, seconds) * 0.4,
        ),
        0.5,
      ),
      pan: 0.3,
    );
  return reverb(b, size: 0.6, mix: 0.25);
}

/// Roanoke: a broken chest's lid lifted on a stiff hinge, set back.
Buf chestLid() {
  final rng = math.Random(66);
  const seconds = 1.4;
  final pulses = Float64List(n(0.7));
  var phase = 0.0;
  for (var i = 0; i < pulses.length; i++) {
    final t = i / rate;
    phase +=
        (40 + 30 * math.sin(math.pi * t / 0.7) + rng.nextDouble() * 6) / rate;
    if (phase >= 1) {
      phase -= 1;
      pulses[i] = 1;
    }
  }
  final b = Buf(seconds)
    ..add(gain(bandpass(pulses, (_) => 900, 4), 2.5), at: 0.05)
    ..add(
      modal(0.5, 140, const [(1, 1, 0.12), (2.4, 0.4, 0.06)]),
      at: 0.8,
      gain: 0.4,
    )
    ..add(
      shape(lowpass(noise(0.15, rng), (_) => 600), (t) => decay(t, 0.03)),
      at: 0.8,
      gain: 0.6,
    );
  return reverb(b, size: 0.3, mix: 0.15);
}

/// Franklin: sea ice grinding and creaking against a hull, slow groans.
Buf iceCreak() {
  final rng = math.Random(67);
  const seconds = 3.2;
  final b = Buf(seconds);
  for (var i = 0; i < 4; i++) {
    final at = 0.1 + i * 0.7 + rng.nextDouble() * 0.2;
    final length = 0.5 + rng.nextDouble() * 0.5;
    b.add(
      shape(
        bandpass(noise(length, rng), (t) => 300 + 600 * t / length, 6),
        (t) => swell(t, 0.1, 0.2, length),
      ),
      at: at,
      gain: 1.6,
      pan: (rng.nextDouble() - 0.5) * 0.6,
    );
  }
  b.add(
    shape(
      lowpass(brown(seconds, rng), (_) => 160),
      (t) => swell(t, 0.5, 1.0, seconds),
    ),
    gain: 0.5,
  );
  return reverb(b, size: 0.7, mix: 0.3);
}

/// Franklin: a helicopter's rotor turning slowly down, the beat fading.
Buf rotor() {
  final rng = math.Random(68);
  const seconds = 3.0;
  final b = Buf(seconds);
  var at = 0.0;
  var gap = 0.12;
  while (at < seconds - 0.2) {
    b.add(
      shape(lowpass(noise(0.08, rng), (_) => 500), (t) => decay(t, 0.03)),
      at: at,
      gain: 0.9 * (1 - at / seconds),
    );
    at += gap;
    gap *= 1.04;
  }
  return reverb(b, size: 0.5, mix: 0.2);
}

/// Franklin: a frame drum struck once, low, its skin humming.
Buf drumLow() {
  final rng = math.Random(69);
  final b = Buf(2.2)
    ..add(
      modal(2, 72, const [(1, 1, 0.6), (1.6, 0.5, 0.35), (2.3, 0.25, 0.2)]),
      gain: 0.6,
    )
    ..add(
      shape(lowpass(noise(0.12, rng), (_) => 700), (t) => decay(t, 0.03)),
      gain: 0.5,
    );
  return reverb(b, size: 0.6, mix: 0.3);
}

/// Franklin: a sonar ping, a pure tone with a long watery tail.
Buf sonarPing() {
  final b = Buf(2.4)
    ..add(
      shape(
        tone(2.2, (_) => 1320),
        (t) => decay(t, 0.45) * swell(t, 0.005, 0.3, 2.2),
      ),
      gain: 0.18,
    );
  return reverb(b, size: 0.9, mix: 0.4, damp: 0.3);
}

/// A seal slipping off the ice into the water.
Buf splash() {
  final rng = math.Random(70);
  final b = Buf(1.2)
    ..add(
      shape(
        bandpass(noise(0.6, rng), (t) => 1800 - 1200 * t, 1.2),
        (t) => decay(t, 0.15),
      ),
      gain: 1.2,
    )
    ..add(
      shape(lowpass(noise(0.3, rng), (_) => 400), (t) => decay(t, 0.06)),
      gain: 0.8,
    );
  return reverb(b, size: 0.4, mix: 0.2);
}

final sfx = <String, Buf Function()>{
  'stone_door': stoneDoor,
  'reactor_count': reactorCount,
  'wind_pines': windPines,
  'wind_rock': windRock,
  'tank_cover': tankCover,
  'keys_jingle': keysJingle,
  'eagle_cry': eagleCry,
  'stone_set': stoneSet,
  'cicadas': cicadas,
  'temple_bell': templeBell,
  'trowel': trowel,
  'trumpet_call': trumpetCall,
  'surf_low': surfLow,
  'chest_lid': chestLid,
  'ice_creak': iceCreak,
  'rotor': rotor,
  'drum_low': drumLow,
  'sonar_ping': sonarPing,
  'splash': splash,
  'notebook': notebook,
  'wind_ridge': windRidge,
  'canvas_flap': canvasFlap,
  'radio_static': radioStatic,
  'footsteps_away': footstepsAway,
  'police_whistle': policeWhistle,
  'train_arch': trainArch,
  'bronze_pour': bronzePour,
  'great_bell': greatBell,
  'striker_creak': strikerCreak,
  'key_turn': keyTurn,
  'door_heavy': doorHeavy,
  'bell_saint_paul': bellSaintPaul,
  'quill': quill,
  'shovel_dig': shovelDig,
  'oven_door': ovenDoor,
  'rumble': rumble,
  'pumice_fall': pumiceFall,
  'millstone': millstone,
  'gecko_call': geckoCall,
  'gull_cry': gullCry,
  'wings_flutter': wingsFlutter,
  'ship_horn': shipHorn,
  'wave_crash': waveCrash,
  'lamp_light': lampLight,
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

/// Flannan Isles: wind over a bare island, the sea below, a low drone.
Buf flannanWind() => loop(48, (seconds) {
  final rng = math.Random(24);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (61.74, 0.45, 24),
        (92.5, 0.25, 16),
        (146.8, 0.1, 12),
      ]),
      gain: 0.4,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 700 + 450 * math.sin(tau * t / 12),
      1.2,
    ),
    (t) => 0.4 + 0.6 * math.pow(math.sin(tau * t / 16), 2),
  );
  final swell = shape(
    lowpass(brown(seconds, rng), (_) => 180),
    (t) => 0.5 + 0.5 * math.sin(tau * t / 8),
  );
  b
    ..add(gain(wind, 0.3), pan: 0.4)
    ..add(gain(swell, 0.6), pan: -0.3);
  return reverb(b, size: 0.9, mix: 0.4, damp: 0.5);
});

/// Pompeii: a warm drone in D, dry wind over the ruins, and a slow plucked
/// string, like a lyre heard from another courtyard.
Buf pompeiiAsh() => loop(48, (seconds) {
  final rng = math.Random(25);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (73.42, 0.4, 24),
        (110.0, 0.22, 16),
        (146.83, 0.1, 12),
      ]),
      gain: 0.4,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 500 + 300 * math.sin(tau * t / 16),
      1.4,
    ),
    (t) => 0.3 + 0.7 * math.pow(math.sin(tau * t / 24), 2),
  );
  b.add(gain(wind, 0.18), pan: 0.3);
  // D dorian, a phrase every 12 seconds, never quite the same.
  const scale = [293.66, 329.63, 349.23, 392.0, 440.0, 493.88, 587.33];
  for (var at = 2.0; at < seconds - 3; at += 12) {
    var degree = rng.nextInt(3) + 2;
    for (var k = 0; k < 4; k++) {
      final f = scale[degree];
      b.add(
        modal(2.5, f, const [
          (1, 1, 0.9),
          (2, 0.35, 0.5),
          (3, 0.15, 0.3),
          (4.02, 0.06, 0.2),
        ]),
        at: at + k * 0.9 + rng.nextDouble() * 0.15,
        gain: 0.07,
        pan: -0.4,
      );
      degree = (degree + rng.nextInt(3) - 1).clamp(0, scale.length - 1);
    }
  }
  return reverb(b, size: 0.8, mix: 0.4, damp: 0.5);
});

/// Bastille: a cold drone in A under stone, a draught in the court, and a
/// slow bowed line, like a viol heard through a wall.
Buf bastilleDawn() => loop(48, (seconds) {
  final rng = math.Random(26);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (55.0, 0.45, 24),
        (82.41, 0.22, 16),
        (130.81, 0.08, 12),
      ]),
      gain: 0.4,
    );
  final draught = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 420 + 200 * math.sin(tau * t / 16),
      1.6,
    ),
    (t) => 0.3 + 0.7 * math.pow(math.sin(tau * t / 24), 2),
  );
  b.add(gain(draught, 0.16), pan: -0.3);
  // A aeolian, two long bowed notes every 16 seconds.
  const scale = [220.0, 246.94, 261.63, 293.66, 329.63, 349.23, 392.0];
  for (var at = 3.0; at < seconds - 6; at += 16) {
    var degree = rng.nextInt(3) + 2;
    for (var k = 0; k < 2; k++) {
      final f = scale[degree];
      const len = 4.5;
      final bow = sum([
        tone(len, (t) => f * (1 + 0.004 * math.sin(tau * 5 * t))),
        gain(
          tone(len, (t) => 2 * f * (1 + 0.004 * math.sin(tau * 5 * t))),
          0.35,
        ),
        gain(
          tone(len, (t) => 3 * f * (1 + 0.004 * math.sin(tau * 5 * t))),
          0.12,
        ),
      ]);
      b.add(
        shape(lowpass(bow, (_) => 1400), (t) => swell(t, 1.2, 2.0, len)),
        at: at + k * 3.8,
        gain: 0.05,
        pan: 0.35,
      );
      degree = (degree + rng.nextInt(3) - 1).clamp(0, scale.length - 1);
    }
  }
  return reverb(b, size: 0.85, mix: 0.45, damp: 0.5);
});

/// Gyeongju: a low drone near the great bell's hum, winter wind in the
/// pines, and a wooden fish (moktak) knocked far off, now and then.
Buf gyeongjuNight() => loop(48, (seconds) {
  final rng = math.Random(27);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (64.0, 0.4, 24),
        (96.0, 0.2, 16),
        (128.0, 0.08, 12),
      ]),
      gain: 0.4,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 600 + 350 * math.sin(tau * t / 16),
      1.3,
    ),
    (t) => 0.3 + 0.7 * math.pow(math.sin(tau * t / 24), 2),
  );
  b.add(gain(wind, 0.18), pan: 0.3);
  // The wooden fish: a run of knocks, slowing, every 12 seconds.
  for (var at = 4.0; at < seconds - 4; at += 12) {
    var gap = 0.45;
    var t = at;
    for (var k = 0; k < 5; k++) {
      b.add(
        modal(0.3, 520, const [(1, 1, 0.05), (2.3, 0.3, 0.03)]),
        at: t,
        gain: 0.06,
        pan: -0.5,
      );
      t += gap;
      gap *= 1.25;
    }
  }
  return reverb(b, size: 0.85, mix: 0.45, damp: 0.5);
});

/// Whitechapel 1891: the fog's drone again, colder, with rain, and a
/// train passing over an arch, far off, once a loop.
Buf whitechapel1891() => loop(48, (seconds) {
  final rng = math.Random(28);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (69.3, 0.45, 24),
        (103.8, 0.26, 16),
        (164.8, 0.1, 12),
      ]),
      gain: 0.42,
    );
  final rain = shape(
    highpass(noise(seconds, rng), 2200),
    (t) => 0.5 + 0.2 * math.sin(tau * t / 12),
  );
  b.add(gain(rain, 0.05));
  final train = shape(
    lowpass(brown(8, rng), (_) => 140),
    (t) => math.sin(math.pi * t / 8),
  );
  b.add(gain(train, 0.5), at: 26, pan: 0.4);
  return reverb(b, size: 0.9, mix: 0.4, damp: 0.55);
});

/// Chongling: a cold drone, wind in the pines, and a temple bowl struck
/// now and then, far off.
Buf chonglingWinter() => loop(48, (seconds) {
  final rng = math.Random(29);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (58.27, 0.42, 24),
        (87.3, 0.22, 16),
        (174.6, 0.07, 12),
      ]),
      gain: 0.4,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 520 + 380 * math.sin(tau * t / 12),
      1.2,
    ),
    (t) => 0.25 + 0.75 * math.pow(math.sin(tau * t / 16), 2),
  );
  b.add(gain(wind, 0.16), pan: -0.2);
  // The bowl: a long, wavering ring, every 16 seconds.
  for (var at = 6.0; at < seconds - 8; at += 16) {
    b.add(
      modal(9, 392, const [(1, 1, 5), (2.71, 0.35, 3), (5.15, 0.12, 1.6)]),
      at: at,
      gain: 0.07,
      pan: 0.4,
    );
  }
  return reverb(b, size: 0.9, mix: 0.45, damp: 0.55);
});

/// Alamut: a low drone in D, wind over the rock, and a long-necked lute
/// plucked far off now and then.
Buf alamutSnow() => loop(48, (seconds) {
  final rng = math.Random(30);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (73.42, 0.42, 24),
        (110.0, 0.22, 16),
        (146.8, 0.08, 12),
      ]),
      gain: 0.4,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 650 + 420 * math.sin(tau * t / 14),
      1.4,
    ),
    (t) => 0.25 + 0.75 * math.pow(math.sin(tau * t / 18), 2),
  );
  b.add(gain(wind, 0.15), pan: 0.25);
  // The lute: a falling phrase of plucked notes every 16 seconds.
  const phrase = [293.7, 311.1, 293.7, 261.6, 220.0];
  for (var at = 5.0; at < seconds - 8; at += 16) {
    for (final (k, pitch) in phrase.indexed) {
      b.add(
        modal(2.2, pitch, const [
          (1, 1, 0.9),
          (2, 0.5, 0.5),
          (3, 0.3, 0.3),
          (4.02, 0.15, 0.2),
        ]),
        at: at + k * 0.55 + (k == phrase.length - 1 ? 0.4 : 0),
        gain: 0.05,
        pan: -0.4,
      );
    }
  }
  return reverb(b, size: 0.9, mix: 0.45, damp: 0.5);
});

/// Great Zimbabwe: a warm drone in E, dry wind in the grass, cicadas, and
/// a mbira-like figure plucked far off now and then.
Buf zimbabweDry() => loop(48, (seconds) {
  final rng = math.Random(31);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (82.41, 0.4, 24),
        (123.5, 0.2, 16),
        (164.8, 0.08, 12),
      ]),
      gain: 0.38,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 900 + 400 * math.sin(tau * t / 16),
      1.2,
    ),
    (t) => 0.3 + 0.7 * math.pow(math.sin(tau * t / 24), 2),
  );
  b.add(gain(wind, 0.12), pan: -0.25);
  final insects = shape(
    bandpass(noise(seconds, rng), (_) => 5000, 6),
    (t) => 0.4 + 0.6 * math.pow(math.sin(tau * t / 12), 2),
  );
  b.add(gain(insects, 0.04), pan: 0.4);
  // The mbira: a short interlocking figure, every 12 seconds.
  const figure = [329.6, 392.0, 329.6, 293.7, 246.9, 293.7];
  for (var at = 4.0; at < seconds - 6; at += 12) {
    for (final (k, pitch) in figure.indexed) {
      b.add(
        modal(1.4, pitch, const [
          (1, 1, 0.6),
          (3.01, 0.3, 0.2),
          (5.4, 0.1, 0.1),
        ]),
        at: at + k * 0.32,
        gain: 0.05,
        pan: k.isEven ? -0.3 : 0.3,
      );
    }
  }
  return reverb(b, size: 0.8, mix: 0.35, damp: 0.5);
});

/// Dyatlov Pass: a thin, high drone, wind over a bare ridge, and a low
/// pulse far under it.
Buf uralWind() => loop(48, (seconds) {
  final rng = math.Random(32);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (55.0, 0.36, 24),
        (220.0, 0.08, 16),
        (330.0, 0.05, 12),
      ]),
      gain: 0.4,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 1000 + 600 * math.sin(tau * t / 12),
      2.0,
    ),
    (t) => 0.2 + 0.8 * math.pow(math.sin(tau * t / 16), 2),
  );
  b.add(gain(wind, 0.18), pan: 0.3);
  // The pulse: a slow, low throb, twice a loop.
  for (var at = 8.0; at < seconds - 4; at += 24) {
    for (var k = 0; k < 4; k++) {
      b.add(
        shape(tone(1.2, (_) => 41.2), (t) => swell(t, 0.3, 0.8, 1.2)),
        at: at + k * 1.6,
        gain: 0.08,
      );
    }
  }
  return reverb(b, size: 0.9, mix: 0.4, damp: 0.6);
});

/// Honnō-ji: a low drone in D, a bamboo flute's breathy phrase in the old
/// scale far off, now and then a temple bell's long hum, cicadas faint.
Buf kyotoAsh() => loop(48, (seconds) {
  final rng = math.Random(33);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (73.42, 0.38, 24),
        (110.0, 0.16, 16),
        (146.8, 0.06, 12),
      ]),
      gain: 0.36,
    );
  // The flute: each note swelling in on a breath, a slow vibrato.
  const phrase = [(293.7, 2.4), (311.1, 1.6), (392.0, 2.8), (293.7, 3.2)];
  for (var at = 3.0; at < seconds - 12; at += 24) {
    var t0 = at;
    for (final (pitch, length) in phrase) {
      b
        ..add(
          shape(
            tone(length, (t) => pitch * (1 + 0.006 * math.sin(tau * t * 5))),
            (t) => swell(t, length * 0.4, length * 0.4, length),
          ),
          at: t0,
          gain: 0.035,
          pan: -0.2,
        )
        ..add(
          shape(
            bandpass(noise(length, rng), (_) => pitch * 2, 3),
            (t) => swell(t, length * 0.3, length * 0.5, length),
          ),
          at: t0,
          gain: 0.05,
          pan: -0.2,
        );
      t0 += length * 0.92;
    }
  }
  // The bell, far off, once a loop.
  b.add(
    modal(14, 98, const [(1, 1, 6), (1.007, 0.6, 5.5), (2.04, 0.4, 3.5)]),
    at: 20,
    gain: 0.08,
    pan: 0.3,
  );
  final insects = shape(
    bandpass(noise(seconds, rng), (_) => 5400, 6),
    (t) => 0.3 + 0.7 * math.pow(math.sin(tau * t / 16), 2),
  );
  b.add(gain(insects, 0.025), pan: 0.4);
  return reverb(b, size: 0.85, mix: 0.38, damp: 0.55);
});

/// Roanoke: a low drone in A, water lapping on the shore, and once a loop a
/// trumpet call far off across the water, unanswered.
Buf soundDawn() => loop(48, (seconds) {
  final rng = math.Random(34);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (55.0, 0.36, 24),
        (110.0, 0.14, 16),
        (164.8, 0.06, 12),
      ]),
      gain: 0.38,
    );
  final lap = shape(
    lowpass(noise(seconds, rng), (t) => 700 + 300 * math.sin(tau * t / 6)),
    (t) => 0.25 + 0.75 * math.pow(math.sin(tau * t / 5.5), 2),
  );
  b.add(gain(lap, 0.08), pan: -0.3);
  const notes = [(392.0, 0.5), (523.3, 0.5), (659.3, 1.2)];
  var at = 18.0;
  for (final (pitch, length) in notes) {
    b.add(_brass(length, pitch, rng), at: at, gain: 0.012, pan: 0.4);
    at += length + 0.1;
  }
  return reverb(b, size: 0.9, mix: 0.4, damp: 0.55);
});

/// Franklin: a cold low drone, ice creaking now and then, wind, and a
/// sonar ping far off once a loop.
Buf iceDrift() => loop(48, (seconds) {
  final rng = math.Random(35);
  final b = Buf(seconds)
    ..add(
      drone(seconds, loopSeconds: 48, const [
        (49.0, 0.38, 24),
        (98.0, 0.12, 16),
        (146.8, 0.05, 12),
      ]),
      gain: 0.38,
    );
  final wind = shape(
    bandpass(
      noise(seconds, rng),
      (t) => 800 + 400 * math.sin(tau * t / 14),
      1.6,
    ),
    (t) => 0.2 + 0.8 * math.pow(math.sin(tau * t / 20), 2),
  );
  b.add(gain(wind, 0.12), pan: -0.3);
  for (var at = 6.0; at < seconds - 4; at += 13) {
    b.add(
      shape(
        bandpass(noise(0.9, rng), (t) => 250 + 400 * t, 7),
        (t) => swell(t, 0.2, 0.4, 0.9),
      ),
      at: at,
      gain: 0.25,
      pan: 0.4,
    );
  }
  b.add(
    shape(
      tone(2.5, (_) => 1320),
      (t) => decay(t, 0.5) * swell(t, 0.005, 0.4, 2.5),
    ),
    at: 30,
    gain: 0.02,
  );
  return reverb(b, size: 0.9, mix: 0.4, damp: 0.5);
});

final music = <String, Buf Function()>{
  'chongling_winter': chonglingWinter,
  'alamut_snow': alamutSnow,
  'zimbabwe_dry': zimbabweDry,
  'ural_wind': uralWind,
  'kyoto_ash': kyotoAsh,
  'sound_dawn': soundDawn,
  'ice_drift': iceDrift,
  'whitechapel_1891': whitechapel1891,
  'gyeongju_night': gyeongjuNight,
  'bastille_dawn': bastilleDawn,
  'pompeii_ash': pompeiiAsh,
  'flannan_wind': flannanWind,
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

Buf noteSound() {
  final rng = math.Random(46);
  final b = Buf(0.5);
  for (final (at, len) in [(0.0, 0.09), (0.12, 0.14), (0.3, 0.07)]) {
    b.add(
      gain(
        shape(
          bandpass(noise(len, rng), (t) => 3500 + 1500 * math.sin(t * 80), 2),
          (t) => swell(t, 0.01, 0.03, len),
        ),
        0.8,
      ),
      at: at,
    );
  }
  return reverb(b, size: 0.1, mix: 0.08);
}

Buf secretSound() {
  final b = Buf(3.5);
  const notes = [587.3, 740.0, 880.0, 1174.7];
  for (final (i, f) in notes.indexed) {
    b.add(glassNote(f, 3), at: i * 0.12, gain: 0.3, pan: -0.3 + i * 0.2);
  }
  b.add(bell(146.8, 3.5, length: 0.6), at: 0.05, gain: 0.25);
  return reverb(b, size: 0.85, mix: 0.4);
}

Buf wipeSound() {
  final rng = math.Random(47);
  final b = Buf(0.3)
    ..add(
      gain(
        shape(
          bandpass(noise(0.25, rng), (t) => 1800 + 1200 * t, 1.2),
          (t) => math.pow(math.sin(math.pi * t / 0.25), 2).toDouble(),
        ),
        0.7,
      ),
    );
  return reverb(b, size: 0.1, mix: 0.05);
}

Buf rubSound() {
  final rng = math.Random(48);
  final b = Buf(0.3)
    ..add(
      gain(
        shape(
          highpass(noise(0.25, rng), 2500),
          (t) =>
              math.pow(math.sin(math.pi * t / 0.25), 2).toDouble() *
              (0.6 + 0.4 * math.sin(t * 190).abs()),
        ),
        0.5,
      ),
    );
  return reverb(b, size: 0.1, mix: 0.05);
}

/// The lens raised or lowered: glass catching the light.
Buf lensSound() {
  final rng = math.Random(49);
  final b = Buf(1.4)
    ..add(gain(air(rng, 0.35, rising: true), 0.5))
    ..add(glassNote(1318.5, 1.2), at: 0.05, gain: 0.25, pan: -0.2)
    ..add(glassNote(1975.5, 1.0), at: 0.13, gain: 0.15, pan: 0.2);
  return reverb(b, size: 0.5, mix: 0.3);
}

/// A small wave breaking on the landing steps.
Buf waveSound() {
  final rng = math.Random(50);
  final b = Buf(1.6)
    ..add(
      gain(
        shape(
          lowpass(noise(1.5, rng), (t) => 400 + 1800 * math.exp(-t / 0.3)),
          (t) => swell(t, 0.08, 0.6, 1.5),
        ),
        1.6,
      ),
    );
  for (var i = 0; i < 14; i++) {
    b.add(
      click(rng, centre: 2500 + rng.nextDouble() * 3000, time: 0.002),
      at: 0.15 + rng.nextDouble() * 0.9,
      gain: 0.1,
      pan: rng.nextDouble() - 0.5,
    );
  }
  return reverb(b, size: 0.5, mix: 0.25);
}

/// A great sea: the water sucked back off the rocks with a rising roar,
/// then breaking over everything, 1.2 s in.
Buf greatSeaSound() {
  final rng = math.Random(51);
  final b = Buf(3.6)
    ..add(
      gain(
        shape(
          lowpass(brown(1.3, rng), (t) => 150 + 500 * t),
          (t) => math.pow(t / 1.3, 2).toDouble(),
        ),
        1.4,
      ),
    )
    ..add(
      gain(
        shape(
          highpass(noise(1.2, rng), 1800),
          (t) => math.pow(t / 1.2, 3).toDouble() * 0.4,
        ),
        0.6,
      ),
    )
    ..add(
      gain(
        shape(
          lowpass(noise(2.4, rng), (t) => 250 + 3000 * math.exp(-t / 0.4)),
          (t) => swell(t, 0.05, 1.2, 2.4),
        ),
        2.6,
      ),
      at: 1.2,
    )
    ..add(
      gain(
        shape(
          lowpass(brown(2.4, rng), (_) => 90),
          (t) => swell(t, 0.05, 1.5, 2.4),
        ),
        1.2,
      ),
      at: 1.2,
    );
  return reverb(b, size: 0.8, mix: 0.3);
}

/// A key tried in a lock that will not turn: iron scraping on the wards,
/// a dull knock.
Buf keyTrySound() {
  final rng = math.Random(52);
  final b = Buf(0.6)
    ..add(
      gain(
        shape(
          bandpass(noise(0.3, rng), (_) => 2400, 1.2),
          (t) => math.sin(math.pi * t / 0.3),
        ),
        0.5,
      ),
    )
    ..add(
      modal(0.4, 620, const [(1, 1, 0.08), (2.7, 0.5, 0.05), (5.1, 0.3, 0.03)]),
      at: 0.28,
      gain: 0.7,
    );
  return reverb(b, size: 0.3, mix: 0.15);
}

/// The great bell of Gyeongju: a low hum and its partials, each split into
/// two tones a hair apart, so the ring swells and fades (the beat). Pairs
/// after the measured ones: 64.07/64.42 Hz (every ~3 s), 168.52/168.63 Hz
/// (every ~9 s).
Float64List greatBellRing(double seconds, {double scale = 1}) => sum([
  modal(seconds, 1, [
    (64.07, 0.8, 9 * scale),
    (64.42, 0.8, 9 * scale),
    (168.52, 0.55, 7 * scale),
    (168.63, 0.55, 7 * scale),
    (231.5, 0.3, 4 * scale),
    (232.1, 0.3, 4 * scale),
    (351.0, 0.18, 2.5 * scale),
    (477.0, 0.1, 1.6 * scale),
    (634.0, 0.06, 1.1 * scale),
  ], attack: 0.004),
]);

/// The great bell struck by its log, for the hollow puzzle: the first
/// seconds of the ring.
Buf bellStrikeSound() {
  final rng = math.Random(53);
  final b = Buf(5)
    ..add(greatBellRing(5, scale: 0.5))
    ..add(
      gain(
        shape(lowpass(noise(0.08, rng), (_) => 600), (t) => decay(t, 0.02)),
        1.2,
      ),
    );
  return reverb(b, size: 0.7, mix: 0.3, damp: 0.5);
}

/// The rim struck, its ring swelling and fading by [swell] (0–1): two
/// tones 1.4 Hz apart, the second as loud as the swell needs.
Buf beatRimSound(double swell, int seed) {
  final rng = math.Random(seed);
  final a = swell / (2 - swell);
  const seconds = 3.2;
  final b = Buf(seconds)
    ..add(
      sum([
        modal(seconds, 1, [
          (168.5, 1, 2.2),
          (168.5 + 1.4, a, 2.2),
          (352.0, 0.35, 1.2),
          (352.0 + 1.4, 0.35 * a, 1.2),
          (64.2, 0.4, 2.8),
        ], attack: 0.003),
        gain(click(rng, centre: 1800, time: 0.004), 0.6),
      ]),
    );
  return reverb(b, size: 0.5, mix: 0.25);
}

/// Molten bronze running down clay channels: a hiss and a low bubbling.
Buf pourSound() {
  final rng = math.Random(54);
  const seconds = 1.6;
  final b = Buf(seconds)
    ..add(
      gain(
        shape(
          bandpass(
            noise(seconds, rng),
            (t) => 900 + 300 * math.sin(t * 9),
            1.4,
          ),
          (t) => swell(t, 0.1, 0.6, seconds),
        ),
        0.7,
      ),
    );
  for (var i = 0; i < 14; i++) {
    b.add(
      modal(0.12, 90 + rng.nextDouble() * 80, const [(1, 1, 0.04)]),
      at: 0.1 + rng.nextDouble() * 1.2,
      gain: 0.4,
    );
  }
  return reverb(b, size: 0.3, mix: 0.15);
}

/// A metal sort dropped into the composing stick: a small bright click.
Buf typeSortSound() {
  final rng = math.Random(59);
  final b = Buf(0.3)
    ..add(
      modal(0.2, 2900, const [
        (1, 1, 0.02),
        (2.4, 0.5, 0.012),
        (4.2, 0.3, 0.008),
      ]),
      gain: 0.7,
    )
    ..add(gain(click(rng, centre: 5200, time: 0.0015), 0.8));
  return reverb(b, size: 0.15, mix: 0.1);
}

/// A gas lamp gutters: a soft hiss that dips and comes back.
Buf lampGutterSound() {
  final rng = math.Random(60);
  const seconds = 0.9;
  final b = Buf(seconds)
    ..add(
      gain(
        shape(
          bandpass(noise(seconds, rng), (_) => 1800, 0.8),
          (t) => 0.3 + 0.7 * (1 - math.sin(math.pi * t / seconds)),
        ),
        0.35,
      ),
    );
  return reverb(b, size: 0.2, mix: 0.1);
}

/// A counter clicking over a sample that reads low: a few sparse clicks.
Buf geigerSound({required int clicks, required int seed}) {
  final rng = math.Random(seed);
  final b = Buf(0.45);
  for (var i = 0; i < clicks; i++) {
    b.add(
      click(rng, centre: 3000 + rng.nextDouble() * 900, time: 0.001),
      at: rng.nextDouble() * 0.35,
      gain: 0.7,
    );
  }
  return reverb(b, size: 0.12, mix: 0.08);
}

/// A glass sample tube set into a plastic rack.
Buf sampleSound() {
  final rng = math.Random(63);
  final b = Buf(0.5)
    ..add(
      modal(0.4, 3400, const [
        (1, 1, 0.08),
        (2.2, 0.4, 0.05),
        (3.9, 0.2, 0.03),
      ]),
      gain: 0.35,
    )
    ..add(click(rng, centre: 1400, time: 0.003), gain: 0.6);
  return reverb(b, size: 0.15, mix: 0.12);
}

/// The probe's needle ticking over a mark on its dial.
Buf probeTickSound() {
  final rng = math.Random(64);
  final b = Buf(0.12)..add(click(rng, centre: 2600, time: 0.0012), gain: 0.35);
  return b;
}

/// A sheet settling into the quire as a catchword meets its page: a soft
/// paper slide and a small bright tick.
Buf catchwordSound() {
  final rng = math.Random(65);
  final b = Buf(0.45)
    ..add(
      gain(
        shape(
          bandpass(noise(0.2, rng), (_) => 2400, 1.5),
          (t) => swell(t, 0.02, 0.12, 0.2),
        ),
        0.35,
      ),
    )
    ..add(
      modal(0.3, 2640, const [(1, 1, 0.06), (2.7, 0.3, 0.03)]),
      at: 0.16,
      gain: 0.2,
    );
  return reverb(b, size: 0.2, mix: 0.15);
}

/// The reed meeting the surface in a dark tank: a soft, low plup.
Buf reedTouchSound() {
  final b = Buf(0.4)..add(plip(420), gain: 0.5);
  return reverb(b, size: 0.6, mix: 0.35);
}

/// A thin drop falling back into the tank.
Buf dripSound() {
  final b = Buf(0.3)..add(plip(1400), gain: 0.35);
  return reverb(b, size: 0.6, mix: 0.3);
}

/// A thick drop letting go of its thread: a low, heavy plop.
Buf dripSlowSound() {
  final b = Buf(0.5)
    ..add(plip(520), gain: 0.5)
    ..add(plip(360), at: 0.03, gain: 0.3);
  return reverb(b, size: 0.6, mix: 0.3);
}

/// A granite block laid in a course: a soft stone knock.
Buf blockLaySound() {
  final rng = math.Random(66);
  final b = Buf(0.4)
    ..add(modal(0.3, 240, const [(1, 1, 0.05), (2.4, 0.4, 0.03)]), gain: 0.5)
    ..add(
      shape(lowpass(noise(0.08, rng), (_) => 1200), (t) => decay(t, 0.015)),
      gain: 0.5,
    );
  return reverb(b, size: 0.25, mix: 0.15);
}

/// A thin slab turned on its edge: a light stone tick.
Buf slabTiltSound() {
  final rng = math.Random(67);
  final b = Buf(0.25)
    ..add(modal(0.2, 760, const [(1, 1, 0.03), (2.7, 0.3, 0.02)]), gain: 0.35)
    ..add(click(rng, centre: 1800, time: 0.002), gain: 0.3);
  return reverb(b, size: 0.2, mix: 0.12);
}

/// A step in a key: a stiff page turned.
Buf keyStepSound() {
  final rng = math.Random(68);
  final b = Buf(0.35)
    ..add(
      shape(
        bandpass(noise(0.18, rng), (t) => 1600 + t * 3000, 1.3),
        (t) => swell(t, 0.02, 0.1, 0.18),
      ),
      gain: 0.45,
    );
  return reverb(b, size: 0.15, mix: 0.1);
}

/// A hand or a tool pushed into a snow layer: a soft crunch.
Buf snowPushSound() {
  final rng = math.Random(69);
  final b = Buf(0.35)
    ..add(
      shape(
        bandpass(noise(0.22, rng), (t) => 1800 - t * 2000, 1.2),
        (t) => swell(t, 0.02, 0.12, 0.22),
      ),
      gain: 0.6,
    );
  return reverb(b, size: 0.15, mix: 0.1);
}

/// The shovel's blade tapped on a snow column: a dull, padded knock.
Buf shovelTapSound() {
  final rng = math.Random(70);
  final b = Buf(0.3)
    ..add(modal(0.25, 320, const [(1, 1, 0.04), (2.6, 0.3, 0.02)]), gain: 0.35)
    ..add(
      shape(lowpass(noise(0.08, rng), (_) => 800), (t) => decay(t, 0.02)),
      gain: 0.5,
    );
  return reverb(b, size: 0.2, mix: 0.1);
}

/// A snow column breaking clean and its top sliding off.
Buf columnBreakSound() {
  final rng = math.Random(71);
  final b = Buf(1.2)
    ..add(
      shape(lowpass(noise(0.1, rng), (_) => 900), (t) => decay(t, 0.03)),
      gain: 0.8,
    )
    ..add(
      shape(
        bandpass(noise(0.8, rng), (t) => 900 - t * 600, 1.2),
        (t) => swell(t, 0.05, 0.5, 0.8),
      ),
      at: 0.08,
      gain: 0.5,
    );
  return reverb(b, size: 0.4, mix: 0.2);
}

/// The enlarger's timer ticking through an exposure.
Buf enlargerSound() {
  final rng = math.Random(72);
  final b = Buf(1.1);
  for (var i = 0; i < 4; i++) {
    b.add(
      click(rng, centre: 2000, time: 0.002),
      at: 0.05 + i * 0.25,
      gain: 0.3,
    );
  }
  b.add(
    shape(tone(0.9, (_) => 100), (t) => swell(t, 0.02, 0.05, 0.9) * 0.3),
    at: 0.05,
    gain: 0.1,
  );
  return b;
}

/// A paper tag pinned to a layer of the section.
Buf strataTagSound() {
  final rng = math.Random(73);
  return Buf(0.35)
    ..add(click(rng, centre: 2600, time: 0.002), gain: 0.4)
    ..add(
      shape(
        bandpass(noise(0.2, rng), (_) => 3000, 1.4),
        (t) => swell(t, 0.01, 0.15, 0.2),
      ),
      at: 0.04,
      gain: 0.25,
    );
}

/// A find lifted from the earth: a small ceramic clink, a crumble.
Buf findLiftSound() {
  final rng = math.Random(74);
  final b = Buf(0.5)
    ..add(modal(0.4, 2300, const [(1, 1, 0.08), (2.7, 0.4, 0.04)]), gain: 0.18)
    ..add(
      shape(lowpass(noise(0.2, rng), (_) => 1200), (t) => decay(t, 0.05)),
      at: 0.02,
      gain: 0.3,
    );
  return reverb(b, size: 0.2, mix: 0.1);
}

/// A block marked on the map: a pencil's quick hatch.
Buf streetMarkSound() {
  final rng = math.Random(75);
  final b = Buf(0.45);
  for (var i = 0; i < 3; i++) {
    b.add(
      shape(
        bandpass(noise(0.08, rng), (_) => 3800, 2),
        (t) => swell(t, 0.01, 0.05, 0.08),
      ),
      at: i * 0.1,
      gain: 0.35,
    );
  }
  return b;
}

/// A tree-ring core slid one ring along: a soft wooden slide.
Buf coreSlideSound() {
  final rng = math.Random(76);
  return Buf(0.2)..add(
    shape(
      bandpass(noise(0.12, rng), (_) => 1400, 1.5),
      (t) => swell(t, 0.01, 0.08, 0.12),
    ),
    gain: 0.3,
  );
}

/// A run of rings marked: a pencil's tick and short stroke.
Buf ringMarkSound() {
  final rng = math.Random(77);
  return Buf(0.35)
    ..add(click(rng, centre: 3200, time: 0.002), gain: 0.4)
    ..add(
      shape(
        bandpass(noise(0.15, rng), (_) => 4000, 2),
        (t) => swell(t, 0.01, 0.1, 0.15),
      ),
      at: 0.04,
      gain: 0.25,
    );
}

/// The dividers walked one step: a brass point set down on paper.
Buf dividerStepSound() {
  final rng = math.Random(78);
  final b = Buf(0.3)
    ..add(modal(0.2, 2800, const [(1, 1, 0.04), (2.3, 0.5, 0.02)]), gain: 0.12)
    ..add(click(rng, centre: 2400, time: 0.0015), gain: 0.3);
  return reverb(b, size: 0.1, mix: 0.08);
}

/// A written sheet turned a quarter turn on the table.
Buf sheetTurnSound() {
  final rng = math.Random(79);
  return Buf(0.35)..add(
    shape(
      bandpass(noise(0.25, rng), (_) => 2600, 1.2),
      (t) => swell(t, 0.03, 0.15, 0.25),
    ),
    gain: 0.35,
  );
}

/// A sonar lane run: a quick ping and a sweep of hiss.
Buf laneRunSound() {
  final rng = math.Random(80);
  return Buf(0.6)
    ..add(shape(tone(0.4, (_) => 1500), (t) => decay(t, 0.08)), gain: 0.1)
    ..add(
      shape(
        bandpass(noise(0.4, rng), (t) => 1200 + 2000 * t, 2),
        (t) => swell(t, 0.05, 0.2, 0.4),
      ),
      at: 0.05,
      gain: 0.2,
    );
}

/// An echo marked: two rising pings.
Buf echoMarkSound() {
  final b = Buf(0.7)
    ..add(shape(tone(0.3, (_) => 1320), (t) => decay(t, 0.08)), gain: 0.12)
    ..add(
      shape(tone(0.35, (_) => 1760), (t) => decay(t, 0.1)),
      at: 0.16,
      gain: 0.12,
    );
  return reverb(b, size: 0.4, mix: 0.2);
}

final ui = <String, Buf Function()>{
  'geiger': () => geigerSound(clicks: 4, seed: 61),
  'geiger_hot': () => geigerSound(clicks: 26, seed: 62),
  'sample': sampleSound,
  'probe_tick': probeTickSound,
  'catchword': catchwordSound,
  'reed_touch': reedTouchSound,
  'drip': dripSound,
  'drip_slow': dripSlowSound,
  'block_lay': blockLaySound,
  'slab_tilt': slabTiltSound,
  'key_step': keyStepSound,
  'snow_push': snowPushSound,
  'shovel_tap': shovelTapSound,
  'column_break': columnBreakSound,
  'enlarger': enlargerSound,
  'strata_tag': strataTagSound,
  'find_lift': findLiftSound,
  'street_mark': streetMarkSound,
  'core_slide': coreSlideSound,
  'ring_mark': ringMarkSound,
  'divider_step': dividerStepSound,
  'sheet_turn': sheetTurnSound,
  'lane_run': laneRunSound,
  'echo_mark': echoMarkSound,
  'type_sort': typeSortSound,
  'lamp_gutter': lampGutterSound,
  'pour': pourSound,
  'bell_strike': bellStrikeSound,
  'beat_steady': () => beatRimSound(0.15, 55),
  'beat_light': () => beatRimSound(0.4, 56),
  'beat_clear': () => beatRimSound(0.62, 57),
  'beat_deep': () => beatRimSound(0.95, 58),
  'key_try': keyTrySound,
  'wave': waveSound,
  'great_sea': greatSeaSound,
  'lens': lensSound,
  'note': noteSound,
  'secret': secretSound,
  'wipe': wipeSound,
  'rub': rubSound,
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
