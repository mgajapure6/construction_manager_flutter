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

class SiteList extends StatefulWidget {
  static const route = '/';

  SiteList({Key key}) : super(key: key);

  @override
  SiteListState createState() => SiteListState();
}

class SiteListState extends State<SiteList> {
  StreamSubscription<QuerySnapshot> currentSubscription;
  bool isLoading = true;
  List<SiteModel> sites = <SiteModel>[];

  SiteListState() {
    // AuthService().currentUser().then((User user) {
    //   if (user != null) {
    //     currentSubscription = SiteService().loadAllSites().listen(updateSites);
    //   }
    // });

    currentSubscription = SiteService().loadAllSites().listen(updateSites);
  }

  @override
  void dispose() {
    print("dispose");
    currentSubscription?.cancel();
    super.dispose();
  }

  void updateSites(QuerySnapshot snapshot) {
    print("updateSites");
    setState(() {
      sites = SiteService().getActiveSites(snapshot);
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
                  SiteFromPage(flag: 'N', siteModel: SiteModel.empty())),
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
            Text('Add New Site',
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
        title: new Text('Site List',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        backgroundColor: Colors.transparent,
        actions: [_newSiteButton()],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1280),
          child: isLoading
              ? CircularProgressIndicator()
              : sites.isNotEmpty
                  ? SiteListView(sites: sites)
                  : EmptyListView(child: Text('No Sites Found !')),
        ),
      ),
    );
  }
}

class SiteListView extends StatelessWidget {
  final List<SiteModel> _sites;

  SiteListView({
    @required List<SiteModel> sites,
  }) : _sites = sites;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          children: _sites.map((site) => SiteCard(site: site)).toList()),
    );
  }
}

class SiteCard extends StatelessWidget {
  final SiteModel site;
  SiteCard({this.site});

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
                        site.siteName,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ]),
                    Row(
                      children: <Widget>[
                        Text("Start Date : "),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          site.siteStartDate,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("End Date : "),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          site.siteEndDate,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("Owner : "),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          site.siteOwnerName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("Budget : "),
                        SizedBox(
                          width: 5,
                        ),
                        Text(site.siteBudget,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.orange,
                            ))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(site.status,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            )),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Text("Edit Site"),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text("Delete Site"),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: Text("Site Workers"),
                            ),
                            PopupMenuItem(
                              value: 4,
                              child: Text("Site Materials"),
                            ),
                          ],
                          onCanceled: () {
                            print("You have canceled the menu.");
                          },
                          onSelected: (value) {
                            print("value:$value");
                            print("site name:" + this.site.siteName);
                            if (value == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SiteFromPage(
                                        flag: 'M', siteModel: site)),
                              );
                            } else if (value == 2) {
                              CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.confirm,
                                  text: "Do you want to delete site ? ",
                                  confirmBtnText: "Yes",
                                  cancelBtnText: "No",
                                  confirmBtnColor: Colors.red,
                                  onConfirmBtnTap: () {
                                    Navigator.pop(context);
                                    Map result =
                                        SiteService().deleteSite(site.id);
                                    if (result['status'] == 'success') {
                                      _displaySnackBar(context, 'S', 'Success',
                                          result['msg']);
                                    } else {
                                      _displaySnackBar(context, 'E', 'Failed',
                                          result['msg']);
                                    }
                                  });
                            } else if (value == 3) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  print("site print");
                                  print(site.toJson());
                                  return SiteWorkersList(siteModel: site);
                                }),
                              );
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
