library db;
import 'dart:io';
import "dart:ui";
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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_links/app_links.dart';

GlobalKey<NavigatorState>? navKey;
MyUserProvider? gMyUserProvider;

BuildContext get gContext {
  BuildContext? context = navKey?.currentContext;
  if(context == null) {
    throw("navKey.currentContext is null. Call dialog init() function");
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
    print("MyUserProvider Constructor ${nKey}");
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
    if(gMyUserProvider == null) {
      gMyUserProvider = this;
    }
  }

  Future<void> init({bool offline_ok: true}) async {
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

    while(!offline_ok) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        dlg.showBusy("No Internet Detected. Please connect to internet to proceed.");
        await Future.delayed(Duration(seconds: 4));
        dlg.closeBusy();
      } else {
        break;
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

    /* handle uni_links/app links */
    final appLinks = AppLinks();
    final sub = appLinks.uriLinkStream.listen((uri) {
       var link = uri.toString();
       print('link: $link');
       if (link != null) {
          processLink(link.toString());
       }
    });// get the initial universal/deep link
    /* handle uni_links/app links */
    final appLinks = AppLinks();
    final sub = appLinks.uriLinkStream.listen((uri) {
       var link = uri.toString();
       print('link: $link');
       if (link != null) {
          processLink(link.toString());
       }
    });// get the initial universal/deep link

    initialized = true;
    notifyListeners();
  }

  static Future navTo({required WidgetBuilder builder, bool replace=false}) {
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider<MyUserProvider>.value(
              value: gMyUserProvider!,
              builder: (context, widget) {
                return builder(context);
              }
          );
        }
    );
    return replace ? Navigator.of(gContext).pushReplacement(route) : Navigator.of(gContext).push(route);
  }

  void processLink(String link) {
    if (link == null || !mounted) {
      return;
    }
    if (link.contains("password/reset")) {
      List m = link.split("/");
      String email = m[m.length-2];
      String rId = m[m.length-1];
      print("EMAIL=$email rId=$rId");

      if(navKey?.currentContext != null) {
        navTo(builder: (context) => PasswordReset2(email, rId));
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
    await navTo(builder: (context) => Login());
    print("goToLogin done");
  }

  void userFromJson(Map user) {
    print("user: $user");
    Map<String, dynamic> m = {};
    user.forEach((k,v) {
      m[k.toString()] = v;
    });
    _user = MyUser.fromJson(m);
    if(_user != null && m["profile"] != null) {
      _user!.profile = TrainingProfile.fromJson(m["profile"]);
      //_user!.profile!.user = _user;
    }
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
    await prefs.clear();
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
  bool _passwordVisible=false;
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
              err == null ? Container(height: 0) : Text(
                  "$err", style: TextStyle(color: Colors.red)),
              Container(height: 50),
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
                textInputAction: TextInputAction.next,
                autofillHints: [AutofillHints.email],
              )),
              Container(height: 30),
              Container(width: loginWidth, child: TextFormField(
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() { _passwordVisible = !_passwordVisible; });
                      }
                  ),
                ),
                textInputAction: TextInputAction.done,
                initialValue: myUser.tmpPasswd,
                onChanged: (newValue) {
                  myUser.tmpPasswd = newValue;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                autofillHints: [AutofillHints.password],
              )),
              Container(height: 50),
              SizedBox(width: loginWidth, child: ElevatedButton(
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
                child: const Text('LOGIN'),
              )),
              Container(height: 20),
              SizedBox(width: loginWidth, child: OutlinedButton(
                onPressed: () async {
                  await MyUserProvider.navTo(builder: (context) => PasswordReset1());
                },
                child: const Text('SETUP ACCOUNT'),
              )),
              Container(height: 30),
              TextButton(
                onPressed: () async {
                  await MyUserProvider.navTo(builder: (context) => PasswordReset1());
                },
                child: const Text("FORGOT PASSWORD"),
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
                Container(height: 50),
                Text("Setup Account/Forgot Password", style: Theme.of(context).textTheme.titleMedium),
                Text("(For Race Participants Only)", style: Theme.of(context).textTheme.bodyMedium),
                Container(height: 30),
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
                Container(height: 30),
                SizedBox(width: loginWidth, child: ElevatedButton(
                    child: Text("SUBMIT"),
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
                )),
                Container(height: 50),
                Container(padding: EdgeInsets.all(40), child: Text("Spectator? Head back to the home screen and follow the links to Track your participant.", textAlign:TextAlign.center, style: Theme.of(context).textTheme.bodyLarge)),
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
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;

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
              Container(height: 40),
              Text("Set Password for", style: Theme.of(context).textTheme.titleMedium),
              Text("${widget.email}", style: Theme.of(context).textTheme.titleMedium),
              Container(height: 20),
              Container(width: loginWidth, child: TextFormField(
                obscureText: !_passwordVisible1,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                      icon: Icon(_passwordVisible1 ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() { _passwordVisible1 = !_passwordVisible1; });
                      }
                  ),
                ),
                initialValue: passwd1,
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
              Container(height: 20),
              Container(width: loginWidth, child: TextFormField(
                obscureText: !_passwordVisible2,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                      icon: Icon(_passwordVisible2 ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() { _passwordVisible2 = !_passwordVisible2; });
                      }
                  ),
                ),
                initialValue: passwd2,
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
              Container(height: 20),
              Container(width: loginWidth, child:
                ElevatedButton(
                  child: Text("SUBMIT"),
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
              )),
              Expanded(child: Container()),
            ],
          ),
        ),
      );
    });
  }
}
