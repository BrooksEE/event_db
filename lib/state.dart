library db;
import 'dart:io';
import 'db.dart';
import 'dart:convert';
import 'RPC.dart';
import 'cart.dart';
import 'dialogs.dart' as dlg;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:uuid/uuid.dart';
import 'package:uni_links/uni_links.dart';
import 'package:package_info_plus/package_info_plus.dart';

GlobalKey<NavigatorState>? navKey;
MyUserProvider? gMyUserProvider;

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
  bool mounted = true;
  String version = "?.?.?";

  static MyUserProvider? get instance {
    //BuildContext? context = navKey?.currentContext;
    //if(context == null) return null;
    //return Provider.of<MyUserProvider>(context, listen: false);
    return gMyUserProvider;
  }

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

  MyUserProvider(GlobalKey<NavigatorState> nKey, this.hostKey) {
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

    PackageInfo.fromPlatform().then((packageInfo) {
      version = packageInfo.version + "." + packageInfo.buildNumber;
    });
    init();
    gMyUserProvider = this;
  }

  Future<void> init() async {
    initialized = false;

    // restore last user as a place holder in case they are offline
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("lastUser")) {
      String? user = prefs.getString("lastUser");
      if(user != null) {
        print("Found lastUser. Restoring $user");
        userFromJson(jsonDecode(user));
      }
    }

    // try to connect to establish last user
    try {
      userFromJson(await RPC().rpc("rest", "User", "whoami", {}, null, forceLogin: false));
    } on NotLoggedInException {

    } catch(e) {
      print(e);
      //dlg.showError(e.toString());
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

  static Future navTo(BuildContext context0, WidgetBuilder builder, {MyUserProvider? myUserProvider=null}) {
    return Navigator.of(context0).push(MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider<MyUserProvider>.value(
              value: myUserProvider != null ? myUserProvider : Provider.of<MyUserProvider>(context0, listen: false),
              builder: (context, widget) {
                return builder(context);
              }
          );
        }
    ));
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

      if(navKey?.currentContext != null) {
        navTo(navKey!.currentContext!, (context) => PasswordReset2(email, rId), myUserProvider: this);
      } else {
        print("Password reset error: ${navKey} ${navKey?.currentContext}");
      }
    }
  }
  Future<void> goToLogin() async {
    BuildContext? context = navKey?.currentState?.context;
    if(context == null) {
      return;
    }
    await navTo(context, (context) => Login(), myUserProvider: this);
    print("goToLogin done");
  }

  void userFromJson(Map user) {
    print("user: $user");
    Map<String, dynamic> m = {};
    user.forEach((k,v) {
      m[k.toString()] = v;
    });
    _user = MyUser.fromJson(m);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("lastUser", jsonEncode(m));
    });
    notifyListeners();
  }

  Future<void> login(String email, String passwd, {bool raise=false}) async {
    print("Login $email");
    try {
      userFromJson(await RPC().rpc("rest", "User", "login",  {"username": email, "password": passwd}, "Logging In"));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("email", email);
      await prefs.setString("password", passwd);
      Cart.email = email;
    } catch(e) {
      if(raise) {
        throw(e);
      } else {
        dlg.showError("$e");
      }
    }
  }

  Future<void> logout() async {
    await RPC().rpc("rest", "User", "logout",  {}, "Logging Out");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("email");
    await prefs.remove("password");
    _user = null;
    Cart.email = "";
    notifyListeners();
  }
}


class Login extends StatefulWidget {
  Login();
  @override LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _loginFormKey = GlobalKey<FormState>();
  String? err;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double loginWidth = width < 300 ? width - 10: 300;
    return Consumer<MyUserProvider>(builder: (context, myUser, widget)
    {
      return Scaffold(
        appBar: AppBar(title: Text("Login")),
        body: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Container(width: 0)),
              Text("Login", style: Theme
                  .of(context)
                  .textTheme
                  .headline5),
              Container(height: 10),
              err == null ? Container(height: 0) : Text(
                  "$err", style: TextStyle(color: Theme
                  .of(context)
                  .errorColor)),
              Container(height: 10),
              Container(width: loginWidth, child: TextFormField(
                initialValue: myUser.tmpEmail,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (newValue) {
                  myUser.tmpEmail = newValue.trim();
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
                initialValue: myUser.tmpPasswd,
                obscureText: true,
                onChanged: (newValue) {
                  myUser.tmpPasswd = newValue;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              )),
              Container(height: 10),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    err = null;
                  });
                  if (!(_loginFormKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  try {
                    await myUser.login(myUser.tmpEmail, myUser.tmpPasswd, raise: true);
                    Navigator.pop(context, 'Login');
                  } catch (e) {
                    print(e);
                    setState(() {
                      err = "$e";
                    });
                  }
                },
                child: const Text('Login'),
              ),
              Expanded(child: Container(width: 0)),
              TextButton(
                onPressed: () async {
                  await MyUserProvider.navTo(context, (context) => PasswordReset1(), myUserProvider: myUser);
                },
                child: const Text("Setup/Forgot Password"),
              ),
            ],
          ),
        ),
      );
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
        return Scaffold(
          appBar: AppBar(title: Text("Password")),
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
      return Scaffold(
        appBar: AppBar(title: Text("Password")),
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
