library db;
import 'dart:io';
import 'db.dart';
import 'RPC.dart';
import 'dialogs.dart' as dlg;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:uuid/uuid.dart';
import 'package:uni_links/uni_links.dart';

GlobalKey<NavigatorState>? navKey;

BuildContext get gContext {
  BuildContext? context = navKey?.currentContext;
  if(context == null) {
    throw("navKey is null. Call dialog init() function");
  } else {
    return context;
  }
}

class MyUserProvider with ChangeNotifier {
  MyUser? _user;
  String _tmpEmail  = "";
  String _tmpPasswd = "";
  bool initialized = false;
  String udid = "Unknown";
  MyUser? get user => _user;
  String hostKey;
  ScaffoldBuilder scaffoldBuilder;
  ChildBuilder childBuilder;
  bool mounted = true;

  @override void dispose() {
    mounted = false;
    super.dispose();
  }

  set tmpEmail(String x) {
    _tmpEmail = x;
    notifyListeners();
  }
  set tmpPasswd(String x) {
    _tmpPasswd = x;
    notifyListeners();
  }
  String get tmpEmail => _tmpEmail;
  String get tmpPasswd => _tmpPasswd;

  MyUserProvider(GlobalKey<NavigatorState> nKey,this.hostKey, this.scaffoldBuilder, this.childBuilder) {
    print("MyUserProvider Constructor");
    navKey = nKey;
    RPC().registerNotLoggedInHandler(() async {
      _user = null;
      notifyListeners();
    });

    FlutterUdid.udid.then((x) {
      udid = x;
      notifyListeners();
    }, onError: (e) {
      var uuid = Uuid();
      udid = uuid.v4(); // -> '110ec58a-a0f2-4ac4-8393-c866d813b8d1'
      notifyListeners();
    });
  }

  Future<void> init() async {
    initialized = false;
    try {
      userFromJson(await RPC().rpc("rest", "User", "whoami", {}, null));
    } on NotLoggedInException {

    } catch(e) {
      dlg.showError(e.toString());
    }

    /* handle uni_links */
    // get the initial universal/deep link
    try {
      final link = await getInitialLink();
      print('initial link: $link');
      if (link != null) {
        processLink(link);
      }
    } catch(e) {
      print("$e");
      // Handle exception by warning the user their action did not succeed
      // return?
    }

    // listen for univiersal/deep links
    var _sub = linkStream.listen((String? link) {
      print("RX LINK: ${link}");
      if(link != null) {
        processLink(link);
      }
    }, onError: (err) {
      print("$err");
      // Handle exception by warning the user their action did not succeed
    });
    // NOTE: Don't forget to call _sub.cancel() in dispose()

    initialized = true;
    notifyListeners();
  }

  void processLink(String link) {
    if (link == null || !mounted) {
      return;
    }
    if (link.contains("password/reset")) {
      List m = link.split("/");
      String email = m[6];
      String rId = m[7];
      print("EMAIL=$email rId=$rId");

      navKey?.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
          return ChangeNotifierProvider<MyUserProvider>.value(
              value : this,
              builder: (context, widget1) {
                return PasswordReset2(email, rId);
              });
        }),
        (route) => true,
      );
    }
  }

  void goToLogin() {
    navKey?.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
          return ChangeNotifierProvider<MyUserProvider>.value(
              value : this,
              builder: (context, widget1) {
                return Login();
              });
        },
        settings: RouteSettings(name: "Login"),
        ),
        (r) {
          print(r);
          return true;
        },
    );
  }

  void userFromJson(Map user) {
    print("user: $user");
    Map<String, dynamic> m = {};
    user.forEach((k,v) {
      m[k.toString()] = v;
    });
    _user = MyUser.fromJson(m);
    notifyListeners();
  }

  Future<void> login(String email, String passwd) async {
    print("Login $email");
    try {
      userFromJson(await RPC().rpc("rest", "User", "login",  {"username": email, "password": passwd}, "Logging In"));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("email", email);
      await prefs.setString("password", passwd);
    } catch(e) {
      dlg.showError("$e");
    }
  }
  Future<void> logout() async {
    await RPC().rpc("rest", "User", "logout",  {}, "Logging Out");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("email");
    await prefs.remove("password");
    _user = null;
    notifyListeners();
  }
}

typedef ChildBuilder = Widget Function(BuildContext context);
typedef ScaffoldBuilder = Widget Function(BuildContext context, {required String appBarTitle, required Widget body});

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);
  @override LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Provider.of<MyUserProvider>(context, listen: false).init();
    });
  }


  @override Widget build(BuildContext context) {
    return Consumer<MyUserProvider>(builder: (context, myUserProvider, child) {
      if(!myUserProvider.initialized) {
        return myUserProvider.scaffoldBuilder (
          context,
          appBarTitle: ("Initializing"),
          body: Center(child: CircularProgressIndicator()),
        );
      } else if(myUserProvider._user == null) {
        String email = "";
        String passwd = "";
        double width = MediaQuery.of(context).size.width;
        double loginWidth = width < 300 ? width - 10: 300;
        return myUserProvider.scaffoldBuilder(
          context,
          appBarTitle: "Login",
          body: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                Expanded(child: Container()),
                Text("Login", style: Theme.of(context).textTheme.headline4),
                Container(width: loginWidth, child: TextFormField(
                    initialValue: myUserProvider.tmpEmail,
                    decoration: InputDecoration(
                      labelText: "Email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (newValue) {
                      myUserProvider.tmpEmail = newValue.trim();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains("@")) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                )),
                Container(width: loginWidth, child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                  initialValue: myUserProvider.tmpPasswd,
                  obscureText: true,
                  onChanged: (newValue) {
                    myUserProvider.tmpPasswd = newValue;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },                )),
                Container(height: 10),
                ElevatedButton(
                    child: Text("Login"),
                    onPressed: (myUserProvider.tmpEmail.isEmpty || myUserProvider.tmpPasswd.isEmpty || !_formKey.currentState!.validate()) ? null : () {
                      myUserProvider.login(myUserProvider.tmpEmail, myUserProvider.tmpPasswd);
                    }
                ),
                Expanded(child: Container()),
                FlatButton(
                  child: Text("Setup/Forgot Password", style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return ChangeNotifierProvider<MyUserProvider>.value(
                          value : myUserProvider,
                          builder: (context, widget1) {
                            return PasswordReset1();
                        });
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      } else {
        return myUserProvider.childBuilder.call(context);
      }
    });
  }
}

class PasswordReset1 extends StatefulWidget {
  PasswordReset1({Key? key}) : super(key: key);
  @override PasswordReset1State createState() => PasswordReset1State();
}

class PasswordReset1State extends State<PasswordReset1> {
  final _formKey = GlobalKey<FormState>();
  bool submitted = false;

  Future<void> send(String email, String hostKey) async {
      var data = await RPC().rpc("rest", "User", "forgot_password", {"email": email, "host_key": hostKey}, "");
      print("DATA=$data");
  }

  @override void initState() {
    super.initState();
  }
  @override Widget build(BuildContext context) {
    return Consumer<MyUserProvider>(builder: (context, myUserProvider, child) {
        double width = MediaQuery.of(context).size.width;
        double loginWidth = width < 300 ? width - 10: 300;
        return myUserProvider.scaffoldBuilder(
          context,
          appBarTitle: "Password",
          body: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                Expanded(child: Container()),
                Text("Setup/Forgot Password", style: Theme.of(context).textTheme.headline5),
                Container(width: loginWidth, child: TextFormField(
                  initialValue: myUserProvider.tmpEmail,
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (newValue) {
                    myUserProvider.tmpEmail = newValue.trim();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || (submitted && !value.contains("@"))) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                )),
                Container(height: 10),
                ElevatedButton(
                    child: Text("Submit"),
                    onPressed: (myUserProvider.tmpEmail.isEmpty || !(_formKey.currentState?.validate() ?? false)) ? null : () async {
                      setState(() {
                        submitted = true;
                      });
                      if(!(_formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      try {
                        await send(myUserProvider.tmpEmail, myUserProvider.hostKey);
                        myUserProvider.tmpPasswd = "";
                        dlg.showMsg("Check Your Email",
                            "You have been emailed instructions. Please click the link in that email to set your password.",
                                () {
                              Navigator.pop(context);
                            });
                      } catch(e) {
                        dlg.showError(e.toString());
                      }
                    }
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        );
    });
  }
}

class PasswordReset2 extends StatefulWidget {
  String email;
  String rId;
  PasswordReset2(this.email, this.rId, {Key? key}) : super(key: key);
  @override PasswordReset2State createState() => PasswordReset2State();
}

class PasswordReset2State extends State<PasswordReset2> {
  final _formKey = GlobalKey<FormState>();
  String passwd1 = "";
  String passwd2 = "";
  bool submitted = false; // displays 'passwords don't match' after submitted is true if the passwords are different

  Future<void> _set_password() async {
    if (passwd1 != passwd2) {
      dlg.showError("Passwords Don't Match");
      return;
    }
    var data = await RPC().rpc("rest", "User", "set_password", {"email": widget.email, "password": passwd1, "rId": widget.rId}, "Setting Password...");
  }

  @override Widget build(BuildContext context) {
    return Consumer<MyUserProvider>(builder: (context, myUserProvider, child) {
      double width = MediaQuery.of(context).size.width;
      double loginWidth = width < 300 ? width - 10: 300;
      return myUserProvider.scaffoldBuilder(
        context,
        appBarTitle: "Password",
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget> [
              Expanded(child: Container()),
              Text("Set Password for", style: Theme.of(context).textTheme.headline5),
              Text("${widget.email}", style: Theme.of(context).textTheme.headline5),
              Container(width: loginWidth, child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Password",
                ),
                initialValue: passwd1,
                obscureText: true,
                onChanged: (newValue) {
                  setState(() {
                    passwd1 = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },                )),
              Container(height: 10),
              Container(width: loginWidth, child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Password Again",
                ),
                initialValue: passwd2,
                obscureText: true,
                onChanged: (newValue) {
                  setState(() {
                    passwd2 = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty || (submitted && passwd1 != passwd2)) {
                    return 'Passwords do not match';
                  }
                  return null;
                },                )),
              Container(height: 10),
              ElevatedButton(
                  child: Text("Submit"),
                  onPressed: (passwd1.isEmpty || passwd2.isEmpty || !(_formKey.currentState?.validate() ?? false)) ? null : () async {
                    setState(() {
                      submitted = true;
                    });
                    if(passwd2 != passwd2) {
                      return;
                    }
                    try {
                      await _set_password();
                      await myUserProvider.login(widget.email, passwd1);
                      Navigator.pop(context);
                      //myUserProvider.goToLogin();
                    } catch(e) {
                      dlg.showError(e.toString(), () {
                        myUserProvider.goToLogin();
                      });
                    }
                  }
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      );
    });
  }
}
