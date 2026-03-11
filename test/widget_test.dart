import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_task_planner/main.dart';

void main() {
  testWidgets('App starts with TaskTrackerApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TaskTrackerApp()),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
