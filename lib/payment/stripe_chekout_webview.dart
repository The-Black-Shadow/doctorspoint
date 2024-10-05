import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeCheckoutWebView extends StatefulWidget {
  final String url;

  const StripeCheckoutWebView({super.key, required this.url});

  @override
  _StripeCheckoutWebViewState createState() => _StripeCheckoutWebViewState();
}

class _StripeCheckoutWebViewState extends State<StripeCheckoutWebView> {
  late final WebViewController
      _controller; // Use late final to ensure initialization
  // Timer variable to keep track of the periodic URL check
  Timer? _urlCheckTimer;

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    _initializeController();

    // Start listening for URL changes
    _startListeningForUrlChanges();
  }

  Future<void> _initializeController() async {
    final WebViewController controller = WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));

    // Assign the controller after initialization
    setState(() {
      _controller = controller;
    });
  }

  void _startListeningForUrlChanges() {
    _urlCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final currentUrl = await _controller.currentUrl();
      print('Current URL: $currentUrl');

      // Check if the current URL is not null and contains the success URL
      if (currentUrl != null &&
          currentUrl.contains('https://buy.stripe.com/c/pay/')) {
        // Stop the timer
        timer.cancel();

        // Pop the screen with a success result
        Navigator.pop(context, 'success');
      } else if (currentUrl != null) {
        print('URL does not match: $currentUrl');
      }
    });
  }

  @override
  void dispose() {
    // Dispose the timer if it exists
    _urlCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Checkout'),
      ),
      body: _controller != null // Ensure controller is initialized
          ? WebViewWidget(controller: _controller)
          : const Center(
              child:
                  CircularProgressIndicator()), // Show a loading indicator until WebView is ready
    );
  }
}
