import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/screens/workerForm.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';

class WorkerList extends StatefulWidget {
  WorkerList({Key key}) : super(key: key);

  @override
  WorkerListState createState() => WorkerListState();
}

class WorkerListState extends State<WorkerList> {
  StreamSubscription<QuerySnapshot> currentSubscription;
  bool isLoading = true;
  List<WorkerModel> workers;

  WorkerListState() {
    // AuthService().currentUser().then((User user) {
    //   if (user != null) {
    //     currentSubscription = WorkerService().loadAllWorkers().listen(updateWorkers);
    //   }
    // });

    currentSubscription =
        WorkerService().loadAllWorkers().listen(updateWorkers);
  }

  @override
  void dispose() {
    print("dispose");
    currentSubscription?.cancel();
    super.dispose();
  }

  void updateWorkers(QuerySnapshot snapshot) {
    print("updateWorkers");
    setState(() {
      workers = WorkerService().getSnapshotWorkers(snapshot);
      isLoading = false;
    });
  }

  Widget _newWorkerButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WorkerFromPage(flag: 'N', workerModel: WorkerModel.empty())),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 4),
              child: Icon(Icons.add, color: Colors.black, size: 15),
            ),
            Text('Add New Worker',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 18),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: new Text('Worker List',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        backgroundColor: Colors.transparent,
        actions: [_newWorkerButton()],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1280),
          child: isLoading
              ? CircularProgressIndicator()
              : workers.isNotEmpty
                  ? WorkerListView(workers: workers)
                  : EmptyListView(child: Text('No Workers Found !')),
        ),
      ),
    );
  }
}

class WorkerListView extends StatelessWidget {
  final List<WorkerModel> _workers;

  WorkerListView({
    @required List<WorkerModel> workers,
  }) : _workers = workers;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          children: _workers.map((w) => WorkerCard(worker: w)).toList()),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final WorkerModel worker;
  WorkerCard({this.worker});

  _displaySnackBar(
      BuildContext context, String type, String title, String text) {
    if (type == 'E') {
      Flushbar(
        titleText: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Colors.red[600]),
        ),
        message: text,
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.red[300],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    } else {
      Flushbar(
        titleText: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Colors.blue[600]),
        ),
        message: text,
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.blue[300],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('worker fname::' + worker.toString());
    return new Card(
      margin: EdgeInsets.all(10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: new Row(
        children: <Widget>[
          Container(
            width: 130,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSh3mYv3dNJM69SIHUkZwTerLfncnUN8dXpDw&usqp=CAU'),
              fit: BoxFit.cover,
            )),
          ),
          Flexible(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      Text(
                        worker.fname + ' ' + worker.lname,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ]),
                    Row(
                      children: <Widget>[
                        Text("Work Start Date : "),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          worker.workStartDate,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("Work End Date : "),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          worker.workEndDate,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(worker.workingStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            )),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Text("Edit Worker"),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text("Delete Worker"),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: Text("Payment"),
                            ),
                            PopupMenuItem(
                              value: 4,
                              child: Text("Attendance"),
                            ),
                            PopupMenuItem(
                              value: 5,
                              child: Text("History"),
                            ),
                          ],
                          onCanceled: () {
                            print("You have canceled the menu.");
                          },
                          onSelected: (value) {
                            print("value:$value");
                            if (value == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WorkerFromPage(
                                        flag: 'M', workerModel: worker)),
                              );
                            } else if (value == 2) {
                              CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.confirm,
                                  text: "Do you want to delete worker ? ",
                                  confirmBtnText: "Yes",
                                  cancelBtnText: "No",
                                  confirmBtnColor: Colors.red,
                                  onConfirmBtnTap: () {
                                    Navigator.pop(context);
                                    Map result =
                                        WorkerService().deleteWorker(worker.id);
                                    if (result['status'] == 'success') {
                                      _displaySnackBar(context, 'S', 'Success',
                                          result['msg']);
                                    } else {
                                      _displaySnackBar(context, 'E', 'Failed',
                                          result['msg']);
                                    }
                                  });
                            } else if (value == 3) {}
                          },
                        ),
                      ],
                    ),
                  ])))
        ],
      ),
    );
  }
}

class EmptyListView extends StatelessWidget {
  final Widget child;
  EmptyListView({this.child});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[child],
      ),
    );
  }
}
