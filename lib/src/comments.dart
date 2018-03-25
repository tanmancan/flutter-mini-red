import 'dart:core';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mini_red/mini_red_api.dart';
import 'package:mini_red/webview.dart';

class RedditComments extends StatefulWidget {
  RedditComments({
    Key key,
    this.permalink: '',
    this.title: 'Loading...',
  }) : super (key: key);

  final String permalink;
  final String title;

  @override
  _RedditCommentsState createState() => new _RedditCommentsState();
}

class _RedditCommentsState extends State<RedditComments> {
  bool loading = true;
  List<Widget> commentTiles = [];

  Future _buildCommentList(List commentsChildren) async {
    int len = commentsChildren.length - 1;
    for (int i = 0; i < len; i++) {
      Map commentData = commentsChildren[i]['data'];
      String author = commentData['author'];
      String spacer = ' ';
      String score = commentData['score'].toString() + spacer;
      int depth = commentData['depth'];
      double depthPadding = depth * 16.0;

      var _launchURLWrapper = (String url) {
        String title = widget.title;
        BuildContext ctx = context;
        launchURL(url: url, title: title, context: ctx);
      };

      String commentBody = commentData['body'];
      MarkdownBody md = new MarkdownBody(
          data: '$commentBody',
          onTapLink: _launchURLWrapper
      );
      commentTiles.add(
          _commentListTile(
              body: md,
              author: author,
              score: score,
              depthPadding: depthPadding
          )
      );

      if (commentData['replies'] != '') {
        List replies = commentData['replies']['data']['children'];
        await _buildCommentList(replies);
      }
    }
  }

  void _pareResults(List results) async {
    commentTiles.clear();
    Map comments = results[1];
    List commentsChildren = comments['data']['children'];

    await _buildCommentList(commentsChildren);

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    fetchComments(widget.permalink)
      .then((results) {
        _pareResults(results);
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(widget.title)),
      body: new _CommentList(
        loading: loading,
        permalink: widget.permalink,
        commentTiles: commentTiles,
      )
    );
  }
}

class _CommentList extends StatelessWidget {
  _CommentList({
    Key key,
    @required this.loading,
    @required this.permalink,
    @required this.commentTiles,
  }) : super (key: key);

  final bool loading;
  final String permalink;
  final List<Widget> commentTiles;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return loading
      ? new ListView(
        children: [
          new ListTile(
              title: new Text('Loading...')
          )
        ],
      )
      : new ListView(
        children: commentTiles,
      );
  }
}

Widget _commentListTile({
  MarkdownBody body,
  String author,
  String score,
  double depthPadding: 0.0
}) {
  String spacer = ' ';

  Widget tile = new ListTile(
    subtitle: body,
    title: new RichText(
      text: new TextSpan(
        text: author + spacer,
        style: new TextStyle(
          color: Colors.grey,
        ),
        children: <TextSpan>[
          new TextSpan(
              text: score + 'pts ',
              style: new TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );

  Container container = new Container(
    padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 8.0
    ),
    decoration: new BoxDecoration(
        border: new Border(
            left: (depthPadding == 0.0)
                ? BorderSide.none
                : new BorderSide(
                width: depthPadding,
                color: Colors.black26
            ),
            bottom: new BorderSide(
                width: 1.0,
                color: Colors.black12
            )
        )
    ),
    child: new Align(
      alignment: Alignment.topLeft,
      heightFactor: 1.2,
      child: tile,
    ),
  );

  return container;
}