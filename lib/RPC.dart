library db;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
//import 'package:dio/adapter_browser.dart';
//import 'package:dio_cookie_manager/dio_cookie_manager.dart';
//import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'dialogs.dart' as dlg;
import 'state.dart';
import 'package:flutter/material.dart';
//import 'main.dart' as mn;
//import 'package:connectivity/connectivity.dart';

class NotLoggedInException implements Exception {
  String errMsg() => "Not Logged In";
}
class ConnectionException implements Exception {
  String errMsg() => "Connection failed";
  String toString() => 'Connection failed';
}

class RPC {
  // make this a singleton. call RPCs by using the RPC().rpc(mod, view, func) method
  static final RPC _rpc = RPC._internal();

  factory RPC() => _rpc;

  RPC._internal();

//  static final server = "http://192.168.75.157:8080";
//  static final server = "http://192.168.75.5:8080";
  static final server = "https://backend.brooksee.com";
//  PersistCookieJar? cookieJar;
  Timer? retryTimer;
  final Dio dio = Dio();
  Function? notLoggedInHandler;
  String? session;

  void registerNotLoggedInHandler(Function f) {
    notLoggedInHandler = f;
  }

  Future<void> rpcEnsure([Map? args=null]) async {
    // tries to perform the requested rpc. if it fails, saves it to try later
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList("rpc") ?? <String>[];
    if(args != null) {
      queue.add(jsonEncode(args));
    }
    print("RPC ENSURE QUEUE: ${queue}");
    List<String> failures = [];
    for(int idx=0; idx<queue.length; idx++) {
      try {
        Map arg = jsonDecode(queue[idx]);
        await rpc(arg["mod"], arg["view"], arg["func"], arg["args"], arg["msg"]);
      } catch(e) {
        failures.add(queue[idx]);
      }
    }
    prefs.setStringList("rpc",failures);
    if(failures.length > 0) {
      print("RPC ENSURE DELAY ON: ${failures}");
      if(retryTimer == null) {
        retryTimer = Timer.periodic(Duration(minutes: kReleaseMode ? 10: 1), (evt) {
          rpcEnsure();
        });
      }
    } else {
      if(retryTimer != null) {
        retryTimer?.cancel();
        retryTimer = null;
      }
    }
  }

  String getCacheKey(String mod, String view, String func, Map args) {
    final String path = '/rest/$mod/$view/$func';
    final String url = '$server$path';
    String key = "$url";
    key = "${MyUserProvider.instance?.user?.id}/$key/${jsonEncode(args)}";
    print("OFFLINE KEY: $key");
    return key;
  }

  Future<Map?> fromCache(String mod, String view, String func, Map args) async {
    String key = getCacheKey(mod, view, func, args);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey(key)) {
      print("Cache hit.");
      String? cache = prefs.getString(key);
      if (cache != null) {
        return jsonDecode(cache);
      }
    }
    return null;
  }
  String getWebPageUrl(String mod, String view, String func) {
    final String path = '/rest/$mod/$view/$func';
    final String url = '$server$path';
    return url;
  }

  Future<Map> rpc(String mod, String view, String func, Map args, String? msg, {bool retryLogin : true, bool forceLogin : true, bool useSnackBarMsg: false, bool cache: false }) async {
    // retryLogin: when true, will try cached login credentials behind the scenes to log back in for the user
    // forceLogin: when true, will launch a login screen for the user to login
    // cache: when true, result is saved off and can be restored with the fromCache() method
    final String path = '/rest/$mod/$view/$func';
    final String url = '$server$path';
    String key = getCacheKey(mod, view, func, args);
    final bool showProgress = msg != null;
    useSnackBarMsg = useSnackBarMsg && gContext != null;
    if (showProgress) {
      if(useSnackBarMsg) {
        ScaffoldMessenger.of(gContext).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(gContext).primaryColor,
          duration: Duration(days: 100),
        ));
      } else {
        dlg.showBusy(msg);
      }
    }
    try {
      print("rpc: $url");
      final Map body = {
        'args': (args == null) ? {} : args,
        'context': {},
      };

      print(" body:" + body.toString());


  /*    var connectivityResult = await (Connectivity().checkConnectivity());
     if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        // we're good
      } else {
        if(showProgress) {
          if (showProgress) dlg.doneBusy(context);
          dlg.showError(context, "No Internet Connection Detected. Please enable Internet and try again");
        }
        throw Exception("No Internet");
      }
  */

      // perform the post to the server
  /*    if(cookieJar == null) {
        if(kIsWeb) {
          var adapter = BrowserHttpClientAdapter();
          adapter.withCredentials = true;
          dio.httpClientAdapter = adapter;
          cookieJar = PersistCookieJar();
        } else {
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          cookieJar = PersistCookieJar(storage: FileStorage(appDocPath + "/.cookies/"));
          if(cookieJar != null) {
            dio.interceptors.add(CookieManager(cookieJar!));
          }
        }
      }
  */
      if(session == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        session = prefs.getString("SESSION");
        print("SESSION=${session}");
      }
      var response;
      try {
        Map<String, dynamic> headers = {};
        if(session != null) {
          headers["x-session"] = session;
        }
        response = await dio.post(url, data: body, options: Options(headers: headers));
      } on DioError catch(e) {
        print("$e");
        /* if(cache) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if(prefs.containsKey(key)) {
            print("Cache hit.");
            String? cache = prefs.getString(key);
            if(cache != null) {
              return jsonDecode(cache);
            }
          } else {
            print("Cache miss.");
          }
        } */
        if(e.message.startsWith("SocketException: Failed host lookup")) {
          throw ConnectionException();
        } else {
          throw e;
        }
      }
      print(" body: ${response.data}");
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        final result = response.data;
        if(result["session"] != null) {
          if(session != result["session"]) {
            session = result["session"];
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("SESSION", session!);
            print("Set SESSION=${session}");
          }
        }
        if (result["status"] == "ERROR") {
          if(retryLogin) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String email = prefs.getString("email") ?? "";
            String password = prefs.getString("password") ?? "";
            print("email=${email} password=${password}");
            if (email.isNotEmpty && password.isNotEmpty) {
              bool failed = true;
              try {
                await RPC().rpc("rest", "User", "login",  {"username": email, "password": password}, null, retryLogin: false, forceLogin: forceLogin, useSnackBarMsg: useSnackBarMsg);
                failed = false;
              } catch(e) {
                failed = true;
              }
              if(!failed) {
                return await rpc(mod, view, func, args, null, retryLogin: false);
              }
            }
          }
          if (result["result"] == "Not Logged In") {
            if(forceLogin) {
              print("FETCHING LOGIN PAGE $mod $view $func");
              try {
                await MyUserProvider.instance?.goToLogin();
              } catch (e) {
                print(e);
              }
            }
            notLoggedInHandler?.call();
            throw NotLoggedInException();
          } else {
            throw Exception(result["result"]);
          }
        } else if (result["status"] == "OK") {
          if(cache) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString(key, jsonEncode(result["result"] ?? {}));
            print("OFFILE KEY: $key");
          }
          return result["result"] ?? {};
        } else {
          throw Exception("Unkonwn response");
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed with statusCode=$response.statusCode');
      }
    } finally {
      if (showProgress) {
        if(useSnackBarMsg) {
          ScaffoldMessenger.of(gContext).hideCurrentSnackBar();
        } else {
          dlg.closeBusy();
        }
      }
    }
    return {};
  }

  Future<String> fileDownload(String url, String filename) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    filename = filename.replaceAll(" ","");
    String savePath = p.join(appDocDir.path, filename);
    var dio = Dio();
    print("RPC.fileDownload ${url} $filename");
    await dio.download(url, savePath);
    print("RPC.fileDownload complete");
    return savePath;
  }
}
