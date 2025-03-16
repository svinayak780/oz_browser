import 'package:flutter/material.dart';
import 'package:oz_browser/app_bar/desktop_app_bar.dart';
import 'package:oz_browser/app_bar/find_on_page_app_bar.dart';
import 'package:oz_browser/app_bar/webview_tab_app_bar.dart';
import 'package:oz_browser/util.dart';

class BrowserAppBar extends StatefulWidget implements PreferredSizeWidget {
  BrowserAppBar({super.key})
      : preferredSize =
            Size.fromHeight(Util.isMobile() ? kToolbarHeight : 90.0);

  @override
  State<BrowserAppBar> createState() => _BrowserAppBarState();

  @override
  final Size preferredSize;
}

class _BrowserAppBarState extends State<BrowserAppBar> {
  bool _isFindingOnPage = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    if (Util.isDesktop()) {
      children.add(const DesktopAppBar());
    }

    children.add(_isFindingOnPage
        ? FindOnPageAppBar(
            hideFindOnPage: () {
              setState(() {
                _isFindingOnPage = false;
              });
            },
          )
        : WebViewTabAppBar(
            showFindOnPage: () {
              setState(() {
                _isFindingOnPage = true;
              });
            },
          ));

    return Column(
      children: children,
    );
  }
}
