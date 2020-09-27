import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<SiteWorker> assignWorkers;

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
      this.assignWorkers);

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
        assignWorkers = snapshot.data()['assignWorkers'];

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
      "assignWorkers": assignWorkers
    };
  }
}

class SiteWorker {
  String id;
  String workerModelId;
  String workStartDate;
  String workEndDate;
  String fname;
  String lname;
  String mname;
  String gender;
  String age;
  String dob;
  String mobile;
  String idNumber;
  String paymentPerDay;
  String paymentPerMonth;
  String workingStatus; //working and not working
  bool isFree;

  SiteWorker(
      this.workStartDate,
      this.workEndDate,
      this.fname,
      this.lname,
      this.mname,
      this.gender,
      this.age,
      this.dob,
      this.mobile,
      this.idNumber,
      this.paymentPerDay,
      this.paymentPerMonth,
      this.workingStatus,
      this.isFree);

  SiteWorker.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot != null),
        id = snapshot.id,
        workerModelId = snapshot.data()['workerModelId'],
        workStartDate = snapshot.data()['workStartDate'],
        workEndDate = snapshot.data()['workEndDate'],
        fname = snapshot.data()['fname'],
        lname = snapshot.data()['lname'],
        mname = snapshot.data()['mname'],
        gender = snapshot.data()['gender'],
        age = snapshot.data()['age'],
        dob = snapshot.data()['dob'],
        mobile = snapshot.data()['mobile'],
        idNumber = snapshot.data()['idNumber'],
        paymentPerDay = snapshot.data()['paymentPerDay'],
        workingStatus = snapshot.data()['workingStatus'];

  toJson() {
    return {
      "workStartDate": workStartDate,
      "workEndDate": workEndDate,
      "fname": fname,
      "lname": lname,
      "mname": mname,
      "gender": gender,
      "age": age,
      "dob": dob,
      "mobile": mobile,
      "idNumber": idNumber,
      "paymentPerDay": paymentPerDay,
      "paymentPerMonth": paymentPerMonth,
      "workingStatus": workingStatus,
      "isFree": isFree
    };
  }
}
