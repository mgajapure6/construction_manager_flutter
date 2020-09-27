import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moduler_flutter_app/modules/dashboard/screens/dashboard.dart';
import 'package:moduler_flutter_app/modules/home/screens/home.dart';
import 'package:moduler_flutter_app/modules/login/screens/loginPage.dart';
import 'package:moduler_flutter_app/modules/login/screens/signup.dart';

import 'package:moduler_flutter_app/modules/login/screens/welcomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moduler_flutter_app/modules/login/services/auth.dart';
import 'package:moduler_flutter_app/modules/site/screens/siteForm.dart';
import 'package:moduler_flutter_app/modules/site/screens/siteList.dart';
import 'package:provider/provider.dart';

//void main() => runApp(MyApp());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
