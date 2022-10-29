import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:fluttertoast/fluttertoast.dart';

class Storage{
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadPrescriptionAndReportsofPatient (
      String filePath,
      String fileName,
   ) async {
    File file = File(filePath);
    try{
      await storage.ref('Patient Reports and Prescriptions/$fileName').putFile(file);
    }
    catch(e){
      Fluttertoast.showToast(msg: "Error" + e.toString());
    }

  }


  Future<firebase_storage.ListResult> listFiles() async{
    firebase_storage.ListResult results = await storage.ref('Patient Prescriptions and Reports').list();
    return results;
  }

}