import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'RPC.dart';
import 'db.dart';
import 'dart:convert';
import 'dialogs.dart' as dlg;
import 'state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AppDrawer {
  static Widget getAvatar(BuildContext context, MyUser? user) {
    String? src = user?.profile?.photo?.url_web!;
    if(src == null) {
      return AspectRatio(aspectRatio: 1, child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage("assets/unknown_user.jpg",package:"db"),
            ),
          )
      ));
    } else {
      return AspectRatio(aspectRatio: 1, child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(src),
            ),
          )
      ));
    }
  }

  static Drawer getDrawer(BuildContext context, Function builder, {bool allowLogout: true}) {
    return Drawer(
      child: Consumer<MyUserProvider>(builder: (context, myUser, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              onTap: myUser.user == null ? null : () {
                Navigator.pop(context); // close drawer
                Profile.navPush(context, myUser);
              },
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                accountName: Padding(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(child: Text(myUser.user == null ? "Not Logged In" : "${myUser.user!.name}")),
                          myUser.user == null ? Container(width: 0) : Icon(Icons.edit, color: Colors.white,),
                          myUser.user == null ? Container(width: 0) : Container(width: 10),
                        ],
                      ),
                      padding: EdgeInsets.only(top: 10),
                ),
                accountEmail: Text(myUser.user?.email ?? ""),
                currentAccountPicture: AppDrawer.getAvatar(context, myUser.user),
              ),
            ),
            Container(height: 30),
            Expanded(child: SingleChildScrollView(child: builder(context))),
            Container(height: 30),
            allowLogout ? GestureDetector(
                child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: ListTile(
                  leading: Icon(myUser.user == null ? Icons.login : Icons.logout, color: Colors.white),
                  title: Text(myUser.user == null ? "Login" : "Logout", style: TextStyle(color: Colors.white)),
                ),
              ),
              onTap: () {
                if(myUser.user == null) {
                  myUser.goToLogin();
                } else {
                  myUser.logout();
                }
              },
            ) : Container(height: 0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              padding: EdgeInsets.all(10),
              child: Text("Version: ${myUser.version}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }
}

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key:key);

  @override ProfileState createState() => ProfileState();

  static void navPush(BuildContext context, MyUserProvider myUserProvider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name:"profile"),
        builder: (BuildContext context) {
          return ChangeNotifierProvider<MyUserProvider>.value(
            value : myUserProvider,
            builder: (context, widget1) {
              return Profile();
            },
          );
        },
      ),
    );    
  }
}

class ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fname = new TextEditingController();
  TextEditingController lname = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController bio = new TextEditingController();
  int preferedUnits = 0;
  int weekStarts = -1;
  String? src;

  Future<void> _save_profile() async {
    try {
      Map myuser = await RPC().rpc("rest", "User", "set_profile", {"first_name": fname.text, "last_name": lname.text, "email":email.text, "bio":bio.text, "preferedUnits":preferedUnits, "weekStarts": weekStarts}, "Saving Profile...");
      Provider.of<MyUserProvider>(context, listen: false).userFromJson(myuser);
      Navigator.pop(context);
    } catch(error) {
      dlg.showError(error.toString());
    }
  }
  Future<void> _delete_account() async {
      dlg.confirm(
        "Confirm",
        "Are you sure you want to delete your account? This cannot be undone.",
        () async {
          try {
            Map myuser = await RPC().rpc("rest", "User", "delete_account", {}, "Deleting Account...");
            Provider.of<MyUserProvider>(context, listen: false).logout();
            Navigator.pop(context);
          } catch (error) {
            dlg.showError(error.toString());
          }
        },
        (){

        },
      );
  }

  @override void initState() {
    super.initState();
    MyUser? user = Provider.of<MyUserProvider>(context, listen: false).user;
    if(user != null) {
      fname.text = user.first_name;
      lname.text = user.last_name;
      email.text = user.username;
      bio.text = user.profile?.bio ?? "";
      preferedUnits = user.profile?.units ?? 0;
      weekStarts = user.profile?.week_starts ?? -1;
      src = user.profile?.photo?.url_web;
      print("USER = $user");
    }
  }

  Future<void> uploadPhoto(XFile image, MyUserProvider myUserProvider) async {
    try {
      var bytes = await image.readAsBytes();
      final String image_b64 = base64.encode(bytes);
      Map result = await RPC().rpc("training", "Training", "set_avatar", {"image_b64": image_b64,}, "Uploading Photo");
      myUserProvider.userFromJson(result["user"]);
    } catch(e) {
      dlg.showError(e.toString());
    }
  }

  @override Widget build(BuildContext context) {
    return Consumer<MyUserProvider>(builder: (context, myUserProvider, child) {
      return Scaffold(
        appBar: AppBar(title: Text("Update Profile")),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  padding: EdgeInsets.only(left:40, right: 40, top: 20, bottom: 20),
                  child: AppDrawer.getAvatar(context, myUserProvider.user),
              ),
              Row(
                children: <Widget> [
                Container(width: 10),
                Expanded(child: OutlinedButton(child: AutoSizeText("New Photo From Gallery", textAlign: TextAlign.center, maxLines:2, minFontSize: 8,), onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if(image != null) {
                    uploadPhoto(image, myUserProvider);
                  }
                  },)),
                Container(width: 10),
                Expanded(child: OutlinedButton(child: AutoSizeText("New Photo From Camera", textAlign: TextAlign.center, maxLines:2, minFontSize: 8,), onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice:CameraDevice.front);
                  if(image != null) {
                    uploadPhoto(image, myUserProvider);
                  }
                },)),
                  myUserProvider.user?.profile?.photo?.url_web == null ? Container(width: 0) : Container(width: 10),
                  myUserProvider.user?.profile?.photo?.url_web == null ? Container(height: 0) : Expanded(child: OutlinedButton(child: AutoSizeText("Delete This Photo", textAlign: TextAlign.center, maxLines:2), onPressed: () {
                    dlg.confirm("Delete Photo", "Are you sure?", () async {
                      try {
                        Map result = await RPC().rpc("training","Training","delete_avatar",{},"Deleting Profile Photo");
                        myUserProvider.userFromJson(result["user"]);
                      } catch(e) {
                        dlg.showError(e.toString());
                      }
                    }, (){});
                  },)),
                  Container(width: 10),
                ],
              ),
              Container(height: 20),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 40, right: 40),
              ),
              Container(height: 20),
              Container(
                padding: EdgeInsets.only(left: 40, right: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[

                  TextFormField(
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
                    Container(height: 20),
                    TextFormField(
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
                    Container(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                      ),
                      controller: email,
                      validator: (value) {
                        if(value?.trim().isEmpty ?? true) {
                          return 'Invalid Email';
                        }
                        if(!value!.contains("@")) {
                          return 'Invalid Email';
                        }
                        return null;
                      }
                    ),
                    Container(height: 20),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Preferred Units",
                      ),
                      value: preferedUnits,
                      items: [
                        DropdownMenuItem<int>(value: 0, child: Text("miles")),
                        DropdownMenuItem<int>(value: 1, child: Text("km")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if(value != null) preferedUnits = value;
                        });
                      },

                    ),
                    Container(height: 20),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Preferred Day To Start Calendar Week",
                      ),
                      value: weekStarts,
                      items: [
                        DropdownMenuItem<int>(value: -1,child: Text("Default")),
                        DropdownMenuItem<int>(value: 0, child: Text("Sun")),
                        DropdownMenuItem<int>(value: 1, child: Text("Mon")),
                        DropdownMenuItem<int>(value: 2, child: Text("Tue")),
                        DropdownMenuItem<int>(value: 3, child: Text("Wed")),
                        DropdownMenuItem<int>(value: 4, child: Text("Thu")),
                        DropdownMenuItem<int>(value: 5, child: Text("Fri")),
                        DropdownMenuItem<int>(value: 6, child: Text("Sat")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if(value != null) weekStarts = value;
                        });
                      },
                    ),
                    Container(height: 20),
                    TextFormField(
                        decoration: InputDecoration(
                          labelText: "Bio",
                        ),
                        controller: bio,
                        validator: (value) {
                          return null;
                        },
                        minLines: 2,
                        maxLines: 6,
                    ),
                    Container(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _save_profile();
                        }
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
              )
            ),
              Container(height: 50),
              TextButton(
                child: Text("Delete Account"),
                onPressed: () {
                  _delete_account();
                }
              ),
              Container(height: 20),
          ]),
        ),
      );
    });
  }
}
