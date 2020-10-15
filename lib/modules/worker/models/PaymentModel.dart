import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  String id;
  String sn;
  DateTime paymentDate;
  String amount;
  String workerId;
  DocumentReference workerRef;
  String workerName;

  PaymentModel.empty();

  PaymentModel(
    this.id,
    this.paymentDate,
    this.amount,
    this.workerId,
    this.workerRef,
  );

  PaymentModel.withWorkerName(
    this.id,
    this.paymentDate,
    this.amount,
    this.workerId,
    this.workerRef,
    this.workerName,
  );

  PaymentModel.forReport(
    this.sn,
    this.workerName,
    this.paymentDate,
    this.amount,
  );

  PaymentModel.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot != null),
        id = snapshot.id,
        paymentDate = snapshot.data()['paymentDate'].toDate(),
        amount = snapshot.data()['amount'],
        workerId = snapshot.data()['workerId'],
        workerRef = snapshot.data()['workerRef'];

  toJson() {
    return {
      "paymentDate": paymentDate,
      "amount": amount,
      "workerId": workerId,
      "workerRef": workerRef,
    };
  }
}
