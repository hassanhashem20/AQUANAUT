import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IssTrackerWebView extends StatefulWidget {
  @override
  State<IssTrackerWebView> createState() => _IssTrackerWebViewState();
}

class _IssTrackerWebViewState extends State<IssTrackerWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Setup Platform-specific parameters if needed (example below for iOS/macOS)
    final params = const PlatformWebViewControllerCreationParams();

    // Create the controller from platform parameters
    _controller = WebViewController.fromPlatformCreationParams(params);

    // Configure the controller
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://isstracker.pl/en'))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            // Optionally handle progress
          },
          onPageStarted: (url) {
            // Optionally handle page started loading
          },
          onPageFinished: (url) {
            // Optionally handle page finished loading
          },
          onWebResourceError: (error) {
            // Handle loading errors
          },
          onNavigationRequest: (navigationRequest) {
            // Control navigation if needed
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISS Tracker')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
