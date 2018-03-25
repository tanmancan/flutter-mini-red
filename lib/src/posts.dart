import 'dart:core';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mini_red/mini_red.dart';
import 'package:mini_red/mini_red_api.dart';
import 'package:mini_red/webview.dart';

class RedditPosts extends StatefulWidget {
  @override
  _RedditPostsState createState() => new _RedditPostsState();
}

class _RedditPostsState extends State<RedditPosts> {
  Map data;
  List postChildren = [];
  String after;
  String kind;
  String subReddit = 'hot/';
  String pageTitle = 'Mini Red';
  int count = 0;

  void _refreshList() {
    setState(() {
      postChildren.clear();
      count = 0;
      after = '';
    });

    fetchPosts(
        count: count,
        subReddit: subReddit,
        after: after
    ).then((results) {
      _parseResults(results);
    });
  }

  void _parseResults(Map results) {
    data = results['data'];
    after = results['data']['after'];
    kind = results['data']['kind'];

    final List children = data['children'];

    int len = children.length;
    for (int i = 0; i < len; i++) {
      postChildren.add(children[i]);
    }

    setState(() {
      count += len;
    });
  }

  void _getNewPosts(int count) {
    fetchPosts(
        count: count,
        subReddit: subReddit,
        after: after
    ).then((results) {
      _parseResults(results);
    });
  }

  @override
  void initState() {
    super.initState();

    fetchPosts(
        count: count,
        subReddit: subReddit,
        after: after
    ).then((results) {
      _parseResults(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(pageTitle),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.refresh), onPressed: _refreshList)
          ],),
      body: new _PostList(
        postChildren: postChildren,
        getNewPosts: _getNewPosts,
        count: count
      ),
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.home),
                title: new Text('Front Page'),
                onTap: () {
                  setState(() {
                    subReddit = 'hot/';
                    pageTitle = 'Mini Red';
                  });
                  _refreshList();
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                leading: new Icon(Icons.turned_in),
                title: new Text('Games'),
                onTap: () {
                  setState(() {
                    subReddit = 'r/games/';
                    pageTitle = 'r/games/';
                  });
                  _refreshList();
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                leading: new Icon(Icons.edit),
                title: new Text('Custom Subreddit'),
                onTap: () {
                  Future<Null> _askedToLead() async {
                    await showDialog(
                      context: context,
                      child: new SimpleDialog(
                        title: const Text('Custom Subreddit'),
                        children: <Widget>[
                          new Container(
                            padding: new EdgeInsets.all(16.0),
                            child: new Column(
                              children: <Widget>[
                                new TextField(
                                  onSubmitted: (String val) {
                                    setState(() {
                                      subReddit = 'r/$val/';
                                      pageTitle = 'r/$val/';
                                    });
                                    _refreshList();
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  _askedToLead();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        )
    );
  }
}

class _PostList extends StatelessWidget {
  _PostList({
    Key key,
    @required this.postChildren,
    @required this.getNewPosts,
    @required this.count
  }) : super (key: key);

  final List postChildren;
  final ValueChanged<int> getNewPosts;
  final int count;

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: postChildren.length,
      itemBuilder: (BuildContext context, int i) {
        if (i.isOdd) return new Divider();
        final index = i ~/ 2;
        if (index == (count ~/ 2) - 10) {
          getNewPosts(count);
        }

        if (index < postChildren.length ~/ 2) {
          Map postData = postChildren[index]['data'];

          return _buildPostTile(postData, context);
        }
      },
    );
  }
}

Widget _buildPostTile(Map postData, BuildContext context) {
  String subReddit = postData['subreddit_name_prefixed'];
  String author = postData['author'];
  String thumbNail = postData['thumbnail'];
  String spacer = ' ';
  String spoiler;
  String nsfw;
  String score = postData['score'].toString() + 'pts' + spacer;

  if (postData['spoiler']) {
    spoiler = 'Spoilers' + spacer;
  }

  if (postData['over_18']) {
    nsfw = 'NSFW' + spacer;
  }

  return new ListTile(
    leading: _getThumbnail(thumbNail),
    title: new Text(
      postData['title'],
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: new RichText(text: new TextSpan(
      text: author + spacer,
      style: new TextStyle(
        color: Colors.grey
      ),
      children: <TextSpan>[
        new TextSpan(
            text: score,
            style: new TextStyle(fontWeight: FontWeight.bold)),
        new TextSpan(
            text: subReddit + spacer,
            style: new TextStyle(fontWeight: FontWeight.bold)),
        new TextSpan(
            text: spoiler,
            style: new TextStyle(fontWeight: FontWeight.bold)),
        new TextSpan(
            text: nsfw,
            style: new TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red)),
      ]
    )),
    onLongPress: () {
      launchURL(
        url: postData['url'],
        title: postData['title'],
        context: context
      );
    },
    onTap: () {
      _gotoComments(postData['permalink'], postData['title'], context);
    }
  );
}

Widget _getThumbnail(thumbNail) {
  if (thumbNail.isEmpty) {
    return new Icon(Icons.collections);
  }

  switch (thumbNail) {
    case 'default':
      return new Icon(Icons.collections);
      break;
    case 'self':
      return new Icon(Icons.comment);
      break;
    case 'image':
      return new Icon(Icons.image);
      break;
    case 'nsfw':
    case 'spoiler':
      return new Icon(Icons.not_interested);
      break;
  }

  return new Image.network(
      thumbNail,
      scale: 1.0,
      repeat: ImageRepeat.noRepeat
  );
}

void _gotoComments(String permalink, String title, BuildContext context) {
  Navigator.of(context).push(
    new MaterialPageRoute(builder: (context) => new RedditComments(
      permalink: permalink,
      title: title,
    )),
  );
}