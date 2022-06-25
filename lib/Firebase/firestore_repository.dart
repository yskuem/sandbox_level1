import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sandbox_level1/model/account.dart';

class FirestoreRepository{
  final _fireStoreInstance = FirebaseFirestore.instance;
  late Account currentLoginAccount;


  Future<dynamic> setAccountData(Account _newAccount)async{//user情報をfirestoreにセット
    final newAccountToJson = _newAccount.toJson();
    try{
      await _fireStoreInstance.collection("users").doc(_newAccount.id).set(newAccountToJson);
      return true;
    }on FirebaseException catch(e){
      return e;
    }
  }
  void setCurrentLoginAccount(Account account){
    currentLoginAccount = account.copyWith();
  }
}