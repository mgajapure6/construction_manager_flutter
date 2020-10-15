import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moduler_flutter_app/modules/worker/models/PaymentModel.dart';

abstract class BaseReportService {}

class ReportService implements BaseReportService {
  final CollectionReference attendanceCollectionRef =
      FirebaseFirestore.instance.collection('attendance');

  final CollectionReference workerCollectionRef =
      FirebaseFirestore.instance.collection('workers');

  final CollectionReference siteCollectionRef =
      FirebaseFirestore.instance.collection('sites');

  final CollectionReference paymentCollectionRef =
      FirebaseFirestore.instance.collection('payments');

  Future<String> getTotalPaidAmount(DateTime fromDate, DateTime toDate) async {
    dynamic totalPaidAmount = 0;
    await paymentCollectionRef
        .where("paymentDate", isGreaterThanOrEqualTo: fromDate)
        .where("paymentDate", isLessThanOrEqualTo: toDate)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        totalPaidAmount = totalPaidAmount + double.parse(doc.data()['amount']);
      });
    });
    print("totalPaidAmount::" + totalPaidAmount.toString());
    return totalPaidAmount.toString();
  }

  Future<String> getUnpaidAmount(DateTime fromDate, DateTime toDate) async {
    dynamic totalUnpaidAmount = 0;
    await attendanceCollectionRef
        .where("attendanceDate", isGreaterThanOrEqualTo: fromDate)
        .where("attendanceDate", isLessThanOrEqualTo: toDate)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc.data()['paymentStatus'] == "Unpaid") {
          totalUnpaidAmount =
              totalUnpaidAmount + double.parse(doc.data()['paymentAmount']);
        }
      });
    });
    print("totalUnpaidAmount::" + totalUnpaidAmount.toString());
    return totalUnpaidAmount.toString();
  }

  Future<List<PaymentModel>> getPaymentTranssactions(
      DateTime fromDate, DateTime toDate) async {
    return await paymentCollectionRef
        .where("paymentDate", isGreaterThanOrEqualTo: fromDate)
        .where("paymentDate", isLessThanOrEqualTo: toDate)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((DocumentSnapshot doc) {
        return new PaymentModel.fromSnapshot(doc);
      }).toList();
    });
  }
}
