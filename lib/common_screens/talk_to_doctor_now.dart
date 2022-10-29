import 'dart:async';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:app/common_screens/payment_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../global/global.dart';
import '../main_screen.dart';
import '../service_file/storage_service.dart';
import '../widgets/progress_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class TalkToDoctorNowInformation extends StatefulWidget {
  const TalkToDoctorNowInformation({Key? key}) : super(key: key);

  @override
  State<TalkToDoctorNowInformation> createState() => _TalkToDoctorNowInformationState();
}

class _TalkToDoctorNowInformationState extends State<TalkToDoctorNowInformation> {

  final Storage storage = Storage();

  final _formKey = GlobalKey<FormState>();
  TextEditingController relationTextEditingController = TextEditingController();
  TextEditingController problemTextEditingController = TextEditingController();
  List<String> reasonOfVisitTypesList = [
    "Cancer",
    "Heart Problem",
    "Skin problem",
    "Liver problem",
    "Broken bones"
  ];
  String? selectedReasonOfVisit;

  String idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  String formattedDate = DateFormat('yMd').format(DateTime.now());// 28/03/2020
  String formattedTime = DateFormat.jm().format(DateTime.now());

  //DateTime date = DateTime.now();
  //TimeOfDay time = TimeOfDay.now().replacing(hour: TimeOfDay.now().hourOfPeriod);

  saveConsultationInfo() async {
    consultationId = idGenerator();
    Map consultationInfoMap = {
      "id" : consultationId,
      "date" : formattedDate,
      "time" : formattedTime,
      "doctorId" : selectedDoctorInfo!.doctorId,
      "doctorName" : selectedDoctorInfo!.doctorName,
      "specialization" : selectedDoctorInfo!.specialization,
      "doctorFee" : selectedDoctorInfo!.fee,
      "workplace" : selectedDoctorInfo!.workplace,
      "consultationType" : "Now",
      "visitationReason": selectedReasonOfVisit,
      "problem": problemTextEditingController.text.trim(),
      "payment" : "Pending"
    };

    FirebaseDatabase.instance.ref().child("Users")
        .child(currentFirebaseUser!.uid)
        .child("patientList")
        .child(patientId!)
        .child("consultations")
        .child(consultationId!).set(consultationInfoMap);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    problemTextEditingController.addListener(() => setState(() {}));
    relationTextEditingController.addListener(() => setState(() {}));
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white
                ),
                child: const Icon(
                  Icons.arrow_back_outlined,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          title: Text(
            "Talk to doctor now",
            style: GoogleFonts.montserrat(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),

        body: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC7E9F0), Color(0xFFFFFFFF)]
              )
          ),

          child: ListView(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book Now
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Fill up the form",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                ),
                              ),
                            ],
                          ),


                          SizedBox(height: height * 0.05,),

                          // Reason of Consultation
                          Text(
                            "Reason of Consultation",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            ),
                          ),
                          SizedBox(height: height * 0.02,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.shade200,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    "assets/advisor.png",
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Expanded(
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                  ) ,
                                  isExpanded: true,
                                  iconSize: 30,
                                  dropdownColor: Colors.white,
                                  hint: const Text(
                                    "Specify the reason",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: selectedReasonOfVisit,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedReasonOfVisit = newValue.toString();
                                    });
                                  },
                                  items: reasonOfVisitTypesList.map((reason) {
                                    return DropdownMenuItem(
                                      value: reason,
                                      child: Text(
                                        reason,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: height * 0.05,),

                          // Consultation For
                          Text(
                            "Consultation For",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            ),
                          ),
                          SizedBox(height: height * 0.02,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.shade200,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    "assets/relations.png",
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: TextFormField(
                                  controller: relationTextEditingController,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),

                                  decoration:  InputDecoration(
                                    labelText: "Relation",
                                    hintText: "Specify relation",
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                                    labelStyle: TextStyle(color: Colors.black, fontSize: 15),

                                    suffixIcon: relationTextEditingController.text.isEmpty
                                        ? Container(width: 0)
                                        : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () =>
                                          relationTextEditingController.clear(),
                                    ),

                                  ),

                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: height * 0.05,),

                          // Describe the problem
                          Text(
                            "Describe the problem",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            ),
                          ),
                          SizedBox(height: height * 0.02,),
                          TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: problemTextEditingController,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: "Write here",
                              hintText: "Write here",
                              prefixIcon: IconButton(
                                icon: Image.asset(
                                  "assets/edit-info.png",
                                  height: 18,
                                ),
                                onPressed: () {},
                              ),
                              suffixIcon: problemTextEditingController.text.isEmpty
                                  ? Container(width: 0)
                                  : IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () =>
                                    problemTextEditingController.clear(),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                              labelStyle:
                              const TextStyle(color: Colors.black, fontSize: 15),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "The field is empty";
                              } else
                                return null;
                            },
                          ),


                          GestureDetector(
                            onTap: () async{
                              final results = await FilePicker.platform.pickFiles(
                                allowMultiple: false,
                                type: FileType.custom,
                                allowedExtensions: ["png","jpg"]
                              );

                              if(results == null){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No file selected'))
                                );
                                return null;
                              }

                              final path = results.files.single.path;
                              final fileName = results.files.single.name;

                              storage.uploadPrescriptionAndReportsofPatient(path!, fileName).then((value) => Fluttertoast.showToast(msg: "Upload Done"));
                            },
                            child: Container(
                              margin: EdgeInsets.all(15),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                ),
                              ) ,
                              child: Row(
                                children: [
                                  Image.asset("assets/Logo.png",width: 60,),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text(
                                      "Upload report and previous prescriptions",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black
                                    )
                                  ),
                              ),
                              ]
                            ),
                            ),
                          ),

                          FutureBuilder(
                            future: storage.listFiles(),
                            builder: (BuildContext context, AsyncSnapshot<firebase_storage.ListResult> snapshot){
                              if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                                return Container(
                                  height:  100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.items.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      /*Image.network(
                                          snapshot.data as String,fit: BoxFit.cover
                                      );*/

                                        ElevatedButton(
                                            onPressed: () {},
                                            child: Text(
                                              snapshot.data!.items[index].name,
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ));
                                      }),
                                );
                              }

                              if(snapshot.connectionState == ConnectionState.waiting && snapshot.hasData){
                                return Center(child: const CircularProgressIndicator());
                              }

                              return Container();
                            },

                          ),

                          SizedBox(height: height * 0.1,),

                          // Consultation fee
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Consultation Fee",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                              Text(
                                selectedDoctorInfo!.fee!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: height * 0.02,),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: ()  {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context){
                                      return ProgressDialog(message: "Please wait...");
                                    }
                                );

                                // Saving consultation information
                                saveConsultationInfo();

                                Timer(const Duration(seconds: 2),()  {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen()));
                                });



                              },

                              style: ElevatedButton.styleFrom(
                                  primary: (Colors.blue),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),

                              child: Text(
                                "Book Now" ,
                                style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),



                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),



        ),
      ),
    );
  }
}
