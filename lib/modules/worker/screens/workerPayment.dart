import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:intl/intl.dart';
import 'package:moduler_flutter_app/modules/site/models/siteModel.dart';
import 'package:moduler_flutter_app/modules/site/services/siteService.dart';
import 'package:moduler_flutter_app/modules/worker/models/PaymentModel.dart';
import 'package:moduler_flutter_app/modules/worker/models/attendanceModel.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/services/attendanceService.dart';
import 'package:moduler_flutter_app/modules/worker/services/paymentService.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';

typedef void UpdateListAndSavePaymentBtn(
    String flag, Map<String, dynamic> attendanceMap);

class WorkerPayment extends StatefulWidget {
  @override
  WorkerPaymentState createState() => WorkerPaymentState();
}

class WorkerPaymentState extends State<WorkerPayment> {
  StreamSubscription<QuerySnapshot> currentSiteSubscription;
  TextEditingController _paymentDateController;
  List<DropdownMenuItem> siteItems = [];
  List<DropdownMenuItem> workerItems = <DropdownMenuItem>[];
  List<SiteModel> sites = <SiteModel>[];
  List<WorkerModel> assignWorkersList = <WorkerModel>[];
  bool isAttendanceLoading = true;
  List<AttendanceModel> allAttendances = [];
  bool isSaveBtnVisible = false;
  List<AttendanceModel> workerAttendances = <AttendanceModel>[];

  List<Map<String, dynamic>> selectedAttendances = <Map<String, dynamic>>[];

  String selectedSiteId;
  String selectedWorkerId;
  SiteModel selectedSiteModel;
  WorkerModel selectedWorkerModel;
  String createUpdateFlag;
  String selectedPaymentDate;

  String emptyStatus = "Please Select Site";

  final _workerStatekey = GlobalKey<FormFieldState>();

  String totalPaymentHasToBePaid = "0.00";

  @override
  void initState() {
    super.initState();
    _paymentDateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    currentSiteSubscription = SiteService().loadAllSites().listen(updateSites);
    selectedPaymentDate = _paymentDateController.text;
    print('selectedPaymentDate::' + selectedPaymentDate);
  }

  void updateSites(QuerySnapshot snapshot) {
    setState(() {
      sites = SiteService().getActiveSites(snapshot);
      if (sites.length > 0) {
        siteItems = sites
            .map((site) => DropdownMenuItem(
                  child: Text(site.siteName),
                  value: site.id,
                  onTap: () {},
                ))
            .toList();
      } else {
        emptyStatus = "Sites not found";
      }

      isAttendanceLoading = false;
    });
  }

  @override
  void dispose() {
    print("dispose");
    currentSiteSubscription?.cancel();
    super.dispose();
  }

  Widget _getSiteSelection() {
    return Container(
      height: 40,
      child: DropdownButtonFormField(
        items: siteItems,
        decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
            fillColor: Color(0xfff3f3f4),
            filled: true,
            hintText: 'Select Site'),
        onChanged: (newVal) async {
          print(newVal);
          setState(() {
            isAttendanceLoading = true;
          });
          assignWorkersList = new List<WorkerModel>();
          assignWorkersList.clear();
          workerAttendances = new List<AttendanceModel>();
          workerAttendances.clear();
          selectedSiteId = newVal;
          print("selectedSiteId::" + selectedSiteId);
          selectedSiteModel = await SiteService().getOne(selectedSiteId);

          _workerStatekey.currentState.didChange(null);
          _workerStatekey.currentState.reset();

          if (selectedSiteModel.assignWorkersId != null &&
              selectedSiteModel.assignWorkersId.length > 0) {
            assignWorkersList = await SiteService().getSiteWorkerList(
                selectedSiteId, selectedSiteModel.assignWorkersId);

            if (assignWorkersList.length > 0) {
              setState(() {
                workerItems = new List<DropdownMenuItem>();
                workerItems.clear();
                workerItems = null;

                workerItems = assignWorkersList
                    .map((w) => DropdownMenuItem(
                          child: Text(w.fname + " " + w.lname),
                          value: w.id,
                          onTap: () {},
                        ))
                    .toList();

                emptyStatus = "Please Select Worker";
                isAttendanceLoading = false;
              });
            } else {
              setState(() {
                emptyStatus = "Workers not found for selected site";
                isAttendanceLoading = false;
              });
            }
          } else {
            setState(() {
              workerItems = new List<DropdownMenuItem>();
              assignWorkersList = new List<WorkerModel>();
              assignWorkersList.clear();
              workerAttendances = new List<AttendanceModel>();
              workerAttendances.clear();
              emptyStatus = "Workers not found for selected site";
            });
          }

          setState(() {
            isAttendanceLoading = false;
          });

          ///loadSiteWorkerAttendanceList();
        },
      ),
    );
  }

  Widget _getWorkerSelection() {
    return Container(
      height: 40,
      child: DropdownButtonFormField(
        key: _workerStatekey,
        items: workerItems,
        decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
            fillColor: Color(0xfff3f3f4),
            filled: true,
            hintText: 'Select Worker'),
        onChanged: (newVal) async {
          print(newVal);

          setState(() {
            isAttendanceLoading = true;
            updateListAndSavePaymentBtn("C", null);
          });

          if (newVal != null) {
            selectedWorkerId = newVal;
            selectedWorkerModel =
                await WorkerService().getOne(selectedWorkerId);
            print("selectedWorkerId::" + selectedWorkerId);

            setState(() {
              workerAttendances = new List<AttendanceModel>();
            });
            List<AttendanceModel> amlist = await AttendanceService()
                .getAttendanceByWorkerId(selectedWorkerId);
            if (amlist.length > 0) {
              amlist.forEach((am) {
                setState(() {
                  workerAttendances.add(am);
                  isAttendanceLoading = false;
                });
              });
            } else {
              setState(() {
                workerAttendances = new List<AttendanceModel>();
                workerAttendances.clear();
                emptyStatus = "Attendance not found for selected worker";
                isAttendanceLoading = false;
              });
            }
          } else {
            setState(() {
              workerAttendances = new List<AttendanceModel>();
              workerAttendances.clear();
              emptyStatus = "Please select worker";
              isAttendanceLoading = false;
            });
          }
        },
      ),
    );
  }

  Widget _getPaymentDateTextField() {
    return Container(
      height: 40,
      child: TextFormField(
        controller: _paymentDateController,
        enableInteractiveSelection: false,
        focusNode: new AlwaysDisabledFocusNode(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Select Payment  Date',
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
              _paymentDateController.text =
                  DateFormat('dd-MM-yyyy').format(selectedDate);
              selectedPaymentDate = _paymentDateController.text;
              //loadSiteWorkerAttendanceList();
            }
          });
        },
        onChanged: (val) {
          //print('val::' + val);
          if (val.length >= 8) {
            RegExp dateRegex = new RegExp(
                r"^(((0[1-9]|[12]\d|3[01])\-(0[13578]|1[02])\-((19|[2-9]\d)\d{2}))|((0[1-9]|[12]\d|30)\-(0[13456789]|1[012])\-((19|[2-9]\d)\d{2}))|((0[1-9]|1\d|2[0-8])\-02\-((19|[2-9]\d)\d{2}))|(29\-02\-((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|(([1][26]|[2468][048]|[3579][26])00))))$");
            print("allMatches : " + dateRegex.hasMatch(val).toString());
            if (dateRegex.hasMatch(val)) {
              _paymentDateController.text = val;
            } else {
              _paymentDateController.text = '';
              _displaySnackBar(
                  context, 'E', 'Invalid Date', 'Please select valid date');
            }
            selectedPaymentDate = _paymentDateController.text;
          }

          if (_paymentDateController.text != '') {
            //loadSiteWorkerAttendanceList();
          }
        },
      ),
    );
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

  PreferredSizeWidget buildAppBarBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(160),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            _getSiteSelection(),
            SizedBox(
              height: 5,
            ),
            _getWorkerSelection(),
            SizedBox(
              height: 5,
            ),
            _getPaymentDateTextField(),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  Flushbar _displayProgressSnackBar(String title) {
    return Flushbar(
      title: title,
      message: 'Please Wait...',
      isDismissible: false,
      icon: Icon(
        Icons.query_builder,
        color: Colors.blue,
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
    );
  }

  Widget getBottomAppBar() {
    return Visibility(
      visible: isSaveBtnVisible,
      child: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Total Payment Has To Paid : ",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                totalPaymentHasToBePaid,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getFloatingButton() {
    return Visibility(
      visible: isSaveBtnVisible,
      child: FloatingActionButton.extended(
        elevation: 4.0,
        icon: Icon(Icons.done_all),
        label: Text("Save Payment"),
        onPressed: () {
          CoolAlert.show(
            context: context,
            type: CoolAlertType.confirm,
            text: "Are you sure want to save ?",
            confirmBtnText: "Yes",
            cancelBtnText: "No",
            confirmBtnColor: Colors.red,
            onConfirmBtnTap: () {
              Navigator.pop(context);
              confirmSavePayment();
            },
          );
        },
      ),
    );
  }

  confirmSavePayment() async {
    Flushbar flushbar = _displayProgressSnackBar(
        createUpdateFlag == 'C' ? 'Saving Attendance' : 'Updating Attendance');
    flushbar.show(context);
    Map result = await AttendanceService()
        .updateWorkersAttendancePaymentStatus(selectedAttendances);

    PaymentModel pm = new PaymentModel(
        null,
        new DateFormat("dd-MM-yyyy").parse(selectedPaymentDate),
        totalPaymentHasToBePaid,
        selectedWorkerId,
        WorkerService().getWorkerDocRef(selectedWorkerId));
    Map pResult = await PaymentService().savePayment(pm);
    flushbar.dismiss(true);
    if (result['status'] == 'success' && pResult['status'] == 'success') {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          text: result['msg'],
          barrierDismissible: false,
          onConfirmBtnTap: () {
            Navigator.pop(context);
            resetPage();
          });
    } else {
      _displaySnackBar(context, 'E', 'Failed', result['msg']);
    }
  }

  resetPage() {
    updateListAndSavePaymentBtn("C", null);
    setState(() {
      _paymentDateController = TextEditingController(
          text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
      selectedPaymentDate = _paymentDateController.text;
      _workerStatekey.currentState.didChange(null);
      _workerStatekey.currentState.reset();
    });
  }

  updateListAndSavePaymentBtn(String flag, Map<String, dynamic> attendanceMap) {
    setState(() {
      if (flag == "C") {
        selectedAttendances = new List<Map<String, dynamic>>();
        selectedAttendances.clear();
        isSaveBtnVisible = false;
        totalPaymentHasToBePaid = "0.00";
      } else {
        if (flag == "A") {
          selectedAttendances.add(attendanceMap);
        } else if (flag == "R") {
          selectedAttendances.remove(attendanceMap);
        }

        print("length:" + selectedAttendances.length.toString());

        if (selectedAttendances.length > 0) {
          isSaveBtnVisible = true;
          totalPaymentHasToBePaid = "0.00";
          selectedAttendances.forEach((map) {
            totalPaymentHasToBePaid = (double.parse(totalPaymentHasToBePaid) +
                    double.parse(map["amount"]))
                .toString();
          });
        } else {
          isSaveBtnVisible = false;
          totalPaymentHasToBePaid = "0.00";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: new Text('Worker Payment'),
        bottom: buildAppBarBottom(),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1280),
          child: isAttendanceLoading
              ? CircularProgressIndicator()
              : workerAttendances != null && workerAttendances.length > 0
                  ? WorkerPaymentListView(
                      attendances: workerAttendances,
                      selectedSiteModel: selectedSiteModel,
                      selectedWorkerModel: selectedWorkerModel,
                      selectedPaymentDate: selectedPaymentDate,
                      selectedAttendances: selectedAttendances,
                      callback: updateListAndSavePaymentBtn)
                  : EmptyPaymentListView(child: Text(emptyStatus)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: getFloatingButton(),
      bottomNavigationBar: getBottomAppBar(),
      // floatingActionButton: Visibility(
      //   visible: isSaveBtnVisible,
      //   child: FloatingActionButton.extended(
      //     backgroundColor:
      //         createUpdateFlag == 'C' ? Colors.blueAccent : Colors.orangeAccent,
      //     onPressed: () async {
      //       Flushbar flushbar = _displayProgressSnackBar(createUpdateFlag == 'C'
      //           ? 'Saving Attendance'
      //           : 'Updating Attendance');
      //       flushbar.show(context);

      //       Map result;
      //       // if (createUpdateFlag == 'C') {
      //       //   result = await AttendanceService()
      //       //       .createWorkersAttendance(selectedAttendances);
      //       // } else {
      //       //   result = await AttendanceService()
      //       //       .updateWorkersAttendance(selectedAttendances);
      //       // }

      //       flushbar.dismiss(true);
      //       if (result['status'] == 'success') {
      //         //loadSiteWorkerAttendanceList();
      //         _displaySnackBar(context, 'S', 'Success', result['msg']);
      //       } else {
      //         _displaySnackBar(context, 'E', 'Failed', result['msg']);
      //       }
      //     },
      //     label: Text(createUpdateFlag == 'C'
      //         ? 'Save Attendance'
      //         : 'Update Attendance'),
      //   ),
      // ),
    );
  }
}

class WorkerPaymentListView extends StatefulWidget {
  final List<AttendanceModel> _attendances;
  final WorkerModel selectedWorkerModel;
  final SiteModel selectedSiteModel;
  final String selectedPaymentDate;
  final List<Map<String, dynamic>> selectedAttendances;

  final UpdateListAndSavePaymentBtn callback;

  WorkerPaymentListView(
      {@required List<AttendanceModel> attendances,
      @required this.selectedSiteModel,
      @required this.selectedWorkerModel,
      @required this.selectedPaymentDate,
      @required this.selectedAttendances,
      this.callback})
      : _attendances = attendances;

  @override
  WorkerPaymentListViewState createState() => WorkerPaymentListViewState(
      attendances: _attendances,
      selectedSiteModel: selectedSiteModel,
      selectedWorkerModel: selectedWorkerModel,
      selectedPaymentDate: selectedPaymentDate,
      selectedAttendances: selectedAttendances,
      callback: callback);
}

class WorkerPaymentListViewState extends State<WorkerPaymentListView> {
  final List<AttendanceModel> _attendances;
  final SiteModel _selectedSiteModel;
  final WorkerModel _selectedWorkerModel;
  final String _selectedPaymentDate;
  final List<Map<String, dynamic>> _selectedAttendances;

  final UpdateListAndSavePaymentBtn callback;

  WorkerPaymentListViewState(
      {@required List<AttendanceModel> attendances,
      @required selectedSiteModel,
      @required selectedWorkerModel,
      @required selectedPaymentDate,
      @required selectedAttendances,
      this.callback})
      : _attendances = attendances,
        _selectedSiteModel = selectedSiteModel,
        _selectedWorkerModel = selectedWorkerModel,
        _selectedPaymentDate = selectedPaymentDate,
        _selectedAttendances = selectedAttendances;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          padding: EdgeInsets.only(top: 10),
          children: _attendances
              .map((a) =>
                  //print("WorkerAttendanceListViewState::" + w.toJson());
                  WorkerPaymentCard(
                    attendance: a,
                    selectedSiteModel: _selectedSiteModel,
                    selectedWorkerModel: _selectedWorkerModel,
                    selectedPaymentDate: _selectedPaymentDate,
                    selectedAttendances: _selectedAttendances,
                    callback: callback,
                  ))
              .toList()),
    );
  }
}

class WorkerPaymentCard extends StatefulWidget {
  final AttendanceModel attendance;
  final SiteModel selectedSiteModel;
  final WorkerModel selectedWorkerModel;
  final String selectedPaymentDate;
  final List<Map<String, dynamic>> selectedAttendances;
  final UpdateListAndSavePaymentBtn callback;

  WorkerPaymentCard(
      {this.attendance,
      this.selectedSiteModel,
      this.selectedWorkerModel,
      this.selectedPaymentDate,
      this.selectedAttendances,
      this.callback});
  @override
  WorkerPaymentCardState createState() => WorkerPaymentCardState(
      attendance: attendance,
      selectedSiteModel: selectedSiteModel,
      selectedWorkerModel: selectedWorkerModel,
      selectedPaymentDate: selectedPaymentDate,
      selectedAttendances: selectedAttendances,
      callback: callback);
}

class WorkerPaymentCardState extends State<WorkerPaymentCard> {
  final AttendanceModel attendance;
  final SiteModel selectedSiteModel;
  final WorkerModel selectedWorkerModel;
  final String selectedPaymentDate;
  final List<Map<String, dynamic>> selectedAttendances;
  final UpdateListAndSavePaymentBtn callback;
  WorkerPaymentCardState(
      {@required this.attendance,
      @required this.selectedSiteModel,
      @required this.selectedWorkerModel,
      @required this.selectedPaymentDate,
      @required this.selectedAttendances,
      @required this.callback});

  bool isChecked = false;

  Map<String, dynamic> attendanceMap = new Map();

  @override
  void initState() {
    super.initState();
  }

  getCheckBox() {
    return Checkbox(
      checkColor: Colors.white,
      activeColor: Colors.blue,
      value: isChecked,
      onChanged: (bool value) {
        setState(() {
          isChecked = value;
          if (value) {
            print("attendance::" + attendance.id);
            attendanceMap["id"] = attendance.id;
            attendanceMap["amount"] = attendance.paymentAmount;
            attendanceMap["status"] = "Paid";
            callback("A", attendanceMap);
          } else {
            callback("R", attendanceMap);
          }
        });
      },
    );
  }

  getDisabledCheckBox() {
    return Checkbox(
      checkColor: Colors.white,
      activeColor: Colors.blue,
      value: false,
      onChanged: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.only(bottom: 5, left: 12, right: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
      ),
      child: new Row(
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      double.parse(attendance.paymentAmount) != 0 &&
                              attendance.paymentStatus == 'Unpaid'
                          ? getCheckBox()
                          : getDisabledCheckBox(),
                      const SizedBox(width: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                "Attendance Date : ",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                DateFormat('dd-MM-yyyy')
                                    .format(attendance.attendanceDate),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Attendance Status : ",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                attendance.attendanceStatus,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: attendance.attendanceStatus == 'Absent'
                                      ? Colors.redAccent
                                      : attendance.attendanceStatus ==
                                              'Half Day'
                                          ? Colors.orangeAccent
                                          : Colors.greenAccent,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Payment Status : ",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                attendance.attendanceStatus == "Absent"
                                    ? "Not Payable"
                                    : attendance.paymentStatus,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: attendance.paymentStatus == 'Unpaid'
                                      ? Colors.redAccent
                                      : Colors.greenAccent,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      Text(
                        "Rs. " + attendance.paymentAmount,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: attendance.paymentStatus == 'Paid' ||
                                  attendance.attendanceStatus == "Absent"
                              ? Colors.grey[500]
                              : Colors.redAccent,
                        ),
                      )
                    ],
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

class EmptyPaymentListView extends StatelessWidget {
  final Widget child;
  EmptyPaymentListView({this.child});
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
