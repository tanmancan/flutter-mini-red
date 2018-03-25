import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

final String domain = 'https://www.reddit.com';

Future<Map> fetchPosts({
  int count,
  String subReddit,
  String after
}) async {
  final String uri = '$domain/$subReddit.json?count=$count&after=$after';
  final response = await http.get(uri);
  final json = JSON.decode(response.body);

  return json;
}

Future<List> fetchComments(String permalink) async {
  final String uri = '$domain/$permalink/.json';
  final response = await http.get(uri);
  final json = JSON.decode(response.body);

  return json;
}