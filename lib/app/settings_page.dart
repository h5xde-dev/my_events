import 'package:flutter/material.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/customisation.dart';
import 'package:my_events/common_widgets/animated_loading.dart';
import 'package:my_events/common_widgets/animated_background.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({
    @required this.auth,
  });

  final AuthBase auth;

  Future<void> _signOut(context) async {
    try {
      await auth.signOut();
      onSignOut(context);
    } catch (e) {
      print(e.toString());
    }
  }

  void onSignOut(context){
     Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false );
  }

  @override
  Widget build(BuildContext context) {

    Future<User> _checkCurrentUser() async {
      User _user = await Auth().currentUser();
      return _user;
    }
    
    return FutureBuilder(
      future: _checkCurrentUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new AnimatedLoading();
          case ConnectionState.waiting:
            return new AnimatedLoading();
          default:
            if (snapshot.hasError)
              return new AnimatedLoading();
            else {
              return _buildContent(context, snapshot.data);
            }
        }
      });
  }

  Widget _buildContent(context, user) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12.0, top: 30.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.account_circle,
                        color: Theme.of(context).textSelectionColor,
                        size: 30.0,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).textSelectionColor,
                        size: 30.0,
                      ),
                      onPressed: () => _signOut(context),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: DropdownButton(
                        items: Customisation.themesList,
                        onChanged: (item) {
                          Customisation.changeTheme(item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}