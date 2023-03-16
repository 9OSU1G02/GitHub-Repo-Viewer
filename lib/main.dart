import 'package:flutter/material.dart';
import 'package:git_hub_repo_viewer/core/presentation/app_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: AppWidget()));
}
