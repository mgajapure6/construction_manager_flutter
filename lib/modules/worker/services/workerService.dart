import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';

abstract class BaseWorkerService {
  Map createWorker(WorkerModel worker);
  Map updateWorker(WorkerModel worker, String id);
  Map deleteWorker(String id);
  Stream<QuerySnapshot> loadAllWorkers();
  List<WorkerModel> getSnapshotWorkers(QuerySnapshot snapshot);
  Future<WorkerModel> getOne(String id);
  Stream<QuerySnapshot> loadFreeWorkers();
}

class WorkerService implements BaseWorkerService {
  final CollectionReference workerCollectionRef =
      FirebaseFirestore.instance.collection('workers');

  @override
  Map createWorker(WorkerModel worker) {
    var responseMap = new Map();
    try {
      workerCollectionRef.add(worker.toJson());
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Worker save successfully.';
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
  Map deleteWorker(String id) {
    var responseMap = new Map();
    try {
      workerCollectionRef.doc(id).delete();
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Worker deleted successfully.';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('exception:' + e.toString());
      print('exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  Stream<QuerySnapshot> loadAllWorkers() {
    return workerCollectionRef.snapshots();
  }

  @override
  List<WorkerModel> getSnapshotWorkers(QuerySnapshot snapshot) {
    return snapshot.docs.map((DocumentSnapshot doc) {
      return WorkerModel.fromSnapshot(doc);
    }).toList();
  }

  @override
  Map updateWorker(WorkerModel worker, String id) {
    print("updating::" + id);
    var responseMap = new Map();
    try {
      workerCollectionRef.doc(id).update(worker.toJson());
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Worker updated successfully.';
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
  Future<WorkerModel> getOne(String id) {
    return workerCollectionRef
        .doc(id)
        .get()
        .then((DocumentSnapshot doc) => WorkerModel.fromSnapshot(doc));
  }

  @override
  Stream<QuerySnapshot> loadFreeWorkers() {
    return workerCollectionRef.where('isFree', isEqualTo: true).snapshots();
  }
}
