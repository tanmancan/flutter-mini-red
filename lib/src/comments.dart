import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mini_red/mini_red_api.dart';

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

  void _pareResults(List results) {
    commentTiles.clear();
    Map comments = results[1];
    List commentsChildren = comments['data']['children'];
    String commentBody;
    MarkdownBody md;

    int len = commentsChildren.length -1;
    for (int i = 0; i < len; i++) {
      Map commentData = commentsChildren[i]['data'];
      String author = commentData['author'];
      String spacer = ' ';
      String score = commentData['score'].toString() + spacer;

      commentBody = commentData['body'];
      md = new MarkdownBody(data: '$commentBody');
      commentTiles.add(
        _commentListTile(
          body: md,
          author: author,
          score: score
        )
      );
    }
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
            title: new Text('Loading')
          )
        ],
      )
      : new ListView(
        children: commentTiles,
      );
  }
}

Widget _commentListTile({MarkdownBody body, String author, String score}) {
  String spacer = ' ';

  return new ListTile(
    title: body,
    subtitle: new RichText(
      text: new TextSpan(
        text: author + spacer,
        style: new TextStyle(
          color: Colors.grey,
        ),
        children: <TextSpan>[
          new TextSpan(
              text: score,
              style: new TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}