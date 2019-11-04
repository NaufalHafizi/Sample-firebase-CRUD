import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditData extends StatefulWidget {
  final String title;
  final String note;
  final DateTime duedate;
  final index;

  EditData({this.title, this.note, this.duedate, this.index});

  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {

  TextEditingController controllerTitle;
  TextEditingController controllerNote;

  DateTime _dueDate;
  String _dateText = '';

  String newTask;
  String note;

  Future<Null> _selectDueDate(BuildContext context) async{
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2019),
      lastDate: DateTime(2025),
    );
    if(picked != null) {
      setState(() {
       _dueDate = picked; 
       _dateText = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _editTask() {
    Firestore.instance.runTransaction((Transaction transaction) async{
      DocumentSnapshot snapshot =
      await transaction.get(widget.index);
      await transaction.update(snapshot.reference, {
        "title" : newTask,
        "note" : note,
        "duedate" : _dueDate
      });
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    _dueDate = widget.duedate;
    _dateText = '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}';

    newTask = widget.title;
    note = widget.note;

    controllerTitle = new TextEditingController(text: widget.title);
    controllerNote = new TextEditingController(text: widget.note);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controllerTitle,
                onChanged: (String str){
                  setState(() {
                   newTask = str;
                  });
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.dashboard),
                  border: InputBorder.none,
                  hintText: "New Task"
                ),
                style: TextStyle(fontSize: 22.0, color: Colors.black),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(Icons.date_range),
                ),
                Expanded(child: Text("Due Date", style: TextStyle(fontSize: 22.0, color: Colors.black54),)),
                FlatButton(
                  onPressed: () => _selectDueDate(context),
                  child: Text(_dateText, style: TextStyle(fontSize: 22.0, color: Colors.black54),)
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controllerNote,
                onChanged: (String str){
                  setState(() {
                   note = str;
                  });
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.note),
                  border: InputBorder.none,
                  hintText: "Note"
                ),
                style: TextStyle(fontSize: 22.0, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check, size: 40,),
                    onPressed: () {
                      _editTask();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 40,),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}