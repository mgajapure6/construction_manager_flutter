import 'dart:async';
import 'dart:html';
import 'package:flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moduler_flutter_app/modules/login/services/auth.dart';
import 'package:moduler_flutter_app/modules/site/models/siteModel.dart';
import 'package:moduler_flutter_app/modules/site/screens/assignWorker.dart';
import 'package:moduler_flutter_app/modules/site/screens/siteForm.dart';
import 'package:moduler_flutter_app/modules/site/services/siteService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';

class SiteWorkersList extends StatefulWidget {
  final SiteModel siteModel;

  SiteWorkersList({@required this.siteModel});

  @override
  SiteWorkersListState createState() => SiteWorkersListState();
}

class SiteWorkersListState extends State<SiteWorkersList> {
  bool isLoading = true;
  List<WorkerModel> assignWorkers = <WorkerModel>[];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    updateAssignedWorkers();
  }

  Future<void> updateAssignedWorkers() async {
    setState(() {
      isLoading = true;
    });
    print("assignWorkersId::" + widget.siteModel.assignWorkersId.toString());
    List<WorkerModel> assignWorkersTemp =
        widget.siteModel.assignWorkersId == null
            ? new List<WorkerModel>()
            : await SiteService().getSiteWorkerList(
                widget.siteModel.id, widget.siteModel.assignWorkersId);
    print('assignWorkersTemp length::' + assignWorkersTemp.length.toString());
    setState(() {
      assignWorkers = assignWorkersTemp;
      isLoading = false;
      print('assignWorkers length::' + assignWorkers.length.toString());
    });
  }

  Widget _assignWorkerButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AssignWorker(siteModel: widget.siteModel)),
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
            Text('Assign Worker', style: TextStyle(fontWeight: FontWeight.w500))
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
        title: new Text('Site Workers List'),
        actions: [_assignWorkerButton()],
      ),
      body: Center(
          child: Container(
        constraints: BoxConstraints(maxWidth: 1280),
        child: isLoading
            ? CircularProgressIndicator()
            : assignWorkers.length > 0
                ? SiteWorkersListView(
                    site: widget.siteModel, assignWorkers: assignWorkers)
                : EmptyListView(
                    child: Text('No Workers Found For This Site !')),
      )
          // Column(
          //   children: <Widget>[
          //     SizedBox(
          //       height: 20,
          //     ),
          //     RichText(
          //       textAlign: TextAlign.start,
          //       text: TextSpan(
          //           text: widget.siteModel.siteName,
          //           style: TextStyle(color: Colors.black, fontSize: 19)),
          //     ),
          //     SizedBox(
          //       height: 10,
          //     ),
          //     RichText(
          //       text: TextSpan(
          //           text: 'Start Date : ' + widget.siteModel.siteStartDate,
          //           style: TextStyle(color: Colors.black, fontSize: 14)),
          //     ),
          //     SizedBox(
          //       height: 5,
          //     ),
          //     RichText(
          //       text: TextSpan(
          //           text: 'Owner : ' + widget.siteModel.siteOwnerName,
          //           style: TextStyle(color: Colors.black, fontSize: 14)),
          //     ),
          //     SizedBox(
          //       height: 30,
          //     ),
          //     Center(
          //       child: assignWorkers.length > 0
          //           ? SiteWorkersListView(
          //               site: widget.siteModel, assignWorkers: assignWorkers)
          //           : EmptyListView(
          //               child: Text('No Workers Found For This Site !')),
          //     )
          //   ],
          // )
          ),
    );
  }
}

class SiteWorkersListView extends StatelessWidget {
  final SiteModel site;
  final List<WorkerModel> assignWorkers;

  SiteWorkersListView({@required this.site, @required this.assignWorkers});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          children: assignWorkers
              .map((worker) => SiteWorkerCard(site: site, worker: worker))
              .toList()),
    );
  }
}

class SiteWorkerCard extends StatelessWidget {
  final SiteModel site;
  final WorkerModel worker;
  SiteWorkerCard({@required this.site, @required this.worker});

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
            width: 130,
            height: 130,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: worker.photoUrl == null
                  ? AssetImage('assets/images/worker.png')
                  : NetworkImage(worker.photoUrl),
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
                        Text(
                          "Start Working Date : ",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          worker.workStartDate,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "End Working Date : ",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          worker.workEndDate == null
                              ? 'Still Working'
                              : worker.workEndDate,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "Contact : ",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          worker.mobile,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Text("Remove"),
                            )
                          ],
                          onCanceled: () {
                            print("You have canceled the menu.");
                          },
                          onSelected: (value) {
                            if (value == 1) {
                              CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.confirm,
                                  text: "Do you want to remove worker ? ",
                                  confirmBtnText: "Yes",
                                  cancelBtnText: "No",
                                  confirmBtnColor: Colors.red,
                                  onConfirmBtnTap: () {
                                    Navigator.pop(context);
                                    SiteService()
                                        .removeSiteWorker(site.id, worker.id)
                                        .then((value) => {
                                              if (value['status'] == 'success')
                                                {
                                                  _displaySnackBar(context, 'S',
                                                      'Success', value['msg'])
                                                }
                                              else
                                                {
                                                  _displaySnackBar(context, 'E',
                                                      'Failed', value['msg'])
                                                }
                                            });
                                  });
                            }
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
