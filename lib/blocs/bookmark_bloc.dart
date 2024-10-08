import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crimebook/models/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkBloc extends ChangeNotifier {


  Future<List> getArticles() async {

    String _collectionName = 'contents';
    String _fieldName = 'bookmarked items';

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');
    

    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List bookmarkedList = snap[_fieldName];
    debugPrint('mainList: $bookmarkedList');

    List d = [];
    if(bookmarkedList.isEmpty){
      return d;
    }else if(bookmarkedList.length <= 10){
      await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: bookmarkedList)
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
      });

    }else if(bookmarkedList.length > 10){
      int size = 10;
      var chunks = [];

      for(var i = 0; i< bookmarkedList.length; i+= size){    
        var end = (i+size<bookmarkedList.length)?i+size:bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i,end));
      }

      await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[0])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[1])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
        });
      });

    }else if(bookmarkedList.length > 20){
      int size = 10;
      var chunks = [];

      for(var i = 0; i< bookmarkedList.length; i+= size){    
        var end = (i+size<bookmarkedList.length)?i+size:bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i,end));
      }

      await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[0])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[1])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
        });
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('timestamp', whereIn: chunks[2])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
        });
      });
    }

    
    return d;
  
  }




  Future onBookmarkIconClick(String? timestamp) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');
    String _fieldName = 'bookmarked items';
    
    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap[_fieldName];
    

    if (d.contains(timestamp)) {

      List a = [timestamp];
      await ref.update({_fieldName: FieldValue.arrayRemove(a)});
      

    } else {

      d.add(timestamp);
      await ref.update({_fieldName: FieldValue.arrayUnion(d)});
      
      
    }

    notifyListeners();
  }





  Future onLoveIconClick(String? timestamp) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String _collectionName = 'contents';
    String? _uid = sp.getString('uid');
    String _fieldName = 'loved items';


    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    final DocumentReference ref1 = FirebaseFirestore.instance.collection(_collectionName).doc(timestamp);

    DocumentSnapshot snap = await ref.get();
    DocumentSnapshot snap1 = await ref1.get();
    List d = snap[_fieldName];
    int? _loves = snap1['loves'];

    if (d.contains(timestamp)) {

      List a = [timestamp];
      await ref.update({_fieldName: FieldValue.arrayRemove(a)});
      ref1.update({'loves': _loves! - 1});

    } else {

      d.add(timestamp);
      await ref.update({_fieldName: FieldValue.arrayUnion(d)});
      ref1.update({'loves': _loves! + 1});

    }
  }
}