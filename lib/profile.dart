import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'RPC.dart';
import 'db.dart';
import 'dialogs.dart' as dlg;
import 'state.dart';

class Profile extends StatefulWidget {
  Function scaffoldBuilder;

  Profile(this.scaffoldBuilder, {Key? key}) : super(key:key);

  @override
  ProfileState createState() => ProfileState();

  static void navPush(BuildContext context, Function scaffoldBuilder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name:"profile"),
        builder: (BuildContext context) => Profile(scaffoldBuilder),
      ),
    );    
  }
}

class ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fname = new TextEditingController();
  TextEditingController lname = new TextEditingController();

  Future<void> _save_profile() async {
    try {
      Map myuser = await RPC().rpc("rest", "User", "set_profile", {"first_name": fname.text, "last_name": lname.text}, "Saving Profile...");
      Provider.of<MyUserProvider>(context, listen: false).userFromJson(myuser);
    } catch(error) {
      dlg.showError(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    MyUser? user = Provider.of<MyUserProvider>(context, listen: false).user;
    if(user != null) {
      fname.text = user.first_name;
      lname.text = user.last_name;
      print("USER = $user");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.scaffoldBuilder(
      appBarTitle: "Update Profile",
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "First Name",
                        ),
                        controller: fname,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true)
                            return 'First Name';
                          else
                            return null;
                        }),
                  ),
                  Container(
                    child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Last Name",
                        ),
                        controller: lname,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true)
                            return 'Last Name';
                          else
                            return null;
                        }),
                  ),
                  Container(height: 20),
                  RaisedButton(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _save_profile();
                      }
                    },
                    child: Text("Update Profile"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
