import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moduler_flutter_app/modules/site/models/siteModel.dart';

abstract class BaseSiteService {
  Map creatSite(SiteModel site);
  Future<void> updateSite();
  Future<String> deleteSite();
  Future<bool> fetchSites();
}

class SiteService implements BaseSiteService {
  final CollectionReference siteCollectionRef =
      FirebaseFirestore.instance.collection('site');

  @override
  Map creatSite(SiteModel site) {
    var responseMap = new Map();
    try {
      Future<DocumentReference> docRef = siteCollectionRef.add(site.toJson());
      responseMap["status"] = 'success';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      return responseMap;
    }
  }

  @override
  Future<String> deleteSite() {}

  @override
  Future<bool> fetchSites() {}

  @override
  Future<void> updateSite() {}
}
