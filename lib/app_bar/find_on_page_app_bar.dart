import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/window_model.dart';

class FindOnPageAppBar extends StatefulWidget {
  final void Function()? hideFindOnPage;

  const FindOnPageAppBar({super.key, this.hideFindOnPage});

  @override
  State<FindOnPageAppBar> createState() => _FindOnPageAppBarState();
}

class _FindOnPageAppBarState extends State<FindOnPageAppBar> {
  final TextEditingController _finOnPageController = TextEditingController();

  OutlineInputBorder outlineBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: BorderRadius.all(
      Radius.circular(50.0),
    ),
  );

  @override
  void dispose() {
    _finOnPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final windowModel = Provider.of<WindowModel>(context, listen: false);
    final webViewModel = windowModel.getCurrentTab()?.webViewModel;
    final findInteractionController = webViewModel?.findInteractionController;

    return AppBar(
      titleSpacing: 10.0,
      title: SizedBox(
          height: 40.0,
          child: TextField(
            onSubmitted: (value) {
              findInteractionController?.findAll(find: value);
            },
            controller: _finOnPageController,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              filled: true,
              fillColor: Colors.white,
              border: outlineBorder,
              focusedBorder: outlineBorder,
              enabledBorder: outlineBorder,
              hintText: "Find on page ...",
              hintStyle: const TextStyle(color: Colors.black54, fontSize: 16.0),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16.0),
          )),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            findInteractionController?.findNext(forward: false);
          },
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            findInteractionController?.findNext(forward: true);
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            findInteractionController?.clearMatches();
            _finOnPageController.text = "";

            if (widget.hideFindOnPage != null) {
              widget.hideFindOnPage!();
            }
          },
        ),
      ],
    );
  }
}
