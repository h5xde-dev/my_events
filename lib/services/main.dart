import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class MainBase {
  Stream<List> get getCardsData;
}

class Main implements MainBase {

  @override
  Stream<List> get getCardsData {
    List dataFire = [];
    Set cardInfo = {};
    return Firestore.instance.collection("places") .getDocuments()
        .then((QuerySnapshot snapshot) {
          createCards(f) {
            cardInfo.add(f.data);
          }
          snapshot.documents.forEach((f) => createCards(f));
          dataFire.addAll(
            cardInfo
          );
          return dataFire;
    }).asStream();
  }
}