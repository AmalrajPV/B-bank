import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyWebView extends StatefulWidget {
  final String url;

  const MyWebView({super.key, required this.url});

  @override
  MyWebViewState createState() => MyWebViewState();
}

class MyWebViewState extends State<MyWebView> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _showErrorPage = false;
  // String? _errorMessage;

  Future<void> _reloadWebView() async {
    await _webViewController?.reload();
  }

  Future<bool> _onWillPop() async {
    final canGoBack = await _webViewController?.canGoBack();
    if (canGoBack == true) {
      _webViewController?.goBack();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _reloadWebView,
          child: Stack(
            children: [
              Visibility(
                visible: !_showErrorPage,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    setState(() {
                      _showErrorPage = true;
                      // _errorMessage = message;
                    });
                  },
                ),
              ),
              Visibility(
                visible: _showErrorPage,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.signal_wifi_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Network Error',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Unable to connect to the internet.\nPlease check your network settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      // const SizedBox(height: 10),
                      // Text(
                      //   _errorMessage ?? "",
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     color: Colors.grey[600],
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showErrorPage = false;
                            _isLoading = true;
                          });
                          _webViewController?.loadUrl(
                              urlRequest:
                                  URLRequest(url: Uri.parse(widget.url)));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _isLoading && !_showErrorPage,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
