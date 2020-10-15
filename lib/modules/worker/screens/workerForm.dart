import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moduler_flutter_app/modules/dashboard/screens/dashboard.dart';
import 'package:moduler_flutter_app/modules/login/services/auth.dart';
import 'package:moduler_flutter_app/modules/worker/models/workerModel.dart';
import 'package:moduler_flutter_app/modules/worker/services/workerService.dart';
import 'package:moduler_flutter_app/utilities/DecimalTextInputFormatter.dart';

import 'package:moduler_flutter_app/utilities/widgets/bezierContainer.dart';
import 'package:moduler_flutter_app/modules/login/screens/loginPage.dart';

class WorkerFromPage extends StatefulWidget {
  final String flag;
  final WorkerModel workerModel;
  WorkerFromPage({@required this.flag, this.workerModel});

  @override
  _WorkerFromPageState createState() => _WorkerFromPageState();
}

class _WorkerFromPageState extends State<WorkerFromPage> {
  TextEditingController _workStartDateController;
  TextEditingController _workEndDateController;
  TextEditingController _fnameController;
  TextEditingController _lnameController;
  TextEditingController _mnameController;
  TextEditingController _genderController;
  TextEditingController _ageController;

  TextEditingController _dobController;
  TextEditingController _mobileController;
  TextEditingController _idNumberController;
  TextEditingController _paymentPerDayController;
  TextEditingController _paymentHalfDayController;
  TextEditingController _paymentPerMonthController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.flag == 'M') {
      _workStartDateController =
          TextEditingController(text: widget.workerModel.workStartDate);
      _workEndDateController =
          TextEditingController(text: widget.workerModel.workEndDate);
      _fnameController = TextEditingController(text: widget.workerModel.fname);
      _lnameController = TextEditingController(text: widget.workerModel.lname);
      _mnameController = TextEditingController(text: widget.workerModel.mname);
      _genderController =
          TextEditingController(text: widget.workerModel.gender);
      _ageController = TextEditingController(text: widget.workerModel.age);

      _dobController = TextEditingController(text: widget.workerModel.dob);
      _mobileController =
          TextEditingController(text: widget.workerModel.mobile);
      _idNumberController =
          TextEditingController(text: widget.workerModel.idNumber);

      _paymentPerDayController =
          TextEditingController(text: widget.workerModel.paymentPerDay);
      _paymentHalfDayController =
          TextEditingController(text: widget.workerModel.paymentPerHalfDay);
      _paymentPerMonthController =
          TextEditingController(text: widget.workerModel.paymentPerMonth);
    } else {
      _workStartDateController = TextEditingController(text: '');
      _workEndDateController = TextEditingController(text: '');
      _fnameController = TextEditingController(text: '');
      _lnameController = TextEditingController(text: '');
      _mnameController = TextEditingController(text: '');
      _genderController = TextEditingController(text: '');
      _ageController = TextEditingController(text: '');
      _dobController = TextEditingController(text: '');
      _mobileController = TextEditingController(text: '');
      _idNumberController = TextEditingController(text: '');
      _paymentPerDayController = TextEditingController(text: '');
      _paymentHalfDayController = TextEditingController(text: '');
      _paymentPerMonthController = TextEditingController(text: '');
    }
  }

  Widget _getFNameTextField() {
    return TextFormField(
      controller: _fnameController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter worker first name';
        }
        return null;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Worker First Name'),
      // onChanged: (val) async {
      //   setState(() {
      //     workerName = val;
      //   });
    );
  }

  Widget _getLNameTextField() {
    return TextFormField(
      controller: _lnameController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter worker last name';
        }
        return null;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Worker Last Name'),
      // onChanged: (val) async {
      //   setState(() {
      //     workerName = val;
      //   });
    );
  }

  Widget _getMNameTextField() {
    return TextFormField(
      controller: _mnameController,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Worker Middle Name'),
      // onChanged: (val) async {
      //   setState(() {
      //     workerName = val;
      //   });
    );
  }

  Widget _getWorkStartDateTextField() {
    return TextFormField(
        controller: _workStartDateController,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please select worker start date';
          }
          return null;
        },
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            fillColor: Color(0xfff3f3f4),
            filled: true,
            hintText: 'Select Worker Start  Date'),
        onTap: () {
          showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1901, 1),
              lastDate: DateTime(2099, 12),
              builder: (BuildContext context, Widget picker) {
                return Theme(
                  data: ThemeData.light(),
                  child: picker,
                );
              }).then((selectedDate) {
            if (selectedDate != null) {
              _workStartDateController.text =
                  DateFormat('dd-MM-yyyy').format(selectedDate);
            }
          });
        });
  }

  Widget _getWorkEndDateTextField() {
    return TextFormField(
      controller: _workEndDateController,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Select Worker End  Date'),
      onTap: () {
        showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1901, 1),
            lastDate: DateTime(2099, 12),
            builder: (BuildContext context, Widget picker) {
              return Theme(
                data: ThemeData.light(),
                child: picker,
              );
            }).then((selectedDate) {
          if (selectedDate != null) {
            _workEndDateController.text =
                DateFormat('dd-MM-yyyy').format(selectedDate);
          }
        });
      },
    );
  }

  Widget _getGenderTextField() {
    return TextFormField(
      controller: _genderController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please select gender';
        }
        return null;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Select Gender'),
    );
  }

  Widget _getDOBTextField() {
    return TextFormField(
      controller: _dobController,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Select Worker Date Of Birth'),
      onTap: () {
        showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1901, 1),
            lastDate: DateTime(2099, 12),
            builder: (BuildContext context, Widget picker) {
              return Theme(
                data: ThemeData.light(),
                child: picker,
              );
            }).then((selectedDate) {
          if (selectedDate != null) {
            _dobController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
          }
        });
      },
    );
  }

  Widget _getPerDayPaymentTextField() {
    return TextFormField(
      controller: _paymentPerDayController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter worker per day payment';
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Per Day Payment'),
    );
  }

  Widget _getPerHalfDayPaymentTextField() {
    return TextFormField(
      controller: _paymentHalfDayController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter worker half day payment';
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Half Day Payment'),
    );
  }

  Widget _getPerMonthPaymentTextField() {
    return TextFormField(
      controller: _paymentPerMonthController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter worker per month payment';
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Per Month Payment'),
    );
  }

  Widget _getIDProofNumberTextField() {
    return TextFormField(
      controller: _idNumberController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Worker ID Proof Number'),
    );
  }

  Widget _getMobileTextField() {
    return TextFormField(
      controller: _mobileController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter worker mobile number';
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Worker Mobile Number'),
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

  _displaySnackBar(String type, String title, String text) {
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

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          Flushbar flushbar = _displayProgressSnackBar('Saving Worker');
          flushbar.show(context);
          Map result;
          if (widget.flag == 'M') {
            result = WorkerService().updateWorker(
                WorkerModel.withoutCreate(
                    _workStartDateController.text,
                    _workEndDateController.text,
                    _fnameController.text,
                    _lnameController.text,
                    _mnameController.text,
                    _genderController.text,
                    _ageController.text,
                    _dobController.text,
                    _mobileController.text,
                    _idNumberController.text,
                    _paymentPerDayController.text,
                    _paymentHalfDayController.text,
                    _paymentPerMonthController.text,
                    widget.workerModel.workingStatus,
                    widget.workerModel.isFree,
                    widget.workerModel.photoUrl,
                    DateFormat('dd-MM-yyyy').format(new DateTime.now()),
                    widget.workerModel.updatedBy),
                widget.workerModel.id);
          } else {
            result = WorkerService().createWorker(WorkerModel(
                _workStartDateController.text,
                _workEndDateController.text,
                _fnameController.text,
                _lnameController.text,
                _mnameController.text,
                _genderController.text,
                _ageController.text,
                _dobController.text,
                _mobileController.text,
                _idNumberController.text,
                _paymentPerDayController.text,
                _paymentHalfDayController.text,
                _paymentPerMonthController.text,
                'Not Working',
                true,
                null,
                DateFormat('dd-MM-yyyy').format(new DateTime.now()),
                null,
                DateFormat('dd-MM-yyyy').format(new DateTime.now()),
                null));
          }

          print("result" + result.toString());

          if (result['status'] == 'success') {
            flushbar.dismiss(true);
            _formKey.currentState.reset();
            _workStartDateController.clear();
            _workEndDateController.clear();
            _fnameController.clear();
            _lnameController.clear();
            _mnameController.clear();
            _genderController.clear();
            _ageController.clear();
            _dobController.clear();
            _mobileController.clear();
            _idNumberController.clear();
            _paymentPerDayController.clear();
            _paymentHalfDayController.clear();
            _paymentPerMonthController.clear();
            _displaySnackBar('S', 'Success', result['msg']);
          } else {
            flushbar.dismiss(true);
            _displaySnackBar('E', 'Failed', result['msg']);
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2),
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)]),
        ),
        child: Text(
          'Save Worker',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: widget.flag == 'N' ? 'Create New Worker' : 'Update Worker',
          style: TextStyle(color: Colors.black, fontSize: 30)),
    );
  }

  Widget _formWidget() {
    return Column(
      children: <Widget>[
        //_selectField('workerType', "Worker Type", ["A", "B"]),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'First Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getFNameTextField(),
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Last Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getLNameTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Middle Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getMNameTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Work Start Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getWorkStartDateTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Work End Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getWorkEndDateTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Gender',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getGenderTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Date Of Birth',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getDOBTextField()
              ]),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Mobile Number',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getMobileTextField()
              ]),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ID Proof Number',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getIDProofNumberTextField()
              ]),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Payment For Full Day',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getPerDayPaymentTextField()
              ]),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Payment For Half Day',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getPerHalfDayPaymentTextField()
              ]),
        ),
      ],
    );
  }

  Widget _getAvatarWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircularProfileAvatar(
            null,
            child: Icon(
              FontAwesomeIcons.user,
              size: 100,
              color: Colors.grey[300],
            ),
            borderColor: Colors.grey[300],
            borderWidth: 3,
            elevation: 5,
            radius: 75,
          ),
          SizedBox(
            height: 15,
          ),
          RaisedButton.icon(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              onPressed: () {},
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0))),
              label: Text(
                'Upload Image',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
              textColor: Colors.white,
              splashColor: Colors.red,
              color: Colors.lightBlue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          leading: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          //elevation: 2,
          //iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            widget.flag == 'N' ? 'Add Worker' : 'Update Worker',
          )),
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: height * .05),
                      _getAvatarWidget(),
                      SizedBox(
                        height: 10,
                      ),
                      _formWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      _submitButton(),
                      SizedBox(height: height * .14),
                    ],
                  ),
                ),
              ),
            ),
            //Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
