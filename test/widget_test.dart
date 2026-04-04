import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack/main.dart';

void main() {
  testWidgets('deve exibir a tela inicial de login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudyTrackApp());

    expect(find.text('StudyTrack'), findsWidgets);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Esqueceu a senha?'), findsOneWidget);
  });
}
