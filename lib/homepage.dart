import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'addtask.dart';
import 'edittask.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase CRUD")),
      floatingActionButton: new FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (BuildContext context) => new AddTask()
            )
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 40,
        color: Colors.blue,
        child: ButtonBar(children: <Widget>[],),
        shape: CircularNotchedRectangle(),
      ),

      body: StreamBuilder(
        stream:Firestore.instance
        .collection('task')
        .where("email", isEqualTo: 'naufalhafizi@gmail.com')
        .snapshots(),

        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return new Container(child: Center(
              child: CircularProgressIndicator()
            ),);
          } else {
            return new TaskList(document: snapshot.data.documents,);
          }
          
        },
      ),
    );
  }
}

class TaskList extends StatelessWidget {

  final List<DocumentSnapshot> document;
  TaskList({this.document});

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: document.length,
      itemBuilder: (BuildContext context, int i){
        String title = document[i].data['title'].toString();
        String note = document[i].data['note'].toString();
        DateTime _date = document[i].data['duedate'].toDate();
        String duedate = "${_date.day}/${_date.month}/${_date.year}";

        return Dismissible(
          key: new Key(document[i].documentID),
          onDismissed: (direction) {
            Firestore.instance.runTransaction((transaction) async {
              DocumentSnapshot snapshot =
              await transaction.get(document[i].reference);
              await transaction.delete(snapshot.reference);
            });

            Scaffold.of(context).showSnackBar(
              new SnackBar(content: new Text("Data Deleted"))
            );
          },
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8.0, right: 16, bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(title,style: new TextStyle(fontSize: 20, letterSpacing: 1.0),),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Icon(Icons.date_range, color: Colors.blue,),
                            ),
                            Text(duedate.toString(),style: new TextStyle(fontSize: 18, letterSpacing: 1.0),),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Icon(Icons.note, color: Colors.blue,),
                            ),
                            Expanded(child: Text(note,style: new TextStyle(fontSize: 18, letterSpacing: 1.0),)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  new IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue,),
                    onPressed: (){
                      Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new EditData(
                          title: title,
                          note: note,
                          duedate: document[i].data['duedate'].toDate(),
                          index: document[i].reference,
                        )
                      ));
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}