import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void launchURL({
    @required
    String url,
    @required
    String title,
    @required
    BuildContext context
  }) async {
  if (await canLaunch(url)) {
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => new WebviewScaffold(
        url: url,
        withZoom: true,
        clearCache: true,
        clearCookies: true,
        appBar: new AppBar(
          title: new Text(title),
        ),
      ))
    );
  } else {
    throw 'Could not launch $url';
  }
}