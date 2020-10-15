import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';

class AttendanceModel {
  String id;
  DateTime attendanceDate;
  String attendanceStatus;
  String paymentStatus;
  String workerModelId;
  String siteModelId;
  String paymentAmount;
  DocumentReference workerRef;

  AttendanceModel.empty();

  AttendanceModel(
    this.id,
    this.attendanceDate,
    this.attendanceStatus,
    this.workerModelId,
    this.paymentStatus,
    this.siteModelId,
    this.paymentAmount,
  );

  AttendanceModel.fetch(
    this.id,
    this.attendanceDate,
    this.attendanceStatus,
    this.workerModelId,
    this.paymentStatus,
    this.siteModelId,
    this.paymentAmount,
    this.workerRef,
  );

  AttendanceModel.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot != null),
        id = snapshot.id,
        attendanceDate = snapshot.data()['attendanceDate'].toDate(),
        attendanceStatus = snapshot.data()['attendanceStatus'],
        workerModelId = snapshot.data()['workerModelId'],
        paymentStatus = snapshot.data()['paymentStatus'],
        siteModelId = snapshot.data()['siteModelId'],
        paymentAmount = snapshot.data()['paymentAmount'],
        workerRef = snapshot.data()['workerRef'];

  toJson() {
    return {
      "attendanceDate": attendanceDate,
      "attendanceStatus": attendanceStatus,
      "workerModelId": workerModelId,
      "paymentStatus": paymentStatus,
      "siteModelId": siteModelId,
      "paymentAmount": paymentAmount,
      //"workerRef": workerRef
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "attendanceDate": attendanceDate,
      "attendanceStatus": attendanceStatus,
      "workerModelId": workerModelId,
      "paymentStatus": paymentStatus,
      "siteModelId": siteModelId,
      "paymentAmount": paymentAmount,
      //"workerRef": workerRef
    };
  }

  Map<String, dynamic> toPaymentMap() {
    return {
      "paymentStatus": paymentStatus,
    };
  }
}
