import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moduler_flutter_app/modules/site/models/siteModel.dart';

abstract class BaseSiteService {
  Map createSite(SiteModel site);
  Map updateSite(SiteModel site, String id);
  Map deleteSite(String id);
  Stream<QuerySnapshot> loadAllSites();
  List<SiteModel> getActiveSites(QuerySnapshot snapshot);
  Future<SiteModel> getOne(String id);
  Map addSiteWorker(SiteModel site, SiteWorker worker);
  Map removeSiteWorker(String siteId, SiteWorker worker);
}

class SiteService implements BaseSiteService {
  final CollectionReference siteCollectionRef =
      FirebaseFirestore.instance.collection('sites');

  @override
  Map createSite(SiteModel site) {
    var responseMap = new Map();
    try {
      siteCollectionRef.add(site.toJson());
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Site save successfully.';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('exception:' + e.toString());
      print('exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  @override
  Map deleteSite(String id) {
    var responseMap = new Map();
    try {
      siteCollectionRef.doc(id).delete();
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Site deleted successfully.';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('exception:' + e.toString());
      print('exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  Stream<QuerySnapshot> loadAllSites() {
    return siteCollectionRef.snapshots();
  }

  @override
  List<SiteModel> getActiveSites(QuerySnapshot snapshot) {
    return snapshot.docs.map((DocumentSnapshot doc) {
      if (doc.data()['status'] == 'Active') {
        return SiteModel.fromSnapshot(doc);
      }
    }).toList();
  }

  @override
  Map updateSite(SiteModel site, String id) {
    print("updating::" + id);
    var responseMap = new Map();
    try {
      siteCollectionRef.doc(id).update(site.toJson());
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Site updated successfully.';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('exception:' + e.toString());
      print('exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  @override
  Future<SiteModel> getOne(String id) {
    return siteCollectionRef
        .doc(id)
        .get()
        .then((DocumentSnapshot doc) => SiteModel.fromSnapshot(doc));
  }

  @override
  Map addSiteWorker(SiteModel site, SiteWorker worker) {
    var responseMap = new Map();
    try {
      siteCollectionRef
          .doc(site.id)
          .collection("assignWorkers")
          .add(worker.toJson());

      responseMap["status"] = 'success';
      responseMap["msg"] = 'Worker assign successfully.';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('exception:' + e.toString());
      print('exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  @override
  Map removeSiteWorker(String siteId, SiteWorker worker) {
    var responseMap = new Map();
    try {
      siteCollectionRef
          .doc(siteId)
          .collection("assignWorkers")
          .doc(worker.id)
          .delete();
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Worker remove successfully.';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('exception:' + e.toString());
      print('exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }
}
