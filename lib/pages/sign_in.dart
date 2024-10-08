import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/blocs/sign_in_bloc.dart';
import 'package:crimebook/pages/done.dart';
import 'package:crimebook/pages/forgot_password.dart';
import 'package:crimebook/pages/sign_up.dart';
import 'package:crimebook/services/app_service.dart';
import 'package:crimebook/utils/icons.dart';
import 'package:crimebook/utils/next_screen.dart';
import 'package:crimebook/utils/snacbar.dart';
import 'package:crimebook/widgets/privacy_info.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SignInPage extends StatefulWidget {
  final String? tag;
  SignInPage({Key? key, this.tag}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  bool offsecureText = true;
  Icon lockIcon = LockIcon().lock;
  var emailCtrl = TextEditingController();
  var passCtrl = TextEditingController();
  
  var formKey = GlobalKey<FormState>();
  

  
  bool signInStart = false;
  bool signInComplete = false;
  late String email;
  late String pass;


  
  


  
  

  void lockPressed (){
    if(offsecureText == true){
      setState(() {
        offsecureText = false;
        lockIcon = LockIcon().open;
        
      });
    } else {
      setState(() {
        offsecureText = true;
        lockIcon = LockIcon().lock;

      });
    }
  }



 

  handleSignInwithemailPassword () async{
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false );
    if (formKey.currentState!.validate()){
      formKey.currentState!.save();
      FocusScope.of(context).requestFocus(new FocusNode());
      await AppService().checkInternet().then((hasInternet){
        if(hasInternet == false){
          openSnacbar(context, 'no internet'.tr());
        }else{
          setState(() {
            signInStart = true;
          });
          sb.signInwithEmailPassword(email, pass).then((_)async{
            if(sb.hasError == false){
              sb.getUserDatafromFirebase(sb.uid)
              .then((value) => sb.guestSignout())
              .then((value) => sb.saveDataToSP()
              .then((value) => sb.setSignIn()
              .then((value){
                setState(() {
                  signInComplete = true;
                });
                afterSignIn();
              })));
            } else{
              setState(() {
                signInStart = false;
              });
              openSnacbar(context, sb.errorCode);
            }
          }); 
        }
      });
    }
  }


  afterSignIn (){
    if(widget.tag == null){
      nextScreenReplace(context, DonePage());
    }else{
      Navigator.pop(context);
    }
    
  }


  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: Form(
            key: formKey,
            child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
            child: ListView(
              children: <Widget>[
                
                SizedBox(height: 20,),
                Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  child: IconButton(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.keyboard_backspace), 
                    onPressed: (){
                      Navigator.pop(context);
                    }),
                ),
                Text('sign in', style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w900
                )).tr(),
                Text('follow the simple steps', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).secondaryHeaderColor
                )).tr(),
                SizedBox(
                  height: 80,
                ),
                
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'username@mail.com',
                    labelText: 'Email'
                  
                    
                  ),
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value){
                    if (value!.length == 0) return "Email can't be empty";
                    return null;
                  },
                  onChanged: (String value){
                    setState(() {
                      email = value;
                    });
                  },
                ),
                SizedBox(height: 20,),
                
                TextFormField(
                  obscureText: offsecureText,
                  controller: passCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter Password',
                    //prefixIcon: Icon(Icons.vpn_key),
                    suffixIcon: IconButton(icon: lockIcon, onPressed: (){
                      lockPressed();
                    }),
                    
                    
                  ),
                 

                  validator: (String? value){
                    if (value!.length == 0) return "Password can't be empty";
                    return null;
                  },
                  onChanged: (String value){
                    setState(() {
                      pass = value;
                    });
                  },
                ),
                
                

                SizedBox(height: 50,),
                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text('forgot password?', style: TextStyle(
                      color: Theme.of(context).primaryColor
                    ),).tr(),
                    onPressed: (){
                      //nextScreen(context, ForgotPasswordPage());
                      Navigator.push(context, CupertinoPageRoute(builder: (context) => ForgotPasswordPage()));
                    }, 

                    
                    ),
                ),

                Container(
                  height: 45,
                  child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) => Theme.of(context).primaryColor)
                        ),
                        child: signInStart == false 
                      ? Text('sign in', style: TextStyle(fontSize: 16, color: Colors.white)).tr()
                      : signInComplete == false 
                      ? SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: new CupertinoActivityIndicator())
                      : Text('sign in successful!', style: TextStyle(fontSize: 16, color: Colors.white)).tr(),
                        onPressed: (){
                         handleSignInwithemailPassword();
                      }),
                ),
                
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("don't have an account?").tr(),
                    TextButton(
                      child: Text('sign up', style: TextStyle(color: Theme.of(context).primaryColor)).tr(),
                      onPressed: (){
                        nextScreenReplace(context, SignUpPage());
                      },
                    )
                  ],
                ),
                SizedBox(height: 50,),
                PrivacyInfo()
                
              ],
            ),
          ),
        )
      
    );
  }

}