import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const WebViewPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  ValueNotifier<bool> _isLoadingPage = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoadingPage.value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: widget.title),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onPageFinished: (finish) {
                      _isLoadingPage.value = false;
                    },
                  ),
                )
                ..loadRequest(
                  Uri.parse(widget.url),
                ),
            ),
            ValueListenableBuilder<bool>(
                valueListenable: _isLoadingPage,
                builder: (_, loader, __) {
                  return Visibility(
                    visible: loader,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
