import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/core/widgets/marked_text.dart';

void main() {
  testWidgets('marked words read as their label and can be tapped', (
    tester,
  ) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkedText(
            'Found in [[bucks_row]], at dawn.',
            labelOf: (id) => "Buck's Row",
            isNoted: (id) => false,
            onWord: tapped.add,
          ),
        ),
      ),
    );
    expect(find.text("Found in Buck's Row, at dawn."), findsOneWidget);

    final rich = tester.widget<RichText>(find.byType(RichText));
    TextSpan? word;
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text == "Buck's Row") word = span;
      return word == null;
    });
    expect(word!.style!.decorationStyle, TextDecorationStyle.dotted);
    (word!.recognizer! as TapGestureRecognizer).onTap!();
    expect(tapped, ['bucks_row']);
  });
}
