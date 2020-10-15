import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerModel {
  String id;
  String refId;
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
  String paymentPerHalfDay;
  String paymentPerMonth;
  String workingStatus; //working and not working
  bool isFree;
  String photoUrl;
  String createDate;
  String createdBy;
  String updateDate;
  String updatedBy;
  String attendanceId;
  String paidStatus;
  String attendanceStatus;

  WorkerModel.empty();
  WorkerModel.name(
    this.fname,
    this.lname,
    this.mname,
    this.gender,
    this.mobile,
  );

  WorkerModel(
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
      this.paymentPerHalfDay,
      this.paymentPerMonth,
      this.workingStatus,
      this.isFree,
      this.photoUrl,
      this.createDate,
      this.createdBy,
      this.updateDate,
      this.updatedBy);

  WorkerModel.withoutCreate(
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
    this.paymentPerHalfDay,
    this.paymentPerMonth,
    this.workingStatus,
    this.isFree,
    this.photoUrl,
    this.updateDate,
    this.updatedBy,
  );

  WorkerModel.attendanceModel(
    this.attendanceId,
    this.id,
    this.fname,
    this.mname,
    this.lname,
    this.photoUrl,
    this.paymentPerDay,
    this.paymentPerHalfDay,
    this.paidStatus,
    this.attendanceStatus,
  );

  WorkerModel.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot != null),
        id = snapshot.id,
        refId = snapshot.data()['refId'],
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
        paymentPerHalfDay = snapshot.data()['paymentPerHalfDay'],
        workingStatus = snapshot.data()['workingStatus'],
        isFree = snapshot.data()['isFree'],
        photoUrl = snapshot.data()['photoUrl'],
        createDate = snapshot.data()['createDate'],
        createdBy = snapshot.data()['createdBy'],
        updateDate = snapshot.data()['updateDate'],
        updatedBy = snapshot.data()['updatedBy'];

  toJson() {
    return {
      "refId": refId,
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
      "paymentPerHalfDay": paymentPerHalfDay,
      "paymentPerMonth": paymentPerMonth,
      "workingStatus": workingStatus,
      "isFree": isFree,
      "photoUrl": photoUrl,
    };
  }
}
