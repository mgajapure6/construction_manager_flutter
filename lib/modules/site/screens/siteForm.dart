import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moduler_flutter_app/modules/dashboard/screens/dashboard.dart';
import 'package:moduler_flutter_app/modules/login/services/auth.dart';

import 'package:moduler_flutter_app/utilities/widgets/bezierContainer.dart';
import 'package:moduler_flutter_app/modules/login/screens/loginPage.dart';

class SiteFromPage extends StatefulWidget {
  SiteFromPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SiteFromPageState createState() => _SiteFromPageState();
}

class _SiteFromPageState extends State<SiteFromPage> {
  final AuthService _authService = AuthService();

  TextEditingController _dateController;

  final _formKey = GlobalKey<FormState>();

  String siteType = '';
  String siteName = '';
  String siteStartDate = '';
  String siteEndDate = '';
  String siteOwnerName = '';
  String siteBudget = '';
  String sitePhoto = '';
  String siteCreateDate = '';
  String siteUpdateDate = '';
  String siteCreatedBy = '';

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _textField(String type, String title, {bool isRequired = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            validator: (value) {
              if (isRequired && value.isEmpty) {
                return 'Please enter ' + title.toLowerCase();
              }
              return null;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                fillColor: Color(0xfff3f3f4),
                filled: true,
                hintText: 'Enter Your ' + title),
            onChanged: (val) async {
              if (type == 'siteName') {
                setState(() {
                  siteName = val;
                });
              } else if (type == 'siteOwnerName') {
                setState(() {
                  siteOwnerName = val;
                });
              } else if (type == 'siteBudget') {
                setState(() {
                  siteBudget = val;
                });
              } else if (type == 'siteCreatedBy') {
                setState(() {
                  siteCreatedBy = val;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _selectField(String type, String title, dataList,
      {bool isRequired = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          InputDecorator(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                fillColor: Color(0xfff3f3f4),
                filled: true,
                hintText: 'Select ' + title),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                isDense: true,
                validator: (value) {
                  if (isRequired && value.isEmpty) {
                    return 'Please select ' + title.toLowerCase();
                  }
                  return null;
                },
                onChanged: (val) async {
                  if (type == 'siteType') {
                    setState(() {
                      siteType = val;
                    });
                  }
                },
                items: dataList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  String siteType = '';
  // String siteName = '';
  // String siteStartDate = '';
  // String siteEndDate = '';
  // String siteOwnerName = '';
  // String siteBudget = '';
  // String sitePhoto = '';
  // String siteCreateDate = '';
  // String siteUpdateDate = '';
  // String siteCreatedBy = '';

  Widget _datePickerField(String type, String title,
      {bool isRequired = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _dateController,
            validator: (value) {
              if (isRequired && value.isEmpty) {
                return 'Please select ' + title.toLowerCase();
              }
              return null;
            },
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
                  _dateController.text =
                      DateFormat('dd-MM-yyyy').format(selectedDate);
                }
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                fillColor: Color(0xfff3f3f4),
                filled: true,
                hintText: 'Select ' + title),
            onChanged: (val) async {
              if (type == 'siteStartDate') {
                setState(() {
                  siteStartDate = val;
                });
              } else if (type == 'siteEndDate') {
                setState(() {
                  siteEndDate = val;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Flushbar _displayProgressSnackBar() {
    return Flushbar(
      title: 'Logging You',
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
          Flushbar flushbar = _displayProgressSnackBar();
          flushbar.show(context);
        }

        //Future<Map> result = _authService.createUser(username, email, password);
        // result.then((value) {
        //   if (value['status'] == 'failed') {
        //     flushbar.dismiss(true);
        //     _displaySnackBar('E', 'Failed', value['msg']);
        //     //Navigator.push(
        //     // context, MaterialPageRoute(builder: (context) => Dashboard()));
        //   } else {}
        // });
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
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          'Save Site',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Create New Site',
          style: TextStyle(color: Colors.black, fontSize: 30)),
    );
  }

  Widget _formWidget() {
    return Column(
      children: <Widget>[
        //_selectField('siteType', "Site Type", ["A", "B"]),
        _textField('siteName', "Site Name", isRequired: true),
        _datePickerField('siteStartDate', "Start Date", isRequired: true),
        _datePickerField('siteEndDate', "End Date", isRequired: true),
        _textField('siteOwnerName', "Owner Name", isRequired: true),
        _textField('siteBudget', "Site Budget", isRequired: true),
      ],
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Add Site',
            style: TextStyle(color: Colors.black),
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
                      _title(),
                      SizedBox(
                        height: 50,
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
