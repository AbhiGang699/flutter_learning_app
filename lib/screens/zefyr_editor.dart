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

class EditorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateNote();
}

class CreateNote extends State<EditorPage> {
  String _selectedtag = 'Technology';
  void setTag(String value) {
    setState(() {
      _selectedtag = value;
      print(_selectedtag);
    });
  }

  ZefyrController _controller;
  FocusNode _focusNode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Note"),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: save)],
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ZefyrScaffold(
          child: ZefyrEditor(
            padding: EdgeInsets.all(5.0),
            controller: _controller,
            focusNode: _focusNode,
            imageDelegate: CustomImageDelegate(),
          ),
        ),
      ),
    );
    // );
  }

  @override
  void initState() {
    super.initState();
    final document =
        NotusDocument.fromDelta(Delta()..insert("Insert text here\n"));
    _controller = ZefyrController(document);
    _focusNode = FocusNode();
  }

  Future<void> save() async {
    var _text = TextEditingController();
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Tag for the article'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _text,
                    decoration: InputDecoration(labelText: 'Enter title'),
                  ),
                  TagDropDownMenu(setTag),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Post'),
                onPressed: () async {
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  var result = await Firestore.instance
                      .collection('users')
                      .document(user.uid)
                      .get();
                  print(result.data);
                  String id = DateTime.now().toString() + user.uid;
                  await Firestore.instance
                      .collection('articles')
                      .document(id)
                      .setData({
                    'title': _text.text,
                    'user': user.uid,
                    'body': jsonEncode(_controller.document),
                    'tag': _selectedtag,
                    'username': result.data['username'],
                    'date': DateFormat.yMMMMd('en_US')
                        .format(DateTime.now())
                        .toString(),
                    'id': id,
                    'caption':
                        _controller.document.toPlainText().substring(0, 20) +
                            '...'
                  });
                  print(jsonEncode(_controller.document.toPlainText()));
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Get Back to Editing'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
