import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_apple_sign_in/apple_id_request.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../models/userModel.dart';

class UserLogic extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String defaultUserImageUrl =
      'https://www.oxfordglobal.co.uk/nextgen-omics-series-us/wp-content/uploads/sites/16/2020/03/Jianming-Xu-e5cb47b9ddeec15f595e7000717da3fe.png';

  // User Data
  Rx<MyUser?> currentUser = MyUser().obs;

  // App Data
  Rx<String> appVersion = '0.0'.obs;
  Rx<String> packageName = ''.obs;

  // State variables
  RxBool isSignedIn = false.obs;
  RxBool hasError = false.obs;
  Rx<String?> errorCode = Rx(null);
  RxBool guestUser = false.obs;

  // Get user data from SharedPreferences
  Future<void> getUserDataFromSp() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    currentUser.value = MyUser(
      uid: sp.getString('uid'),
      name: sp.getString('name'),
      email: sp.getString('email'),
      cnicNo: sp.getString('cnicNo'),
      phoneNumber: sp.getString('phoneNumber'),
      profilePicUrl: sp.getString('profilePicUrl'),
      userType: UserType.values.byName(sp.getString('userType') ?? 'unknown'),
    );
    update();
  }

  // Save user data to SharedPreferences
  Future<void> saveDataToSP() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('uid', currentUser.value!.uid!);
    await sp.setString('name', currentUser.value!.name!);
    await sp.setString('email', currentUser.value!.email!);
    await sp.setString('cnicNo', currentUser.value!.cnicNo!);
    await sp.setString('phoneNumber', currentUser.value!.phoneNumber!);
    await sp.setString('profilePicUrl', currentUser.value!.profilePicUrl!);
    await sp.setString('userType', currentUser.value!.userType!.name);
  }

  // Clear all data from SharedPreferences
  Future<void> clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }



  // Get timestamp
  Future getTimestamp() async {
    DateTime now = DateTime.now();
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    update();
  }

  // Initialize package info
  Future<void> initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
    packageName.value = packageInfo.packageName;
    update();
  }

  // Sign in with Google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    print("0");
    if (googleUser != null) {
      print("00");
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print("000");
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        print("0000");
        User userDetails = (await _firebaseAuth.signInWithCredential(credential)).user!;
        print("00000");
        currentUser.value = MyUser(
          uid: userDetails.uid,
          name: userDetails.displayName,
          email: userDetails.email,
          profilePicUrl: userDetails.photoURL,
          userType: UserType.crimeReporter, // Set default user type
        );
        isSignedIn.value = true;
        hasError.value = false;
        update();
      } catch (e) {
        hasError.value = true;
        errorCode.value = e.toString();
        update();
      }
    } else {
      hasError.value = true;
      update();
    }
  }

  // Sign in with Apple
  // Future signInWithApple() async {
  //   final result = await TheAppleSignIn.performRequests([
  //     AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
  //   ]);
  //
  //   if (result.status == AuthorizationStatus.authorized) {
  //     try {
  //       final appleIdCredential = result.credential;
  //       final oAuthProvider = OAuthProvider('apple.com');
  //       final credential = oAuthProvider.credential(
  //         idToken: String.fromCharCodes(appleIdCredential!.identityToken!),
  //         accessToken: String.fromCharCodes(appleIdCredential.authorizationCode!),
  //       );
  //       final authResult = await _firebaseAuth.signInWithCredential(credential);
  //       final firebaseUser = authResult.user;
  //
  //       currentUser.value = User(
  //         uid: firebaseUser!.uid,
  //         name: appleIdCredential.fullName!.givenName != null
  //             ? '${appleIdCredential.fullName!.givenName} ${appleIdCredential.fullName!.familyName}'
  //             : 'Not given',
  //         email: firebaseUser.email ?? 'Not given',
  //         profilePicUrl: firebaseUser.photoURL ?? defaultUserImageUrl,
  //         userType: UserType.crimeReporter, // Set default user type
  //       );
  //
  //       isSignedIn.value = true;
  //       hasError.value = false;
  //       update();
  //     } catch (e) {
  //       hasError.value = true;
  //       errorCode.value = 'Appple Sign In Error! Please try again';
  //       update();
  //     }
  //   } else if (result.status == AuthorizationStatus.error) {
  //     hasError.value = true;
  //     errorCode.value = 'Appple Sign In Error! Please try again';
  //     update();
  //   } else if (result.status == AuthorizationStatus.cancelled) {
  //     hasError.value = true;
  //     errorCode.value = 'Sign In Cancelled!';
  //     update();
  //   }
  // }

  // Sign up with email and password
  Future signUpwithEmailPassword(MyUser myUser,email, password) async {
    try {
      final User? user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      ))
          .user!;
      assert(user != null);
      await user!.getIdToken();
      currentUser.value = MyUser(
          uid: user.uid,
          name: myUser.name,
          email: myUser.email,
          );
      isSignedIn.value = true;
      hasError.value = false;
      update();
    } catch (e) {
      hasError.value = true;
      errorCode.value = e.toString();
      update();
    }
  }

  Future<MyUser?> getUserDetails(String userId) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        return MyUser.fromJSON(snapshot.data() as Map<String, dynamic>);
      } else {
        return null; // User document doesn't exist
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null; // Error fetching details
    }
  }
  // Sign in with email and password
  Future signInwithEmailPassword(String userEmail, String userPassword) async {
    try {
      final User? user = (await _firebaseAuth.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      ))
          .user!;
      assert(user != null);
      await user!.getIdToken();
      final User myUser = _firebaseAuth.currentUser!;
      currentUser.value = MyUser(
          uid: myUser.uid,
          name: myUser.displayName,
          email: myUser.email,
          profilePicUrl: myUser.photoURL,
          userType: UserType.crimeReporter);
      isSignedIn.value = true;
      hasError.value = false;
      update();
    } catch (e) {
      hasError.value = true;
      errorCode.value = e.toString();
      update();
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(MyUser myUser) async {
    DocumentSnapshot snap = await firestore.collection('users').doc(myUser.uid!).get();
    if (snap.exists) {
      print('User Exists');
      return true;
    } else {
      print('new user');
      return false;
    }
  }

  // Save user data to Firestore
  // Future saveToFirebase() async {
  //   final DocumentReference ref =
  //       FirebaseFirestore.instance.collection('users').doc(uid.value);
  //   var userData = {
  //     'name': name.value,
  //     'email': email.value,
  //     'uid': uid.value,
  //     'image url': imageUrl.value,
  //     'timestamp': timestamp.value,
  //     'loved items': [],
  //     'bookmarked items': []
  //   };
  //   await ref.set(userData);
  // }

  // Sign out the user
  Future userSignout() async {
    // if (signInProvider.value == 'apple') {
    //   await _firebaseAuth.signOut();
    // } else if (signInProvider.value == 'facebook') {
    //   await _firebaseAuth.signOut();
    //   // await _fbAuth.logOut();
    // } else if (signInProvider.value == 'email') {
    //   await _firebaseAuth.signOut();
    // } else {
      await _firebaseAuth.signOut();
      // await _googlSignIn.signOut();
    // }
    isSignedIn.value = false;
    update();
  }

  Future afterUserSignOut() async {
    await clearAllData();
    isSignedIn.value = false;
    guestUser.value = false;
    update();
  }

  // Set guest user
  Future setGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest_user', true);
    guestUser.value = true;
    update();
  }

  // Check if guest user
  void checkGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    guestUser.value = sp.getBool('guest_user') ?? false;
    update();
  }

  // Guest sign out
  Future guestSignout() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest_user', false);
    guestUser.value = false;
    update();
  }

  // Update user profile
  Future updateUserProfile(String newName, String newImageUrl, MyUser myUser) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    FirebaseFirestore.instance
        .collection('users')
        .doc(myUser.uid!)
        .update({'name': newName, 'image url': newImageUrl});

    sp.setString('name', newName);
    sp.setString('image_url', newImageUrl);
    // name.value = newName;
    // imageUrl.value = newImageUrl;
    update();
  }

  // Get total users count
  Future<int> getTotalUsersCount() async {
    final String fieldName = 'count';
    final DocumentReference ref = firestore.collection('item_count').doc('users_count');
    DocumentSnapshot snap = await ref.get();
    if (snap.exists == true) {
      int itemCount = snap[fieldName] ?? 0;
      return itemCount;
    } else {
      await ref.set({fieldName: 0});
      return 0;
    }
  }

  // Increase user count
  Future increaseUserCount() async {
    await getTotalUsersCount().then((int documentCount) async {
      await firestore
          .collection('item_count')
          .doc('users_count')
          .update({'count': documentCount + 1});
    });
  }

  // Delete user data from database
  Future deleteUserDatafromDatabase(MyUser myUser) async {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    await _db.collection('users').doc(myUser.uid).delete();
  }
}
