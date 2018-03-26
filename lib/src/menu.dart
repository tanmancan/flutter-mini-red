import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget buildMenu({
  List<Widget> drawerItems,
}) {
  return new Drawer(
    child: new ListView(
      children: drawerItems,
    ),
  );
}

Widget buildMenuItem({
  IconData menuIcon: Icons.home,
  String menuTitle: 'Needs a Title',
  @required onTap
}) {
  return new ListTile(
    leading: new Icon(menuIcon),
    title: new Text(menuTitle),
    onTap: onTap,
  );
}

addMenuItem(List<Widget> itemList, Set itemSet) =>
        (Widget item, String itemKey) {
      if (!itemSet.contains(itemKey)) {
        itemList.add(item);
      }
      itemSet.add(itemKey);
    };