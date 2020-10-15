import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moduler_flutter_app/modules/reports/services/reportService.dart';
import 'package:moduler_flutter_app/modules/worker/models/PaymentModel.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/screens/workerPayment.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

typedef void CountTransactionsCallback(int count);

class PaymentReport extends StatefulWidget {
  @override
  PaymentReportState createState() => PaymentReportState();
}

class PaymentReportState extends State<PaymentReport> {
  TextEditingController _fromDateController;
  TextEditingController _toDateController;
  String selectedFromDate;
  String selectedToDate;
  String totalPaidAmount = "0";
  String totalUnpaidAmount = "0";

  DateTime currentDate;

  bool isLoading = false;

  List<PaymentModel> paymentTrans = <PaymentModel>[];
  List<List<dynamic>> reportPaymentTrans = [];
  List<int> transCount = [];

  @override
  void initState() {
    print("initState");
    super.initState();
    currentDate = DateTime.now();
    _fromDateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(
      currentDate.subtract(Duration(days: 30)),
    ));
    _toDateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(currentDate),
    );
    loadWorkerPaymentReport();
  }

  getWorkerModel(DocumentReference workerRef) async {
    return await workerRef.get().then((doc) {
      return new WorkerModel.fromSnapshot(doc);
    });
  }

  loadWorkerPaymentReport() async {
    setState(() {
      isLoading = true;
    });
    paymentTrans = <PaymentModel>[];
    paymentTrans.clear();
    transCount = <int>[];
    transCount.clear();
    reportPaymentTrans = [];
    reportPaymentTrans.clear();
    print("loadWorkerPaymentReport 1");
    String tempTotalPaidAmount = await ReportService().getTotalPaidAmount(
        new DateFormat("dd-MM-yyyy").parse(_fromDateController.text),
        new DateFormat("dd-MM-yyyy").parse(_toDateController.text));

    String tempTotalUnpaidAmount = await ReportService().getUnpaidAmount(
        new DateFormat("dd-MM-yyyy").parse(_fromDateController.text),
        new DateFormat("dd-MM-yyyy").parse(_toDateController.text));

    List<PaymentModel> tempList = await ReportService().getPaymentTranssactions(
      new DateFormat("dd-MM-yyyy").parse(_fromDateController.text),
      new DateFormat("dd-MM-yyyy").parse(_toDateController.text),
    );

    print("tempList.l::" + tempList.length.toString());
    print("paymentTrans.l::" + paymentTrans.length.toString());
    int count = 0;
    tempList.forEach((pm) async {
      count = count + 1;
      WorkerModel wm = await getWorkerModel(pm.workerRef);
      pm.workerName = wm.fname + " " + wm.lname;

      List<dynamic> reportData = [];
      reportData.add(count.toString());
      reportData.add(pm.workerName);
      reportData.add(pm.paymentDate.toString());
      reportData.add(pm.amount);
      reportPaymentTrans.add(reportData);

      setState(() {
        paymentTrans.add(pm);
      });

      if (paymentTrans.length > 0 && paymentTrans.length == tempList.length) {
        isLoading = false;
      } else {
        isLoading = true;
      }
    });

    print("tempList.l::" + tempList.length.toString());
    print("paymentTrans.l::" + paymentTrans.length.toString());

    setState(() {
      totalPaidAmount = tempTotalPaidAmount;
      totalUnpaidAmount = tempTotalUnpaidAmount;
    });

    print("loadWorkerPaymentReport 2");
  }

  Widget _getFromDateTextField() {
    return TextFormField(
      controller: _fromDateController,
      enableInteractiveSelection: false,
      focusNode: new AlwaysDisabledFocusNode(),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
        fillColor: Color(0xfff3f3f4),
        filled: true,
        hintText: 'From  Date',
      ),
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1901, 1),
          lastDate: DateTime.now(),
          builder: (
            BuildContext context,
            Widget picker,
          ) {
            return Theme(
              data: ThemeData.light(),
              child: picker,
            );
          },
        ).then((selectedDate) {
          if (selectedDate != null) {
            _fromDateController.text =
                DateFormat('dd-MM-yyyy').format(selectedDate);
            selectedFromDate = _fromDateController.text;
            setState(() {
              loadWorkerPaymentReport();
            });
          }
        });
      },
      onChanged: (val) {
        //print('val::' + val);
        if (val.length >= 8) {
          RegExp dateRegex = new RegExp(
              r"^(((0[1-9]|[12]\d|3[01])\-(0[13578]|1[02])\-((19|[2-9]\d)\d{2}))|((0[1-9]|[12]\d|30)\-(0[13456789]|1[012])\-((19|[2-9]\d)\d{2}))|((0[1-9]|1\d|2[0-8])\-02\-((19|[2-9]\d)\d{2}))|(29\-02\-((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|(([1][26]|[2468][048]|[3579][26])00))))$");
          if (dateRegex.hasMatch(val)) {
            _fromDateController.text = val;
          } else {
            _fromDateController.text = '';
            _displaySnackBar(
                context, 'E', 'Invalid Date', 'Please select valid date');
          }
          selectedFromDate = _fromDateController.text;
        }

        if (_fromDateController.text != '') {
          setState(() {
            loadWorkerPaymentReport();
          });
        }
      },
    );
  }

  Widget _getToDateTextField() {
    return TextFormField(
      controller: _toDateController,
      enableInteractiveSelection: false,
      focusNode: new AlwaysDisabledFocusNode(),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
        fillColor: Color(0xfff3f3f4),
        filled: true,
        hintText: 'To  Date',
      ),
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1901, 1),
          lastDate: DateTime.now(),
          builder: (
            BuildContext context,
            Widget picker,
          ) {
            return Theme(
              data: ThemeData.light(),
              child: picker,
            );
          },
        ).then((selectedDate) {
          if (selectedDate != null) {
            _toDateController.text =
                DateFormat('dd-MM-yyyy').format(selectedDate);
            selectedToDate = _toDateController.text;
            setState(() {
              loadWorkerPaymentReport();
            });
          }
        });
      },
      onChanged: (val) {
        //print('val::' + val);
        if (val.length >= 8) {
          RegExp dateRegex = new RegExp(
              r"^(((0[1-9]|[12]\d|3[01])\-(0[13578]|1[02])\-((19|[2-9]\d)\d{2}))|((0[1-9]|[12]\d|30)\-(0[13456789]|1[012])\-((19|[2-9]\d)\d{2}))|((0[1-9]|1\d|2[0-8])\-02\-((19|[2-9]\d)\d{2}))|(29\-02\-((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|(([1][26]|[2468][048]|[3579][26])00))))$");
          if (dateRegex.hasMatch(val)) {
            _toDateController.text = val;
          } else {
            _toDateController.text = '';
            _displaySnackBar(
                context, 'E', 'Invalid Date', 'Please select valid date');
          }
          selectedToDate = _toDateController.text;
        }

        if (_toDateController.text != '') {
          setState(() {
            loadWorkerPaymentReport();
          });
        }
      },
    );
  }

  PreferredSizeWidget buildAppBarBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _getFromDateTextField(),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: _getToDateTextField(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, String labelMain,
      String labelSub, Color labelMainColor) {
    return InkWell(
      onTap: null,
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200],
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    labelMain,
                    style: TextStyle(
                      fontSize: 20,
                      color: labelMainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    labelSub,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: new AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: new Text(
            'Payment Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: buildAppBarBottom(),
        ),
        body: isLoading
            ? Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 1280),
                  child: CircularProgressIndicator(),
                ),
              )
            : paymentTrans != null && paymentTrans.length > 0
                ? ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const SizedBox(height: 16.0),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildReportTile(
                              context,
                              totalPaidAmount,
                              "Total Paid Amount",
                              Colors.green[600],
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: _buildReportTile(
                              context,
                              totalUnpaidAmount,
                              "Total Unpaid Amount",
                              Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Paid Transactions",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: paymentTrans
                            .map((pm) => PaymentTranCard(
                                  paymentModel: pm,
                                ))
                            .toList(),
                      )
                    ],
                  )
                : EmptyPaymentTranListView(
                    child: Text('Paid Transactions not found !')));
  }

  _displaySnackBar(
      BuildContext context, String type, String title, String text) {
    if (type == 'E') {
      Flushbar(
        titleText: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Colors.red[600]),
        ),
        message: text,
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.red[300],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    } else {
      Flushbar(
        titleText: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Colors.blue[600]),
        ),
        message: text,
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.blue[300],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }
}

class PaymentTranCard extends StatefulWidget {
  final PaymentModel paymentModel;
  PaymentTranCard({
    @required this.paymentModel,
  });
  @override
  PaymentTranCardState createState() => PaymentTranCardState(
        paymentModel: paymentModel,
      );
}

class PaymentTranCardState extends State<PaymentTranCard> {
  final PaymentModel paymentModel;
  PaymentTranCardState({
    @required this.paymentModel,
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      //margin: EdgeInsets.only(bottom: 5, left: 12, right: 12, top: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
      ),
      child: new Row(
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    paymentModel.workerName,
                    overflow: TextOverflow.fade,
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy').format(paymentModel.paymentDate),
                    overflow: TextOverflow.fade,
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Rs. " + paymentModel.amount,
                    overflow: TextOverflow.fade,
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class EmptyPaymentTranListView extends StatelessWidget {
  final Widget child;
  EmptyPaymentTranListView({this.child});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[child],
      ),
    );
  }
}

Future<Uint8List> generateReport(
    PdfPageFormat pageFormat, List<List<dynamic>> pms) async {
  const _darkColor = PdfColors.blueGrey800;
  const _lightColor = PdfColors.white;
  const _baseColor = PdfColors.teal;
  const _accentColor = PdfColors.blueGrey900;

  PdfColor _baseTextColor =
      _baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

    final font1 = await rootBundle.load('assets/roboto1.ttf');
    final font2 = await rootBundle.load('assets/roboto2.ttf');
    final font3 = await rootBundle.load('assets/roboto3.ttf');

    pw.PageTheme _buildTheme(
        PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
      return pw.PageTheme(
        pageFormat: pageFormat,
        theme: pw.ThemeData.withFont(
          base: base,
          bold: bold,
          italic: italic,
        ),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(
            children: [
              pw.Positioned(
                bottom: 0,
                left: 0,
                child: pw.Container(
                  height: 20,
                  width: pageFormat.width / 2,
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [_baseColor, PdfColors.white],
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                bottom: 20,
                left: 0,
                child: pw.Container(
                  height: 20,
                  width: pageFormat.width / 4,
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [_accentColor, PdfColors.white],
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                top: pageFormat.marginTop + 72,
                left: 0,
                right: 0,
                child: pw.Container(
                  height: 3,
                  color: _baseColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    pw.Widget _buildHeader(pw.Context context) {
      return pw.Column(
        children: [
          pw.Text(
            'Paid Payment Report',
            style: pw.TextStyle(
              color: _baseColor,
              fontSize: 25,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 4),
          pw.SizedBox(height: 10),
        ],
      );
    }

    pw.Widget _contentTable(pw.Context context) {
      const tableHeaders = [
        '#',
        'Worker Name',
        'Payment Date',
        'Paid Amount',
      ];

      return pw.Table.fromTextArray(
        border: null,
        cellAlignment: pw.Alignment.centerLeft,
        headerDecoration: pw.BoxDecoration(
          borderRadius: 2,
          color: PdfColors.teal,
        ),
        headerHeight: 25,
        cellHeight: 40,
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerLeft,
          3: pw.Alignment.centerRight
        },
        headerStyle: pw.TextStyle(
          color: _baseTextColor,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(
          color: _darkColor,
          fontSize: 10,
        ),
        rowDecoration: pw.BoxDecoration(
          border: pw.BoxBorder(
            bottom: true,
            color: _accentColor,
            width: .5,
          ),
        ),
        headers: List<String>.generate(
          tableHeaders.length,
          (col) => tableHeaders[col],
        ),
        data: pms,
      );
    }

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          font1 != null ? pw.Font.ttf(font1) : null,
          font2 != null ? pw.Font.ttf(font2) : null,
          font3 != null ? pw.Font.ttf(font3) : null,
        ),
        header: _buildHeader,
        build: (context) => [
          _contentTable(context),
          pw.SizedBox(height: 20),
          // _contentFooter(context),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }
}
