import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moduler_flutter_app/modules/site/models/siteModel.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';

abstract class BaseSiteService {
  Map createSite(SiteModel site);
  Map updateSite(SiteModel site, String id);
  Map deleteSite(String id);
  Stream<QuerySnapshot> loadAllSites();
  List<SiteModel> getActiveSites(QuerySnapshot snapshot);
  List<SiteModel> getAllSites(QuerySnapshot snapshot);
  Future<SiteModel> getOne(String id);
  Future<Map> addSiteWorker(SiteModel site, String workersId);
  Future<Map> removeSiteWorker(String siteId, String workerId);
  Stream<QuerySnapshot> loadAssignedWorkers(
      String siteId, List<dynamic> assignWorkersId);
  List<WorkerModel> getAssignWorkersSnapshotData(QuerySnapshot snapshot);
  Future<List<WorkerModel>> getSiteWorkerList(
      String siteId, List<dynamic> assignWorkersId);
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
  Future<Map> addSiteWorker(SiteModel site, String workerId) async {
    var responseMap = new Map();
    try {
      List<dynamic> assignWorkersId;
      await siteCollectionRef
          .doc(site.id)
          .get()
          .then((DocumentSnapshot doc) async => {
                assignWorkersId = doc.data()["assignWorkersId"],
                assignWorkersId.add(workerId),
                await siteCollectionRef
                    .doc(site.id)
                    .update({"assignWorkersId": assignWorkersId}),
              });

      await WorkerService().updateWorkerFreeStatus(workerId, false);
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Worker assign successfully.';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('addSiteWorker exception:' + e.toString());
      print('addSiteWorker exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  @override
  Future<Map> removeSiteWorker(String siteId, String workerId) async {
    var responseMap = new Map();
    try {
      List<dynamic> assignWorkersId;
      await siteCollectionRef
          .doc(siteId)
          .get()
          .then((DocumentSnapshot doc) async => {
                assignWorkersId = doc.data()["assignWorkersId"],
                if (assignWorkersId.contains(workerId))
                  {
                    assignWorkersId.remove(workerId),
                    await siteCollectionRef
                        .doc(siteId)
                        .update({"assignWorkersId": assignWorkersId}),
                  }
              });

      await WorkerService().updateWorkerFreeStatus(workerId, true);

      responseMap["status"] = 'success';
      responseMap["msg"] = 'Worker remove successfully.';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('removeSiteWorker exception:' + e.toString());
      print('removeSiteWorker exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  @override
  List<WorkerModel> getAssignWorkersSnapshotData(QuerySnapshot snapshot) {
    return snapshot.docs.map((DocumentSnapshot doc) {
      return WorkerModel.fromSnapshot(doc);
    }).toList();
  }

  @override
  Stream<QuerySnapshot> loadAssignedWorkers(
      String siteId, List<dynamic> assignWorkersId) {
    return WorkerService()
        .workerCollectionRef
        .where('id', arrayContains: assignWorkersId)
        .snapshots();
  }

  @override
  List<SiteModel> getAllSites(QuerySnapshot snapshot) {
    return snapshot.docs.map((DocumentSnapshot doc) {
      return SiteModel.fromSnapshot(doc);
    }).toList();
  }

  @override
  Future<List<WorkerModel>> getSiteWorkerList(
      String siteId, List<dynamic> assignWorkersId) async {
    //List<WorkerModel> workers = [];
    return await WorkerService()
        .workerCollectionRef
        .where(FieldPath.documentId, whereIn: assignWorkersId)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((DocumentSnapshot doc) {
        return WorkerModel.fromSnapshot(doc);
      }).toList();
    });

    //return workers;
  }
}
