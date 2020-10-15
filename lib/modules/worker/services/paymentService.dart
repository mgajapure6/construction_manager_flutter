import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moduler_flutter_app/modules/worker/models/PaymentModel.dart';

abstract class BaseWorkerPaymentService {
  Future<Map> savePayment(PaymentModel payment);
  Future<Map> updatePayment(PaymentModel payment, String id);
  Future<Map> deletePayment(String id);
  Stream<QuerySnapshot> loadPayments();
  List<PaymentModel> getSnapshotData(QuerySnapshot snapshot);
}

class PaymentService implements BaseWorkerPaymentService {
  final CollectionReference paymentCollectionRef =
      FirebaseFirestore.instance.collection('payments');

  @override
  Future<Map> deletePayment(String id) async {
    var responseMap = new Map();
    try {
      await paymentCollectionRef.doc(id).delete();
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Payment deleted successfully.';
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
  Future<Map> updatePayment(PaymentModel payment, String id) async {
    var responseMap = new Map();
    try {
      await paymentCollectionRef.doc(id).update(payment.toJson());
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
  List<PaymentModel> getSnapshotData(QuerySnapshot snapshot) {
    return snapshot.docs.map((DocumentSnapshot doc) {
      return PaymentModel.fromSnapshot(doc);
    }).toList();
  }

  @override
  Stream<QuerySnapshot> loadPayments() {
    return paymentCollectionRef.snapshots();
  }

  @override
  Future<Map> savePayment(PaymentModel payment) async {
    var responseMap = new Map();
    try {
      await paymentCollectionRef.add(payment.toJson());
      responseMap["status"] = 'success';
      responseMap["msg"] = 'Payment save successfully.';
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
