import 'dart:async';
import 'package:flutter/material.dart';
import '../firebase.dart' as firebase;
import '../cards/creatorCards.dart';

/// This [Dialog] loads a list of objects from a
/// category in Firebase, with the [initialObjects]
/// indicating which objects are currently selected.
/// 
/// [Navigator.pop]s with the newly selected data.
class SelectorDialog extends StatefulWidget {
  /// Opens a dialog to select an object from a category
  const SelectorDialog({
    Key key,
    this.category,
    this.initialObjects,
  }) : super(key: key);

  /// The category in Firebase to select from
  final String category;
  /// The object to show as currently selected
  final List<String> initialObjects;

  @override
  _SelectorDialogState createState() => new _SelectorDialogState();
}

class _SelectorDialogState extends State<SelectorDialog> {
  List<ListTile> objectList = <ListTile>[];
  List<Map<String, dynamic>> objList = <Map<String, dynamic>>[];

  @override
  void initState(){
    super.initState();
    firebase.getCategory(widget.category).then((Map<String, Map<String, dynamic>> objects){
      setState((){
        objects.forEach((String id, Map<String, dynamic> data){
          Map<String, dynamic> obj = new Map<String, dynamic>.from(data);
          objList.add(obj);
        });
      });
    });
  }

  Future<Null> _onAdd() async {
    dynamic res = await showCreatorCard(context, widget.category);
    // If the Creator Card popped with data,
    if (res != null){
      // Pop that data further up the chain.
      Navigator.pop(context, res);
    }
  }

  void _onCancel(){
    Navigator.pop(context);
  }

  Widget build(BuildContext context){
    final Widget actions = new ButtonTheme.bar(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: const Text('Cancel'),
            onPressed: _onCancel,
          ),
          new FlatButton(
            child: const Text("Add new"),
            onPressed: _onAdd,
          )
        ]
      )
    );
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new Column(
          children: <Widget>[
            new ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index){
                return new ListTile(
                  title: new Text(objList[index]["name"]),
                  onTap: (){
                    Navigator.pop(context, objList[index]);
                  },
                  selected: (widget.initialObjects.contains(objList[index]["id"]))
                );
              },
            ),
            actions,
          ],
        )
      )
    );
  }
}