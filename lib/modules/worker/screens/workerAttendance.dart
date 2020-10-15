import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:intl/intl.dart';
import 'package:moduler_flutter_app/modules/site/models/siteModel.dart';
import 'package:moduler_flutter_app/modules/site/services/siteService.dart';
import 'package:moduler_flutter_app/modules/worker/models/attendanceModel.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/services/attendanceService.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';

class WorkerAttendance extends StatefulWidget {
  @override
  WorkerAttendanceState createState() => WorkerAttendanceState();
}

class WorkerAttendanceState extends State<WorkerAttendance> {
  StreamSubscription<QuerySnapshot> currentSiteSubscription;
  TextEditingController _attendanceDateController;
  List<DropdownMenuItem> items = [];
  List<SiteModel> sites = <SiteModel>[];
  bool isAttendanceLoading = true;
  List<WorkerModel> assignWorkers = [];
  bool isSaveBtnVisible = false;

  List<AttendanceModel> selectedAttendances = <AttendanceModel>[];

  String selectedSiteId;
  SiteModel selectedSiteModel;
  String selectedAttendanceDate;
  String createUpdateFlag;

  @override
  void initState() {
    super.initState();
    _attendanceDateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    currentSiteSubscription = SiteService().loadAllSites().listen(updateSites);
    selectedAttendanceDate = _attendanceDateController.text;
    print('selectedAttendanceDate::' + selectedAttendanceDate);

    // Future<List<AttendanceModel>> aml =
    //     AttendanceService().getAttendanceByWorkerId("qqgcLGVmc7tFO0KxZCJi");
    // aml.then((value) {
    //   value.forEach((element) {
    //     WorkerModel wm;
    //     element.workerRef.get().then((doc) {
    //       wm = new WorkerModel.fromSnapshot(doc);
    //       print("wm1::" + wm.fname);
    //     });
    //     //print("wm1::" + wm.fname);
    //     print("aml2::" + element.workerRef.toString());
    //   });
    // });
  }

  void updateSites(QuerySnapshot snapshot) {
    setState(() {
      sites = SiteService().getActiveSites(snapshot);
      items = sites
          .map((site) =>
              DropdownMenuItem(child: Text(site.siteName), value: site.id))
          .toList();
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
    return DropdownButtonFormField(
      items: items,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Select Site'),
      onChanged: (newVal) async {
        print(newVal);
        setState(() {
          isAttendanceLoading = true;
        });
        selectedSiteId = newVal;
        selectedSiteModel = await SiteService().getOne(newVal);
        //SiteService().loadAssignedWorkers(newVal).listen(loadSiteWorkerList);
        print('selectedAttendanceDate2::' + selectedAttendanceDate);
        setState(() {
          isAttendanceLoading = false;
        });
        loadSiteWorkerAttendanceList();
      },
    );
  }

  getWorkerModel(DocumentReference workerRef) async {
    return await workerRef.get().then((doc) {
      return new WorkerModel.fromSnapshot(doc);
    });
  }

  loadSiteWorkerAttendanceList() async {
    setState(() {
      isAttendanceLoading = true;
      isSaveBtnVisible = false;
    });

    if (_attendanceDateController.text != null &&
        _attendanceDateController.text.isNotEmpty &&
        selectedSiteId != null &&
        selectedSiteId != '') {
      int count = await AttendanceService().getAttendanceCountBySiteAndDate(
          selectedSiteId, _attendanceDateController.text);

      List<WorkerModel> list = [];

      if (count > 0) {
        //updating attendance
        createUpdateFlag = 'U';
        print('updating attendance');

        List<AttendanceModel> attendances = await AttendanceService()
            .getAttendanceBySiteAndDate(
                selectedSiteId, _attendanceDateController.text);

        createUpdateFlag = createUpdateFlag;
        assignWorkers.clear();
        selectedAttendances.clear();
        print('assignWorkers length1::' + assignWorkers.length.toString());

        attendances.forEach((am) async {
          print(1);
          print("attendance::" + am.workerRef.toString());
          WorkerModel wm = await getWorkerModel(am.workerRef);
          print(2);
          setState(() {
            WorkerModel wm1 = new WorkerModel.attendanceModel(
              am.id,
              wm.id,
              wm.fname,
              wm.mname,
              wm.lname,
              wm.photoUrl == null ? "" : wm.photoUrl,
              wm.paymentPerDay,
              wm.paymentPerHalfDay,
              am.paymentStatus,
              am.attendanceStatus,
            );
            print("WorkerModel::" + wm1.photoUrl);

            assignWorkers.add(wm1);
            print('assignWorkers length2::' + assignWorkers.length.toString());

            if (assignWorkers.length > 0) {
              isSaveBtnVisible = true;
            } else {
              isSaveBtnVisible = false;
            }

            isAttendanceLoading = false;
          });
          print(3);
        });
      } else {
        //new attendance
        createUpdateFlag = 'C';
        print('new attendance');
        print(' selectedSiteModel.assignWorkersId:;' +
            selectedSiteModel.assignWorkersId.toString());
        list = selectedSiteModel.assignWorkersId == null
            ? new List<WorkerModel>()
            : await SiteService().getSiteWorkerList(
                selectedSiteId, selectedSiteModel.assignWorkersId);

        setState(() {
          createUpdateFlag = createUpdateFlag;
          assignWorkers.clear();
          selectedAttendances.clear();
          print('assignWorkers length::' + assignWorkers.length.toString());
          list.forEach((element) {
            assignWorkers.add(element);
          });
          if (assignWorkers.length > 0) {
            isSaveBtnVisible = true;
          } else {
            isSaveBtnVisible = false;
          }

          isAttendanceLoading = false;
        });
      }
    } else {
      setState(() {
        isAttendanceLoading = false;
      });
    }
  }

  Widget _getAttendanceDateTextField() {
    return TextFormField(
      controller: _attendanceDateController,
      enableInteractiveSelection: false,
      focusNode: new AlwaysDisabledFocusNode(),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
        fillColor: Color(0xfff3f3f4),
        filled: true,
        hintText: 'Select Attendance  Date',
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
            _attendanceDateController.text =
                DateFormat('dd-MM-yyyy').format(selectedDate);
            selectedAttendanceDate = _attendanceDateController.text;
            loadSiteWorkerAttendanceList();
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
            _attendanceDateController.text = val;
          } else {
            _attendanceDateController.text = '';
            _displaySnackBar(
                context, 'E', 'Invalid Date', 'Please select valid date');
          }
          selectedAttendanceDate = _attendanceDateController.text;
        }

        if (_attendanceDateController.text != '') {
          loadSiteWorkerAttendanceList();
        }
      },
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
      preferredSize: Size.fromHeight(150),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            _getSiteSelection(),
            SizedBox(
              height: 10,
            ),
            _getAttendanceDateTextField(),
            SizedBox(
              height: 10,
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
        title: new Text('Worker Attendance'),
        bottom: buildAppBarBottom(),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1280),
          child: isAttendanceLoading
              ? CircularProgressIndicator()
              : assignWorkers != null && assignWorkers.length > 0
                  ? WorkerAttendanceListView(
                      workers: assignWorkers,
                      selectedAttendances: selectedAttendances,
                      selectedSiteModel: selectedSiteModel,
                      selectedAttendanceDate: selectedAttendanceDate)
                  : EmptyAttendanceListView(
                      child: Text('No Workers Found For This Site !')),
        ),
      ),
      floatingActionButton: Visibility(
        visible: isSaveBtnVisible,
        child: FloatingActionButton.extended(
          backgroundColor:
              createUpdateFlag == 'C' ? Colors.blueAccent : Colors.orangeAccent,
          onPressed: () async {
            Flushbar flushbar = _displayProgressSnackBar(createUpdateFlag == 'C'
                ? 'Saving Attendance'
                : 'Updating Attendance');
            flushbar.show(context);

            Map result;
            if (createUpdateFlag == 'C') {
              result = await AttendanceService()
                  .createWorkersAttendance(selectedAttendances);
            } else {
              result = await AttendanceService()
                  .updateWorkersAttendance(selectedAttendances);
            }

            flushbar.dismiss(true);
            if (result['status'] == 'success') {
              loadSiteWorkerAttendanceList();
              _displaySnackBar(context, 'S', 'Success', result['msg']);
            } else {
              _displaySnackBar(context, 'E', 'Failed', result['msg']);
            }
          },
          label: Text(createUpdateFlag == 'C'
              ? 'Save Attendance'
              : 'Update Attendance'),
        ),
      ),
    );
  }
}

class WorkerAttendanceListView extends StatefulWidget {
  final List<WorkerModel> _workers;
  final List<AttendanceModel> selectedAttendances;
  final SiteModel selectedSiteModel;
  final String selectedAttendanceDate;
  WorkerAttendanceListView(
      {@required List<WorkerModel> workers,
      @required this.selectedAttendances,
      @required this.selectedSiteModel,
      @required this.selectedAttendanceDate})
      : _workers = workers;

  @override
  WorkerAttendanceListViewState createState() => WorkerAttendanceListViewState(
      workers: _workers,
      selectedAttendances: selectedAttendances,
      selectedSiteModel: selectedSiteModel,
      selectedAttendanceDate: selectedAttendanceDate);
}

class WorkerAttendanceListViewState extends State<WorkerAttendanceListView> {
  final List<WorkerModel> _workers;
  final List<AttendanceModel> _selectedAttendances;
  final SiteModel _selectedSiteModel;
  final String _selectedAttendanceDate;
  WorkerAttendanceListViewState(
      {@required List<WorkerModel> workers,
      @required selectedAttendances,
      @required selectedSiteModel,
      @required selectedAttendanceDate})
      : _workers = workers,
        _selectedAttendances = selectedAttendances,
        _selectedSiteModel = selectedSiteModel,
        _selectedAttendanceDate = selectedAttendanceDate;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          padding: EdgeInsets.only(top: 10),
          children: _workers
              .map((w) =>
                  //print("WorkerAttendanceListViewState::" + w.toJson());
                  WorkerAttendanceCard(
                      worker: w,
                      selectedAttendances: _selectedAttendances,
                      selectedSiteModel: _selectedSiteModel,
                      selectedAttendanceDate: _selectedAttendanceDate))
              .toList()),
    );
  }
}

class WorkerAttendanceCard extends StatefulWidget {
  final WorkerModel worker;
  final List<AttendanceModel> selectedAttendances;
  final SiteModel selectedSiteModel;
  final String selectedAttendanceDate;
  WorkerAttendanceCard(
      {this.worker,
      this.selectedAttendances,
      this.selectedSiteModel,
      this.selectedAttendanceDate});
  @override
  WorkerAttendanceCardState createState() => WorkerAttendanceCardState(
        worker: worker,
        selectedAttendances: selectedAttendances,
        selectedSiteModel: selectedSiteModel,
        selectedAttendanceDate: selectedAttendanceDate,
      );
}

class WorkerAttendanceCardState extends State<WorkerAttendanceCard> {
  final WorkerModel worker;
  final List<AttendanceModel> selectedAttendances;
  final SiteModel selectedSiteModel;
  final String selectedAttendanceDate;
  WorkerAttendanceCardState({
    @required this.worker,
    @required this.selectedAttendances,
    @required this.selectedSiteModel,
    @required this.selectedAttendanceDate,
  });
  List<String> _astatus = ["Present", "Absent", "Half Day"];

  String selectedAttendanceStatus;

  AttendanceModel attendanceModel;

  @override
  void initState() {
    super.initState();
    print("selectedAttendanceDate3::" + selectedAttendanceDate);
    selectedAttendanceStatus = _astatus[0];
    selectedAttendanceStatus =
        worker.attendanceStatus == null ? 'Present' : worker.attendanceStatus;
    attendanceModel = AttendanceModel(
        worker.attendanceId,
        new DateFormat("dd-MM-yyyy").parse(selectedAttendanceDate),
        selectedAttendanceStatus,
        worker.id,
        worker.paidStatus != null ? worker.paidStatus : 'Unpaid',
        selectedSiteModel.id,
        selectedAttendanceStatus == "Present"
            ? worker.paymentPerDay
            : selectedAttendanceStatus == "Absent"
                ? "0.00"
                : worker.paymentPerHalfDay);

    selectedAttendances.add(attendanceModel);
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: worker.photoUrl == null || worker.photoUrl == ""
                  ? AssetImage('assets/images/worker.png')
                  : NetworkImage(worker.photoUrl),
              fit: BoxFit.cover,
            )),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Text(
                      worker.fname + ' ' + worker.mname + ' ' + worker.lname,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ]),
                  Divider(color: Colors.grey[100]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RadioButtonGroup(
                        orientation: GroupedButtonsOrientation.HORIZONTAL,
                        margin: EdgeInsets.all(0),
                        onSelected: (String selected) {
                          setState(() {
                            selectedAttendanceStatus = selected;
                          });
                          attendanceModel.attendanceStatus = selected;
                          attendanceModel.paymentAmount =
                              selectedAttendanceStatus == "Present"
                                  ? worker.paymentPerDay
                                  : selectedAttendanceStatus == "Absent"
                                      ? "0.00"
                                      : worker.paymentPerHalfDay;
                          selectedAttendances[selectedAttendances
                              .indexOf(attendanceModel)] = attendanceModel;
                          print(selectedAttendances.toString());
                        },
                        labels: _astatus,
                        picked: selectedAttendanceStatus,
                        itemBuilder: (Radio rb, Text txt, int i) {
                          return Row(
                            children: <Widget>[
                              rb,
                              txt,
                            ],
                          );
                        },
                      ),
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

class EmptyAttendanceListView extends StatelessWidget {
  final Widget child;
  EmptyAttendanceListView({this.child});
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
