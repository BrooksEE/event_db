library db;
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' hide context;
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'state.dart';

void showError(String msg, [VoidCallback? cb=null]) {
  showMsg("Error", msg, cb);
}

void show(String title, String msg, Function builder) {
  showDialog(
    context: gContext,
    builder: (BuildContext context) {
      return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(msg)),
          actions: builder(context),
      );
    }
  );
}

void confirm(String title, String msg, Function cbConfirm, Function cbCancel) {
  show(title, msg, (context) {
    return <Widget>[
      TextButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
          cbCancel();
        },
      ),
      TextButton(
        child: Text("Ok"),
        onPressed: () {
          Navigator.of(context).pop();
          cbConfirm();
        },
      ),
    ];
  });
}

void showMsg(String title, String msg, [VoidCallback? cb=null]) {
  return show(title, msg, (context) {
    return <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                if(cb != null) {
                  cb();
                }
              },
            ),
          ];
  });
}

void showBusy(String msg) {
  showDialog(
    context: gContext,
    barrierDismissible: false, // user can't dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              Container(height: 20),
              Text(msg),
            ]),
      );
    },
  );
}

void closeBusy() {
  Navigator.pop(gContext);
}



class ImageDialog extends StatefulWidget {
  String url;
  ImageDialog(this.url, {Key? key}) : super(key: key);

  static Future<void> show(BuildContext context, String url) async {
    await showDialog(
        context: context,
        builder: (_) => ImageDialog(url)
    );
  }

  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromARGB(0,0,0,0),
      child: Column(children: <Widget>[
        Expanded(child:
//        width: 200,
//        height: 200,
         PhotoView(
           backgroundDecoration: BoxDecoration(
             color: Color.fromARGB(0,0,0,0),
           ),
             loadingBuilder: (context, event) {
             return Center(child: CircularProgressIndicator());
             },
             imageProvider: NetworkImage(widget.url)
         ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget> [

        FlatButton(child: Text("Dismiss", style:TextStyle(color: Colors.white)),
          color: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ])
    ]));
  }
}
