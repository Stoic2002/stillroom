import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `clockHands`: set a clock's hands to an hour, as on a Victorian
/// puzzle-box lock.
///
/// ```json
/// "config": { "time": "3:40", "start": "12:00", "step": 5, "image": "images/..." }
/// ```
/// The player drags the hands round. The minute hand moves in `step`
/// minutes (default 5), the hour hand from hour to hour. Solved when they
/// show `time` (hours 1 to 12). `start` (default 12:00) is where they begin;
/// `image` (optional) is the dial drawn under the hands.
final class ClockHandsType implements PuzzleType {
  const ClockHandsType();

  static const typeId = 'clockHands';

  @override
  String get id => typeId;

  @override
  ClockHandsConfig parseConfig(JsonReader json) {
    json.allowOnly({'time', 'start', 'step', 'image'});
    final step = json.optionalInt('step') ?? 5;
    if (step <= 0 || 60 % step != 0) {
      json.fail('must divide 60 (1, 5, 15, ...)', 'step');
    }
    (int, int) time(String key, String? value) {
      final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value ?? '');
      final hour = int.tryParse(match?.group(1) ?? '') ?? 0;
      final minute = int.tryParse(match?.group(2) ?? '') ?? -1;
      if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
        json.fail('expected a time like "3:40" (hours 1 to 12)', key);
      }
      if (minute % step != 0) {
        json.fail('minutes must be a multiple of step ($step)', key);
      }
      return (hour, minute);
    }

    final target = time('time', json.string('time'));
    final start = json.has('start')
        ? time('start', json.string('start'))
        : (12, 0);
    if (start == target) json.fail('starts solved', 'start');
    return ClockHandsConfig(
      hour: target.$1,
      minute: target.$2,
      startHour: start.$1,
      startMinute: start.$2,
      step: step,
      image: json.optionalString('image'),
    );
  }
}

final class ClockHandsConfig implements PuzzleConfig {
  const ClockHandsConfig({
    required this.hour,
    required this.minute,
    this.startHour = 12,
    this.startMinute = 0,
    this.step = 5,
    this.image,
  });

  final int hour;
  final int minute;
  final int startHour;
  final int startMinute;
  final int step;
  final String? image;

  ClockHandsState start() => ClockHandsState(this, startHour, startMinute);

  @override
  Iterable<ContentRef> get references => [
    if (image case final image?) ContentRef.image(image),
  ];
}

final class ClockHandsState {
  const ClockHandsState(this.config, this.hour, this.minute);

  final ClockHandsConfig config;

  /// 1 to 12.
  final int hour;

  /// 0 to 59, a multiple of the step.
  final int minute;

  bool get isSolved => hour == config.hour && minute == config.minute;

  /// The hour hand pointed at [position] (0 = 12 o'clock, 1 = one, … 11).
  ClockHandsState pointHour(int position) {
    final h = position % 12 == 0 ? 12 : position % 12;
    return h == hour ? this : ClockHandsState(config, h, minute);
  }

  /// The minute hand pointed at [minutes] (rounded to the step).
  ClockHandsState pointMinute(int minutes) {
    final step = config.step;
    final m = ((minutes / step).round() * step) % 60;
    return m == minute ? this : ClockHandsState(config, hour, m);
  }
}
