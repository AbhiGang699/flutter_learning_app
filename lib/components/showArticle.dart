import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/components/image.dart';
import '../components/tagdropdown.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';
import 'package:intl/intl.dart';

class ViewerPage extends StatefulWidget {
  final DocumentSnapshot article;
  ViewerPage(this.article);
  @override
  State<StatefulWidget> createState() => ViewNote();
}

class ViewNote extends State<ViewerPage> {
  ZefyrController _controller;
  FocusNode _focusNode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article['title'] == null
            ? "View Note"
            : widget.article['title']),
        actions: [IconButton(icon: Icon(Icons.star), onPressed: () {})],
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ZefyrScaffold(
          child: ZefyrEditor(
            padding: EdgeInsets.all(5.0),
            controller: _controller,
            focusNode: _focusNode,
            imageDelegate: CustomImageDelegate(),
            mode: ZefyrMode.view,
          ),
        ),
      ),
    );
    // );
  }

  @override
  void initState() {
    super.initState();
    final document = NotusDocument.fromJson(jsonDecode(widget.article['body']));
    _controller = ZefyrController(document);
    _focusNode = FocusNode();
  }
}
