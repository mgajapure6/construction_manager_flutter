import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:moduler_flutter_app/modules/worker/models/attendanceModel.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';

abstract class BaseWorkerAttendanceService {
  Future<Map> createWorkersAttendance(List<AttendanceModel> attendances);
  Future<Map> updateWorkersAttendance(List<AttendanceModel> attendances);
  Future<Map> deleteWorkersAttendance(List<AttendanceModel> attendances);
  Stream<QuerySnapshot> loadAllWorkersAttendance();
  List<AttendanceModel> getSnapshotData(QuerySnapshot snapshot);
  Future<List<AttendanceModel>> getAttendanceBySiteAndDate(
      String siteId, String attendanceDate);
  Future<int> getAttendanceCountBySiteAndDate(
      String siteId, String attendanceDate);

  Future<List<AttendanceModel>> getAttendanceByWorkerId(String workerId);
  Future<Map> updateWorkersAttendancePaymentStatus(
      List<Map<String, dynamic>> idStatusMap);
}

class AttendanceService implements BaseWorkerAttendanceService {
  final CollectionReference workerAttendanceCollectionRef =
      FirebaseFirestore.instance.collection('attendance');

  final CollectionReference workerCollectionRef =
      FirebaseFirestore.instance.collection('workers');

  @override
  Future<Map> createWorkersAttendance(List<AttendanceModel> attendances) async {
    var responseMap = new Map();
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      attendances.forEach((attendance) {
        Map<String, dynamic> aMap = attendance.toMap();
        DocumentReference workerRef =
            workerCollectionRef.doc(attendance.workerModelId);
        aMap["workerRef"] = workerRef;
        batch.set(workerAttendanceCollectionRef.doc(), aMap);
      });
      await batch.commit();
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Attendance save successfully.';
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
  Future<Map> updateWorkersAttendance(List<AttendanceModel> attendances) async {
    var responseMap = new Map();

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      attendances.forEach((attendance) {
        print('attendance id update::' + attendance.id);
        batch.update(workerAttendanceCollectionRef.doc(attendance.id),
            attendance.toMap());
      });
      await batch.commit();
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Attendance updated successfully.';
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
  Future<Map> updateWorkersAttendancePaymentStatus(
      List<Map<String, dynamic>> idStatusMap) async {
    var responseMap = new Map();

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      idStatusMap.forEach((map) {
        print('attendance id update::' + map["id"]);
        batch.update(workerAttendanceCollectionRef.doc(map["id"]),
            {"paymentStatus": map["status"]});
      });
      await batch.commit();
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Payment updated successfully.';
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
  Future<Map> deleteWorkersAttendance(List<AttendanceModel> attendances) async {
    var responseMap = new Map();
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      attendances.forEach((attendance) {
        batch.delete(workerAttendanceCollectionRef.doc(attendance.id));
      });
      await batch.commit();
      responseMap["status"] = 'success';
      responseMap["msg"] = 'attendance save successfully.';
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
  List<AttendanceModel> getSnapshotData(QuerySnapshot snapshot) {
    return snapshot.docs.map((DocumentSnapshot doc) {
      return AttendanceModel.fromSnapshot(doc);
    }).toList();
  }

  @override
  Stream<QuerySnapshot> loadAllWorkersAttendance() {
    return workerAttendanceCollectionRef.snapshots();
  }

  @override
  Future<int> getAttendanceCountBySiteAndDate(
      String siteId, String attendanceDate) async {
    return await workerAttendanceCollectionRef
        .where("siteModelId", isEqualTo: siteId)
        .where("attendanceDate", isEqualTo: attendanceDate)
        .get()
        .then((snapshot) {
      return snapshot.size;
    });
  }

  @override
  Future<List<AttendanceModel>> getAttendanceBySiteAndDate(
      String siteId, String attendanceDate) async {
    return await workerAttendanceCollectionRef
        .where("siteModelId", isEqualTo: siteId)
        .where("attendanceDate", isEqualTo: attendanceDate)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((DocumentSnapshot doc) {
        return new AttendanceModel.fromSnapshot(doc);
      }).toList();
    });
  }

  @override
  Future<List<AttendanceModel>> getAttendanceByWorkerId(String workerId) async {
    return await workerAttendanceCollectionRef
        .where("workerModelId", isEqualTo: workerId)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((DocumentSnapshot doc) {
        return new AttendanceModel.fromSnapshot(doc);
      }).toList();
    });
  }
}
