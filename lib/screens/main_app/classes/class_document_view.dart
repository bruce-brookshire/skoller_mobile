import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ClassDocumentView extends StatefulWidget {
  final ClassDocument doc;

  ClassDocumentView(this.doc);

  @override
  State createState() => _ClassDocumentState();
}

class _ClassDocumentState extends State<ClassDocumentView> {
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: widget.doc.name,
      children: [
        Expanded(
          child: Stack(
            children: [
              WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: widget.doc.path,
                onPageFinished: (url) => setState(() => loading = false),
              ),
              if (loading)
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(),
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}
