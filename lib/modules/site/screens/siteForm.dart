import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moduler_flutter_app/modules/dashboard/screens/dashboard.dart';
import 'package:moduler_flutter_app/modules/login/services/auth.dart';
import 'package:moduler_flutter_app/modules/site/models/siteModel.dart';
import 'package:moduler_flutter_app/modules/site/services/siteService.dart';
import 'package:moduler_flutter_app/utilities/DecimalTextInputFormatter.dart';

import 'package:moduler_flutter_app/utilities/widgets/bezierContainer.dart';
import 'package:moduler_flutter_app/modules/login/screens/loginPage.dart';

class SiteFromPage extends StatefulWidget {
  final String flag;
  final SiteModel siteModel;
  SiteFromPage({@required this.flag, this.siteModel});

  @override
  _SiteFromPageState createState() => _SiteFromPageState();
}

class _SiteFromPageState extends State<SiteFromPage> {
  TextEditingController _startDateController;
  TextEditingController _endDateController;
  TextEditingController _siteTypeController;
  TextEditingController _siteNameController;
  TextEditingController _siteOwnerNameController;
  TextEditingController _siteBudgetController;
  TextEditingController _statusController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.flag == 'M') {
      _startDateController =
          TextEditingController(text: widget.siteModel.siteStartDate);
      _endDateController =
          TextEditingController(text: widget.siteModel.siteEndDate);
      _siteTypeController =
          TextEditingController(text: widget.siteModel.siteType);
      _siteNameController =
          TextEditingController(text: widget.siteModel.siteName);
      _siteOwnerNameController =
          TextEditingController(text: widget.siteModel.siteOwnerName);
      _siteBudgetController =
          TextEditingController(text: widget.siteModel.siteBudget);
      _statusController = TextEditingController(text: widget.siteModel.status);
    } else {
      _startDateController = TextEditingController(text: '');
      _endDateController = TextEditingController(text: '');
      _siteTypeController = TextEditingController(text: '');
      _siteNameController = TextEditingController(text: '');
      _siteOwnerNameController = TextEditingController(text: '');
      _siteBudgetController = TextEditingController(text: '');
      _statusController = TextEditingController(text: '');
    }
  }

  Widget _getSiteNameTextField() {
    return TextFormField(
      controller: _siteNameController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter site name';
        }
        return null;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Site Name'),
      // onChanged: (val) async {
      //   setState(() {
      //     siteName = val;
      //   });
    );
  }

  Widget _getStartDateTextField() {
    return TextFormField(
        controller: _startDateController,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please select site start date';
          }
          return null;
        },
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            fillColor: Color(0xfff3f3f4),
            filled: true,
            hintText: 'Select Site Start  Date'),
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
              _startDateController.text =
                  DateFormat('dd-MM-yyyy').format(selectedDate);
            }
          });
        });
  }

  Widget _getEndDateTextField() {
    return TextFormField(
      controller: _endDateController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please select site end date';
        }
        return null;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Select Site End  Date'),
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
            _endDateController.text =
                DateFormat('dd-MM-yyyy').format(selectedDate);
          }
        });
      },
    );
  }

  Widget _getSiteOwnerNameTextField() {
    return TextFormField(
      controller: _siteOwnerNameController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter site owner name';
        }
        return null;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Site Owner Name'),
    );
  }

  Widget _getSiteBudgetTextField() {
    return TextFormField(
      controller: _siteBudgetController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter site budget';
        }
        return null;
      },
      keyboardType:
          TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          hintText: 'Enter Site Budget'),
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
          Flushbar flushbar = _displayProgressSnackBar('Saving Site');
          flushbar.show(context);
          Map result;
          if (widget.flag == 'M') {
            result = SiteService().updateSite(
                SiteModel.withoutCreate(
                    _siteTypeController.text,
                    _siteNameController.text,
                    _startDateController.text,
                    _endDateController.text,
                    _siteOwnerNameController.text,
                    _siteBudgetController.text,
                    null,
                    widget.siteModel.status,
                    DateFormat('dd-MM-yyyy').format(new DateTime.now()),
                    null),
                widget.siteModel.id);
          } else {
            result = SiteService().createSite(SiteModel(
                _siteTypeController.text,
                _siteNameController.text,
                _startDateController.text,
                _endDateController.text,
                _siteOwnerNameController.text,
                _siteBudgetController.text,
                null,
                'Active',
                DateFormat('dd-MM-yyyy').format(new DateTime.now()),
                DateFormat('dd-MM-yyyy').format(new DateTime.now()),
                null,
                null));
          }

          print("result" + result.toString());

          if (result['status'] == 'success') {
            flushbar.dismiss(true);
            _formKey.currentState.reset();
            _startDateController.clear();
            _endDateController.clear();
            _siteBudgetController.clear();
            _siteNameController.clear();
            _siteOwnerNameController.clear();
            _siteTypeController.clear();
            _statusController.clear();
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
          text: widget.flag == 'N' ? 'Create New Site' : 'Update Site',
          style: TextStyle(color: Colors.black, fontSize: 30)),
    );
  }

  Widget _formWidget() {
    return Column(
      children: <Widget>[
        //_selectField('siteType', "Site Type", ["A", "B"]),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Site Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getSiteNameTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Start Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getStartDateTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'End Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getEndDateTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Owner Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getSiteOwnerNameTextField()
              ]),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Site Budget',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                _getSiteBudgetTextField()
              ]),
        ),
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
            widget.flag == 'N' ? 'Add Site' : 'Update Site',
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
