import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moduler_flutter_app/modules/login/services/auth.dart';
import 'package:moduler_flutter_app/modules/site/models/siteModel.dart';
import 'package:moduler_flutter_app/modules/site/screens/siteForm.dart';
import 'package:moduler_flutter_app/modules/site/screens/siteWorkersList.dart';
import 'package:moduler_flutter_app/modules/site/services/siteService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/screens/workerForm.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';

class AssignWorker extends StatefulWidget {
  final SiteModel siteModel;

  AssignWorker({@required this.siteModel});

  @override
  AssignWorkerState createState() => AssignWorkerState();
}

class AssignWorkerState extends State<AssignWorker> {
  StreamSubscription<QuerySnapshot> currentSubscription;
  bool isLoading = true;
  List<WorkerModel> freeWorkers = <WorkerModel>[];

  AssignWorkerState() {
    // AuthService().currentUser().then((User user) {
    //   if (user != null) {
    //     currentSubscription = SiteService().loadAllSites().listen(updateSites);
    //   }
    // });

    currentSubscription = WorkerService().loadFreeWorkers().listen(updateSites);
  }

  @override
  void dispose() {
    currentSubscription?.cancel();
    super.dispose();
  }

  void updateSites(QuerySnapshot snapshot) {
    setState(() {
      freeWorkers = WorkerService().getSnapshotData(snapshot);
      isLoading = false;
    });
  }

  Widget _newSiteButton() {
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
              child: Icon(Icons.add),
            ),
            Text('Add Worker', style: TextStyle(fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: new Text('Available Workers List',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        actions: [_newSiteButton()],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1280),
          child: isLoading
              ? CircularProgressIndicator()
              : freeWorkers.isNotEmpty
                  ? AssignWorkerView(
                      workers: freeWorkers, siteModel: widget.siteModel)
                  : EmptyListView(child: Text('No Free Workers Found !')),
        ),
      ),
    );
  }
}

class AssignWorkerView extends StatelessWidget {
  final SiteModel siteModel;
  final List<WorkerModel> _workers;

  AssignWorkerView(
      {@required List<WorkerModel> workers, @required this.siteModel})
      : _workers = workers;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          children: _workers
              .map((worker) =>
                  AssignWorkerCard(worker: worker, siteModel: siteModel))
              .toList()),
    );
  }
}

class AssignWorkerCard extends StatelessWidget {
  final WorkerModel worker;
  final SiteModel siteModel;
  AssignWorkerCard({this.worker, this.siteModel});

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
    return new Card(
      margin: EdgeInsets.all(10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: new Row(
        children: <Widget>[
          Container(
            width: 80,
            height: 90,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: worker.photoUrl == null
                  ? AssetImage('assets/images/placeholder-image.png')
                  : NetworkImage(worker.photoUrl),
              fit: BoxFit.cover,
            )),
          ),
          Flexible(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Text(worker.workingStatus,
                        //     style: TextStyle(
                        //       fontSize: 15,
                        //       fontWeight: FontWeight.w700,
                        //       color: Colors.red,
                        //     )),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                              height: 35,
                              //width: 100,
                              child: RaisedButton.icon(
                                onPressed: () {
                                  SiteService()
                                      .addSiteWorker(siteModel, worker.id);
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(50.0))),
                                label: Text(
                                  'Assign',
                                  style: TextStyle(color: Colors.white),
                                ),
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                                textColor: Colors.white,
                                splashColor: Colors.red,
                                color: Colors.lightGreen,
                              ),
                            ))
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
