import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:crimebook/pages/welcome.dart';
import 'package:crimebook/utils/next_screen.dart';
import 'package:provider/provider.dart';

import '../blocs/sign_in_bloc.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {

  bool _isLoading = false;


  _openDeleteDialog() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('account-delete-title').tr(),
            content: Text('account-delete-subtitle').tr(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDeleteAccount();
                },
                child: Text('account-delete-confirm').tr(),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('cancel').tr())
            ],
          );
        });
  }


  _handleDeleteAccount () async{
    setState(()=> _isLoading = true);
    await context.read<SignInBloc>().deleteUserDatafromDatabase()
    .then((_) async => await context.read<SignInBloc>().userSignout())
    .then((_) => context.read<SignInBloc>().afterUserSignOut()).then((_){
      setState(()=> _isLoading = false);
      Future.delayed(Duration(seconds: 1))
      .then((value) => nextScreenCloseOthers(context, WelcomePage()));
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('security').tr(),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              ListTile(
                title: Text('delete-user-data').tr(),
                leading: Icon(Feather.trash, size: 20,),
                onTap: _openDeleteDialog,
                
              ),
            ],
          ),

          Align(
            child: _isLoading == true ? SizedBox(
                width: 32.0,
                height: 32.0,
                child: new CupertinoActivityIndicator()) : Container(),
          )

          
        ],
      ),
    );
  }
}
