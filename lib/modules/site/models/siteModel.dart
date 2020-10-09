import 'dart:html';
import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';

class SiteModel {
  String id;
  String siteType;
  String siteName;
  String siteStartDate;
  String siteEndDate;
  String siteOwnerName;
  String siteBudget;
  String sitePhoto;
  String status;
  String siteCreateDate;
  String siteCreatedBy;
  String siteUpdateDate;
  String siteUpdatedBy;
  List<dynamic> assignWorkersId;

  SiteModel.empty();

  SiteModel(
      this.siteType,
      this.siteName,
      this.siteStartDate,
      this.siteEndDate,
      this.siteOwnerName,
      this.siteBudget,
      this.sitePhoto,
      this.status,
      this.siteCreateDate,
      this.siteUpdateDate,
      this.siteCreatedBy,
      this.siteUpdatedBy);

  SiteModel.withoutCreate(
      this.siteType,
      this.siteName,
      this.siteStartDate,
      this.siteEndDate,
      this.siteOwnerName,
      this.siteBudget,
      this.sitePhoto,
      this.status,
      this.siteUpdateDate,
      this.siteUpdatedBy);

  SiteModel.withAssignWorkers(
      this.siteType,
      this.siteName,
      this.siteStartDate,
      this.siteEndDate,
      this.siteOwnerName,
      this.siteBudget,
      this.sitePhoto,
      this.status,
      this.assignWorkersId);

  SiteModel.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot != null),
        id = snapshot.id,
        siteType = snapshot.data()['siteType'],
        siteName = snapshot.data()['siteName'],
        siteStartDate = snapshot.data()['siteStartDate'],
        siteEndDate = snapshot.data()['siteEndDate'],
        siteOwnerName = snapshot.data()['siteOwnerName'],
        siteBudget = snapshot.data()['siteBudget'],
        sitePhoto = snapshot.data()['sitePhoto'],
        status = snapshot.data()['status'],
        siteCreateDate = snapshot.data()['siteCreateDate'],
        siteUpdateDate = snapshot.data()['siteUpdateDate'],
        siteCreatedBy = snapshot.data()['siteCreatedBy'],
        siteUpdatedBy = snapshot.data()['siteUpdatedBy'],
        assignWorkersId = snapshot.data()['assignWorkersId'];

  toJson() {
    return {
      "siteType": siteType,
      "siteName": siteName,
      "siteStartDate": siteStartDate,
      "siteEndDate": siteEndDate,
      "siteOwnerName": siteOwnerName,
      "siteBudget": siteBudget,
      "sitePhoto": sitePhoto,
      "status": status,
      "siteCreateDate": siteCreateDate,
      "siteUpdateDate": siteUpdateDate,
      "siteCreatedBy": siteCreatedBy,
      "siteUpdatedBy": siteUpdatedBy,
      "assignWorkersId": assignWorkersId,
    };
  }
}

// class SiteWorker {
//   String id;
//   WorkerModel worker;
//   String workStartDate;
//   String workEndDate;

//   SiteWorker(this.workStartDate, this.workEndDate, this.worker);

//   SiteWorker.fromSnapshot(DocumentSnapshot snapshot)
//       : assert(snapshot != null),
//         id = snapshot.id,
//         worker = snapshot.data()['worker'],
//         workStartDate = snapshot.data()['workStartDate'],
//         workEndDate = snapshot.data()['workEndDate'];

//   toJson() {
//     return {
//       "workStartDate": workStartDate,
//       "workEndDate": workEndDate,
//       "worker": {}
//     };
//   }
// }
