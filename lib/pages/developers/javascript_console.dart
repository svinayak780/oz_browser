import 'package:flutter/material.dart';
import 'package:oz_browser/javascript_console_result.dart';
import 'package:oz_browser/models/webview_model.dart';
import 'package:provider/provider.dart';

import '../../models/window_model.dart';

class JavaScriptConsole extends StatefulWidget {
  const JavaScriptConsole({super.key});

  @override
  State<JavaScriptConsole> createState() => _JavaScriptConsoleState();
}

class _JavaScriptConsoleState extends State<JavaScriptConsole> {
  final TextEditingController _customJavaScriptController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int currentJavaScriptHistory = 0;

  @override
  void dispose() {
    _customJavaScriptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildJavaScriptConsole();
  }

  Widget _buildJavaScriptConsole() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Selector<WebViewModel, List<Widget>>(
            selector: (context, webViewModel) =>
                webViewModel.javaScriptConsoleResults,
            builder: (context, javaScriptConsoleResults, child) {
              return ListView.builder(
                controller: _scrollController,
                itemCount: javaScriptConsoleResults.length,
                itemBuilder: (context, index) {
                  return javaScriptConsoleResults[index];
                },
              );
            },
          ),
        ),
        const Divider(),
        SizedBox(
          height: 75.0,
          child: Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  expands: true,
                  onSubmitted: (value) {
                    evaluateJavaScript(value);
                  },
                  controller: _customJavaScriptController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: "document.querySelector('body') ...",
                      prefixIcon:
                          Icon(Icons.keyboard_arrow_right, color: Colors.blue),
                      border: InputBorder.none),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  evaluateJavaScript(_customJavaScriptController.text);
                },
              ),
              Selector<WebViewModel, List<String>>(
                  selector: (context, webViewModel) =>
                      webViewModel.javaScriptConsoleHistory,
                  builder: (context, javaScriptConsoleHistory, child) {
                    currentJavaScriptHistory = javaScriptConsoleHistory.length;

                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: 35.0,
                          child: IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up),
                            onPressed: () {
                              currentJavaScriptHistory--;
                              if (currentJavaScriptHistory < 0) {
                                currentJavaScriptHistory = 0;
                              } else {
                                _customJavaScriptController.text =
                                    javaScriptConsoleHistory[
                                        currentJavaScriptHistory];
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 35.0,
                          child: IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onPressed: () {
                              if (currentJavaScriptHistory + 1 >=
                                  javaScriptConsoleHistory.length) {
                                currentJavaScriptHistory =
                                    javaScriptConsoleHistory.length;
                                _customJavaScriptController.text = "";
                              } else {
                                currentJavaScriptHistory++;
                                _customJavaScriptController.text =
                                    javaScriptConsoleHistory[
                                        currentJavaScriptHistory];
                              }
                            },
                          ),
                        )
                      ],
                    );
                  }),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  final windowModel = Provider.of<WindowModel>(context, listen: false);
                  var webViewModel = windowModel.getCurrentTab()?.webViewModel;
                  if (webViewModel != null) {
                    webViewModel.setJavaScriptConsoleResults([]);

                    var currentWebViewModel =
                        Provider.of<WebViewModel>(context, listen: false);
                    currentWebViewModel.updateWithValue(webViewModel);
                  }
                },
              )
            ],
          ),
        )
      ],
    );
  }

  void evaluateJavaScript(String source) async {
    final windowModel = Provider.of<WindowModel>(context, listen: false);
    final webViewModel = windowModel.getCurrentTab()?.webViewModel;

    if (webViewModel != null) {
      var currentWebViewModel =
          Provider.of<WebViewModel>(context, listen: false);

      if (source.isNotEmpty &&
          (webViewModel.javaScriptConsoleHistory.isEmpty ||
              (webViewModel.javaScriptConsoleHistory.isNotEmpty &&
                  webViewModel.javaScriptConsoleHistory.last != source))) {
        webViewModel.addJavaScriptConsoleHistory(source);
        currentWebViewModel.updateWithValue(webViewModel);
      }

      var result = await webViewModel.webViewController
          ?.evaluateJavascript(source: source);

      webViewModel.addJavaScriptConsoleResults(
          JavaScriptConsoleResult(data: result.toString()));
      currentWebViewModel.updateWithValue(webViewModel);

      setState(() {
        Future.delayed(const Duration(milliseconds: 100), () async {
          await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.ease);
          // must be repeated, otherwise it won't scroll to the bottom sometimes
          await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.ease);
        });
      });
    }
  }
}
