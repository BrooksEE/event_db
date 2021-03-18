library db;
import 'db.dart';
import 'RPC.dart';
import 'dialogs.dart' as dlg;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  MyUser? get user => _user;

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

  MyUserProvider(GlobalKey<NavigatorState> nKey) {
    print("MyUserProvider Constructor");
    navKey = nKey;
    RPC().registerNotLoggedInHandler(() async {
      _user = null;
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
    initialized = true;
    notifyListeners();
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
  Login({Key? key, required this.childBuilder, required this.scaffoldBuilder }) : super(key: key);
  ChildBuilder childBuilder;
  ScaffoldBuilder scaffoldBuilder;

  @override LoginState createState() => LoginState();
}


class LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Provider.of<MyUserProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyUserProvider>(builder: (context, myUserProvider, child) {
      if(!myUserProvider.initialized) {
        return widget.scaffoldBuilder (
          context,
          appBarTitle: ("Initializing"),
          body: Center(child: CircularProgressIndicator()),
        );
      } else if(myUserProvider._user == null) {
        String email = "";
        String passwd = "";
        double width = MediaQuery.of(context).size.width;
        double loginWidth = width < 300 ? width - 10: 300;
        return widget.scaffoldBuilder(
          context,
          appBarTitle: "Login",
          body: Column(
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
                    myUserProvider.tmpEmail = newValue;
                  }
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
              )),
              Container(height: 10),
              ElevatedButton(
                  child: Text("Login"),
                  onPressed: (myUserProvider.tmpEmail.isEmpty || myUserProvider.tmpPasswd.isEmpty) ? null : () {
                    myUserProvider.login(myUserProvider.tmpEmail, myUserProvider.tmpPasswd);
                  }
              ),
              Expanded(child: Container()),
            ],
          ),
        );
      } else {
        return widget.childBuilder.call(context);
      }
    });
  }
}