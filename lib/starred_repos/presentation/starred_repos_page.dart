import 'package:flutter/material.dart';
import 'package:git_hub_repo_viewer/auth/shared/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StarredReposPage extends ConsumerWidget {
  const StarredReposPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () {
          ref.read(authNotifierProvider.notifier).signOut();
        }, child: const Text("Sign out"))
      )
    );
  }
}
