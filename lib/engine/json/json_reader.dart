/// Path-aware helpers for reading content JSON with precise error messages.
library;

typedef JsonMap = Map<String, Object?>;

/// Thrown when content JSON does not match the expected shape.
final class ContentFormatException implements Exception {
  const ContentFormatException(this.source, this.path, this.message);

  /// File (or other origin) the JSON came from, e.g. `scenes/desk.json`.
  final String source;

  /// JSON path of the offending value, e.g. `$.hotspots[0].rect`.
  final String path;

  final String message;

  @override
  String toString() => 'ContentFormatException: $source $path: $message';
}

/// Wraps a decoded JSON object and reads typed fields from it.
///
/// Every failure throws [ContentFormatException] carrying the source file and
/// the JSON path of the bad value, so content authors can find typos quickly.
final class JsonReader {
  JsonReader(this.json, {required this.source, this.path = r'$'});

  factory JsonReader.root(Object? value, {required String source}) {
    if (value is! JsonMap) {
      throw ContentFormatException(source, r'$', 'expected a JSON object');
    }
    return JsonReader(value, source: source);
  }

  final JsonMap json;
  final String source;
  final String path;

  bool has(String key) => json[key] != null;

  Never fail(String message, [String? key]) {
    throw ContentFormatException(
      source,
      key == null ? path : '$path.$key',
      message,
    );
  }

  /// Rejects fields outside [allowed], catching typos such as `onTAp`.
  void allowOnly(Set<String> allowed) {
    for (final key in json.keys) {
      if (!allowed.contains(key)) fail('unknown field', key);
    }
  }

  Object value(String key) => json[key] ?? fail('required field', key);

  String string(String key) {
    final v = json[key];
    if (v is String && v.isNotEmpty) return v;
    fail(v == null ? 'required field' : 'expected a non-empty string', key);
  }

  String? optionalString(String key) => has(key) ? string(key) : null;

  bool boolean(String key) {
    final v = json[key];
    if (v is bool) return v;
    fail(v == null ? 'required field' : 'expected true or false', key);
  }

  bool? optionalBool(String key) => has(key) ? boolean(key) : null;

  int integer(String key) {
    final v = json[key];
    if (v is int) return v;
    fail(v == null ? 'required field' : 'expected an integer', key);
  }

  int? optionalInt(String key) => has(key) ? integer(key) : null;

  double number(String key) {
    final v = json[key];
    if (v is num) return v.toDouble();
    fail(v == null ? 'required field' : 'expected a number', key);
  }

  double? optionalNumber(String key) => has(key) ? number(key) : null;

  JsonReader object(String key) {
    final v = json[key];
    if (v is JsonMap) return JsonReader(v, source: source, path: '$path.$key');
    fail(v == null ? 'required field' : 'expected an object', key);
  }

  JsonReader? optionalObject(String key) => has(key) ? object(key) : null;

  List<Object?> _list(String key, {required bool optional}) {
    final v = json[key];
    if (v == null && optional) return const [];
    if (v is List<Object?>) return v;
    fail(v == null ? 'required field' : 'expected a list', key);
  }

  /// A list of objects. Absent means empty when [optional] is true.
  List<JsonReader> objects(String key, {bool optional = false}) {
    final list = _list(key, optional: optional);
    return [
      for (var i = 0; i < list.length; i++)
        switch (list[i]) {
          final JsonMap m => JsonReader(
            m,
            source: source,
            path: '$path.$key[$i]',
          ),
          _ => fail('expected an object', '$key[$i]'),
        },
    ];
  }

  List<String> strings(String key, {bool optional = false}) {
    final list = _list(key, optional: optional);
    return [
      for (var i = 0; i < list.length; i++)
        switch (list[i]) {
          final String s when s.isNotEmpty => s,
          _ => fail('expected a non-empty string', '$key[$i]'),
        },
    ];
  }

  List<double> numbers(String key, {int? length}) {
    final list = _list(key, optional: false);
    if (length != null && list.length != length) {
      fail('expected exactly $length numbers', key);
    }
    return [
      for (var i = 0; i < list.length; i++)
        switch (list[i]) {
          final num n => n.toDouble(),
          _ => fail('expected a number', '$key[$i]'),
        },
    ];
  }
}
