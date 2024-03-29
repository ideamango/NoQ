// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/db/db_model/app_user.dart';
import '../lib/db/db_service/user_service.dart';
import '../lib/global_state.dart';

import '../lib/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    GlobalState gs = await (GlobalState.getGlobalState() as FutureOr<GlobalState>);
    AppUser? u = await gs.getCurrentUser();

    // Verify that our counter starts at 0.
    expect(u, null);
  });
}
