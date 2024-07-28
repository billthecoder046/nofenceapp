// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:crimebook/utils/buttons.dart'; // Import your custom button widget
//
// enum PhoneVerificationState { SHOW_PHONE_FORM_STATE, SHOW_OTP_FORM_STATE }
//
// class PhoneAuthPage extends StatefulWidget {
//   String? number;
//   PhoneAuthPage({this.number});
//
//   @override
//   _PhoneAuthPageState createState() => _PhoneAuthPageState();
// }
//
// class _PhoneAuthPageState extends State<PhoneAuthPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKeyForSnackBar = GlobalKey();
//   PhoneVerificationState currentState =
//       PhoneVerificationState.SHOW_PHONE_FORM_STATE;
//   final phoneController = TextEditingController();
//   final otpController = TextEditingController();
//   String? verificationIDFromFirebase;
//   bool spinnerLoading = false;
//
//   FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   Future<void> _verifyPhoneButton(String number) async {
//     setState(() {
//       spinnerLoading = true;
//     });
//     try {
//       await _firebaseAuth.verifyPhoneNumber(
//         phoneNumber: number,
//         verificationCompleted: (phoneAuthCredential) async {
//           setState(() {
//             spinnerLoading = false;
//           });
//           // TODO: Auto Complete Function
//           // signInWithPhoneAuthCredential(phoneAuthCredential);
//         },
//         verificationFailed: (verificationFailed) async {
//           setState(() {
//             spinnerLoading = false;
//           });
//           Fluttertoast.showToast(
//               msg: "Verification Code Failed: ${verificationFailed.message}");
//         },
//         codeSent: (verificationId, resendingToken) async {
//           setState(() {
//             spinnerLoading = false;
//             currentState = PhoneVerificationState.SHOW_OTP_FORM_STATE;
//             this.verificationIDFromFirebase = verificationId;
//           });
//         },
//         codeAutoRetrievalTimeout: (verificationId) async {
//           setState(() {
//             spinnerLoading = false;
//           });
//           // Handle auto-retrieval timeout
//         },
//       );
//     } catch (e) {
//       setState(() {
//         spinnerLoading = false;
//       });
//       print('Error verifying phone number: $e');
//     }
//   }
//
//   Future<void> _verifyOTPButton() async {
//     try {
//       PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
//           verificationId: verificationIDFromFirebase ?? '',
//           smsCode: otpController.text);
//       await signInWithPhoneAuthCredential(phoneAuthCredential);
//     } catch (e) {
//       print('Error verifying OTP: $e');
//     }
//   }
//
//   Future<void> signInWithPhoneAuthCredential(
//       PhoneAuthCredential phoneAuthCredential) async {
//     setState(() {
//       spinnerLoading = true;
//     });
//     try {
//       final authCredential =
//       await _firebaseAuth.signInWithCredential(phoneAuthCredential);
//       setState(() {
//         spinnerLoading = false;
//       });
//       if (authCredential.user != null) {
//         Navigator.of(context).pop(true);
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         spinnerLoading = false;
//       });
//       Fluttertoast.showToast(msg: e.message.toString());
//     }
//   }
//
//   Widget getPhoneFormWidget(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Text("Go back and enter phone number again!").tr()
//       ],
//     );
//   }
//
//   Widget getOTPFormWidget(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           "Enter OTP Number",
//           style: const TextStyle(fontSize: 16.0),
//         ),
//         const SizedBox(
//           height: 40.0,
//         ),
//         TextField(
//           controller: otpController,
//
//           textAlign: TextAlign.start,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(
//               hintText: "OTP Number",
//               prefixIcon: Icon(Icons.confirmation_number_rounded)),
//         ),
//         const SizedBox(
//           height: 20.0,
//         ),
//         Center(
//           child: myFirstButton(
//             onPressed: () => _verifyOTPButton(),
//             text: Text('Verify OTP Number'),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print("PhoneNumber ${widget.number.toString()}");
//     _verifyPhoneButton(widget.number.toString());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//           key: _scaffoldKeyForSnackBar,
//           appBar: AppBar(
//             leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,), onPressed: () { Navigator.of(context).pop(); },),
//             title: Text("Phone Verification",style: TextStyle(color: Colors.white),),
//             backgroundColor: Colors.red,
//             centerTitle: true,
//
//           ),
//           body: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     height: 40.0,
//                   ),
//                   spinnerLoading
//                       ? const Center(
//                     child: SizedBox(
//                         width: 32.0,
//                         height: 32.0,
//                         child:   CupertinoActivityIndicator())
//                   )
//                       : currentState == PhoneVerificationState.SHOW_PHONE_FORM_STATE
//                       ? getPhoneFormWidget(context)
//                       : getOTPFormWidget(context),
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }