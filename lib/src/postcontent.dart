import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:mini_red/mini_red.dart';

enum PostType {
  IMAGE,
  GIF,
  VIDEO,
  WEB,
  SELF
}

class PostContent extends StatefulWidget {
  PostContent({
    Key key,
    this.postData,
    this.context
  }) : super (key: key);

  final Map postData;
  final BuildContext context;

  @override
  PostContentState createState() => new PostContentState();
}

class PostContentState extends State<PostContent> {
  VideoPlayerController _controller;
  bool _isPlaying = false;
  Widget contentBody;

  @override
  void initState() {
    super.initState();
    contentBody = new Text('Loading');
    _controller = new VideoPlayerController(
      'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4',
    )
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..initialize();
  }

  @override
  Widget build(BuildContext context) {
    Map postData = widget.postData;
    PostType type = _getPostType(postData);
    print(postData['domain']);
    print(type);
    // @TODO: do this better
    switch (type) {
      case PostType.IMAGE:
        Map source = postData['preview']['images'][0]['source'];
        contentBody = new Image.network(
          source['url'],
          width: source['width'] * 1.0,
          height: source['height'] * 1.0,
        );
        break;
      case PostType.GIF:
        Map source = postData['preview']['images'][0]['variants']['gif']['source'];
        contentBody = new Image.network(
          source['url'],
          width: source['width'] * 1.0,
          height: source['height'] * 1.0,
        );
        break;
      case PostType.VIDEO:
        contentBody = new Center(
          child: new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new AspectRatio(
              aspectRatio: 1280 / 720,
              child: new VideoPlayer(_controller),
            ),
          ),
        );
        break;
      case PostType.WEB:
        return new WebviewScaffold(
          url: postData['url'],
          withZoom: true,
          clearCache: true,
          clearCookies: true,
          appBar: new AppBar(
            title: new Text(postData['title']),
          ),
        );
        break;
      case PostType.SELF:
        return new RedditComments(
            permalink: postData['permalink'],
            title: postData['title']
        );
        break;
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(postData['title']),
      ),
      body: contentBody,
    );
  }
}

PostType _getPostType(postData) {
  if (postData['is_self'] == true) {
    return PostType.SELF;
  }

  switch (postData['domain']) {
    case 'i.redd.it':
    case 'i.imgur.com':
      if (postData['preview'].containsKey('reddit_video_preview')) {
        if (postData['preview']['reddit_video_preview']['is_gif'] == true) {
          return PostType.GIF;
        }
        return PostType.VIDEO;
      }
      return PostType.IMAGE;
      break;
    case 'v.redd.it':
      return PostType.VIDEO;
      break;
    case 'reddit.com':
      return PostType.SELF;
      break;
  }

  return PostType.WEB;
}