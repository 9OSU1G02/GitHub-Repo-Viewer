// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:git_hub_repo_viewer/auth/infrastructure/github_authenticator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage({
    Key? key,
    required this.authorizationUrl,
    required this.onAuthorizationCodeRedirectAttempt,
  }) : super(key: key);
  final Uri authorizationUrl;
  final void Function(Uri redirectUrl) onAuthorizationCodeRedirectAttempt;
  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  @override
  Widget build(BuildContext context) {
    WebViewCookieManager().clearCookies();
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..clearCache()
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url
                .startsWith(GithubAuthenticator.redirectUrl.toString())) {
              widget.onAuthorizationCodeRedirectAttempt(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          widget.authorizationUrl.toString(),
        ),
      );
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
