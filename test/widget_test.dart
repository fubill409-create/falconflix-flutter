import 'package:flutter_test/flutter_test.dart';

import 'package:falconflix/main.dart';

void main() {
  testWidgets('App boots without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const FalconFlixApp());
    await tester.pump();
    // 启动即过：底部导航存在即认为外壳渲染成功。
    expect(find.text('首页'), findsOneWidget);
  });
}
