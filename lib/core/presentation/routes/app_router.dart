import 'package:auto_route/auto_route.dart';
import 'package:git_hub_repo_viewer/auth/presentation/authorization_page.dart';
import 'package:git_hub_repo_viewer/auth/presentation/sign_in_page.dart';
import 'package:git_hub_repo_viewer/splash/presentation/splash_page.dart';
import 'package:git_hub_repo_viewer/starred_repos/presentation/starred_repos_page.dart';

@MaterialAutoRouter(routes: [
  MaterialRoute(page: SplashPage, initial: true),
  MaterialRoute(page: SignInPage, path: "/sign-in"),
  MaterialRoute(page: StarredReposPage, path: "/starred-repos"),
  MaterialRoute(page: AuthorizationPage, path: "/auth")
], replaceInRouteName: "Page,Route")
class $AppRouter {}
