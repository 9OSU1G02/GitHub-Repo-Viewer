import 'package:flutter/material.dart';
import 'package:git_hub_repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth/shared/providers.dart';

final initializationProvider = FutureProvider<void>((ref) async {
  final authNotifier = ref.read(authNotifierProvider.notifier);
  await authNotifier.checkAndUpdateAuthStatus();
});

class AppWidget extends ConsumerWidget {
  final _appRouter = AppRouter();
  AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initializationProvider, (previous, next) {});
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeMap(
          orElse: () {},
          authenticated: (_) {
            _appRouter.push(const StarredReposRoute());
          },
          unauthenticated: (_) {
            _appRouter.push(const SignInRoute());
          });
    });
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Repo Viewer",
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
