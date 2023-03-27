library db;
import 'forms.dart';
import 'db.dart';
import 'RPC.dart';
import 'dialogs.dart' as dlg;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'cart.dart';
import 'state.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

// TODO:
//  - Waves (change as a dependacny
//  - Option Inventory
//  - Teams
//  - Pricing Table
//  - Rewards points?

class RegForm  {
  final _formKey = GlobalKey<FormState>();
  MyFormController? myFormController;
  Race? race;
  Map? info;
  Amount? origAmt;
  String? origLabel;
  //Map inventory;

  Future<void> init(int race_id, Map? setup, State<StatefulWidget> state) async {
    myFormController = MyFormController(_formKey,
      setCartItemName: (Field f) {
        if(f.key=='event') {
          ChoiceField c = f as ChoiceField;
          return "${c.choice?.label} - ${race?.getName}";
        }
        return null;
      },
      setCartItemDesc: (Field f) {
        if(f.key == 'event') {
          Field? firstname = myFormController!.getField('firstname');
          Field? lastname  = myFormController!.getField('lastname');
          return "${firstname == null ? "" : firstname.value} ${lastname == null ? "" : lastname.value}";
        }
        return null;
      },
    );
    try {
      Map args = {"race_id":race_id};
      if(setup != null && setup["initialize"] != null) {
        args["initialize"] = setup["initialize"];
      }
      Map form_data = await RPC().rpc("event", "Info", "get_reg_form", args, null);
      race = Race.fromJson(form_data["race"]);
      print("FORM: ${form_data["form"]}");
      print("INVENTORY: ${form_data["inventory"]}");
      //inventory = form_data["inventory"];
      if(form_data["form"] != null) {
        form_data["form"].forEach((f) {
          if(f == null) { return; }
          switch(f["key"]) {
            case "firstname": { f["autofillHints"] = ["givenName"];        f["keyboardType"] = "name";         f["textCapitalization"] = "words"; break; }
            case "lastname":  { f["autofillHints"] = ["familyName"];       f["keyboardType"] = "name";         f["textCapitalization"] = "words"; break; }
            case "email":     { f["autofillHints"] = ["email"];            f["keyboardType"] = "emailAddress"; break; }
            case "phone":     { f["autofillHints"] = ["telephoneNumber"];  f["keyboardType"] = "phone";        break; }
            case "address":   { f["autofillHints"] = ["fullStreetAddress"];f["keyboardType"] = "streetAddress"; f["textCapitalization"] = "words"; break; }
            case "city":      { f["autofillHints"] = ["addressCity"];      f["keyboardType"] = "text";          f["textCapitalization"] = "words"; break; }
            case "zip":       { f["autofillHints"] = ["postalCode"];       f["keyboardType"] = "text"; break; }
            case "emergencyname":{                                         f["keyboardType"] = "name";        f["textCapitalization"] = "words"; break; }
            case "emergencyphone":{                                        f["keyboardType"] = "phone"; break; }
          }
          print("HERE ${f}");
        });
        if(setup != null && setup["fields"] != null) {
          print("FIELDS1: ${form_data["form"].map((f) { return f["key"]; }).toList()}");
          form_data["form"].retainWhere((f) {
            return setup["fields"].indexWhere((key) { return key == f["key"]; }) != -1 || f["key"] == "race_event";
          });
          if(!(setup["initialize"] ?? true)) {
            form_data["form"].forEach((f) {
              f.remove("initial");
            });
          }
          print("FIELDS2: ${setup["fields"]}");
          if(setup["fields"].indexOf("bib") >= 0) {
            form_data["form"].add(
              {"key": "bib", "label": "Bib #", "widget":"TextInput", "keyboardType": "number", "required": true },
            );
          }
        }
      }
      myFormController!.fromJSON(form_data["form"]);
      if(form_data["team_rules"] != null && (setup == null || setup["fields"] == null || setup["fields"].indexOf("team") >= 0)) {
        myFormController!.insertField(0, TeamField.fromJSON(race!, form_data["team_rules"], state));
      }
      myFormController!.fields.forEach((Field field) {
        String key = field.key;
        if(key.startsWith("option")) {
          field.listen((value) {
            print("HERE: ${field} ${value}");
          });
        }
      });
      if(setup != null) {
        print("DATA: ${setup}");
        if(setup["race_event_id"] != null) {
          print("DATA TYPE: ${setup["race_event_id"].runtimeType}");
          RadioField? event = myFormController!.getField("event") as RadioField?;
          if(event != null) {
            String reid = setup["race_event_id"].toString();
            event.value = event.initial = reid;
            event.initial = setup["race_event_id"];
            event.choices.removeWhere((choice) {
              print("REMOVE: ${choice.key} ${choice.key.runtimeType} ${reid}");
              return choice.key != reid;
            });
            if(setup["points"] != null && event.choices.length > 0) {
              int points = setup["points"];
              Choice choice = event.choices[0];
              origLabel = choice.label;
              choice.label = "${choice.label} - ${points} Points";
              origAmt = choice.amt;
              choice.amt = Amount(0, "USD");
            }
            if(setup["cost"] != null && event.choices.length > 0) {
              Choice choice = event.choices[0];
              origAmt = choice.amt;
              choice.amt = setup["cost"];
            }
          }
        }
      }
      info = form_data;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);
      dlg.showError(e.toString());
    }
  }

}


class TeamField extends Field<int> {
  late Map info;
  Race race;
  Map? team;
  late TextEditingController joinTeamController;
  State parent;

  TeamField.fromJSON(this.race, Map j, this.parent) {
    key = "team";
    label = "Join Team";
    value = initial = null;
    //required = false;
    //String widget;
    type = "Team Discount";
    //Map<String, dynamic> data;
    //String errorTxt;
    //Map<String, dynamic> cart_info;
    info = j;
    joinTeamController = TextEditingController();
  }

  CartItem? addToCart(CartItem? parent, MyFormController controller) {
    print("ADDTOCART: ${label} ${value}");
    if(value != null) {
      CartItem item = CartItem(
        "team_discount", //type
        "Team Discount", // name
        team!["name"], //desc
        info["discount_type"] == 0 ? Amount.fromDouble(-info["discount"], "USD") : Amount((-(parent?.amt.amt ?? 0)*info["discount"]).round(), "USD"),
        1, //qty,
        data: {"team_id" : team!["id"]},
        parent: parent,
        shippingRequired: false,
        onComplete: null,
        deletable: false,
      );
      Cart.addItem(item);
      return item;
    }
  }

  @override Widget getWidget(State<StatefulWidget> state, BuildContext context) {
    return (team == null) ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Team Registration", style: TextStyle(fontWeight: FontWeight.bold)),
          Html(data: info["blurp"]),
          ElevatedButton(
            child: Text("Tell Me More"),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return Scaffold(
                      appBar: AppBar(title: Text("Team Rules")),
                      body: Html(data: info["rules"]),
                    );
                  })
              );
            },
          ),
          ElevatedButton(
            child: Text("Create A Team"),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  //{"info":info, "race": race, "setTeam": setTeam});
                  return TeamCreate(race, info, setTeam);
                })
              );
            },
          ),
          ElevatedButton(
              child: Text("Join A Team"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text("Join Team"),
                        content: Padding(padding: EdgeInsets.only(top: 10, bottom: 0), child: TextFormField(
                          controller: joinTeamController,
                          decoration: InputDecoration(
                            labelText: "Team Name or Captain's Email",
                          ),
                        )),
                        actions: <Widget>[
                          TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          TextButton(
                              child: Text("Join"),
                              onPressed: () async {
                                Map result;
                                try {
                                  result = await RPC().rpc(
                                      "teams",
                                      "Teams",
                                      "join",
                                      {
                                        "race_id": race.id,
                                        "name_or_email": joinTeamController.text,
                                      },
                                      "Checking Code");
                                } catch (e) {
                                  dlg.showError(e.toString());
                                  return;
                                }
                                setTeam(result["team"]);
                                Navigator.pop(context);
                              })
                        ]);
                  },
                );
              }
          )
        ])  : Text("You are joining team: ${team!["name"]}", style: TextStyle(fontWeight: FontWeight.bold));
  }

  void setTeam(Map team) {
    parent.setState(() {
      print("SET TEAM: ${team}");
      this.team = team;
      value = this.team!["id"];
    });
  }
}

class TeamCreate extends StatefulWidget {
  Race race;
  Map info;
  Function(Map) setTeam;
  TeamCreate(this.race, this.info, this.setTeam) : super();

  @override _TeamCreateState createState() => _TeamCreateState();
}

class _TeamCreateState extends State<TeamCreate> {
  final _formKey = GlobalKey<FormState>();
  MyFormController? myFormController;
  @override
  void initState() {
    myFormController = MyFormController(_formKey);
    MyUserProvider? myUser = MyUserProvider.instance;
    myFormController!.fromJSON([
      {
        "widget"             : "TextInput",
        "label"              : "Team Name",
        "key"                : "name",
        "required"           : true,
        "autofillHints"      : ["name"],
        "keyboardType"       : "name",
        "textCapitalization" : "words",
        "type"               : "",
      },
      {
        "widget": "TextInput",
        "label" : "Team Captain's Name",
        "key"   : "captain",
        "required": true,
        "autofillHints"      : ["name"],
        "keyboardType"       : "name",
        "textCapitalization" : "words",
        "initial"            : myUser?.user?.name ?? "",
        "type"               : "",
      },
      {
        "widget": "EmailInput",
        "label" : "Team Captain's Email",
        "key"   : "email",
        "required": true,
        "autofillHints"      : ["email"],
        "keyboardType"       : "email",
        "initial"            : myUser?.user?.email ?? "",
        "type"               : "",
      },
      {
        "widget": "TextInput",
        "label" : "Team Description",
        "key"   : "desc",
        "required": false,
        "multiline" : true,
        "type"               : "",
      },
    ]);
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> init() async {
  }

  Future<void> createTeam() async {
    try{
      Map args = myFormController!.getFormData();
      args["race_id"] = widget.race.id;
      Map data = await RPC().rpc("teams","Teams","create", args, "Creating Team...");
      print("NEW TEAM: ${data["team"]}");
      widget.setTeam(data["team"]);
      Navigator.pop(context);
    } catch(e) {
      dlg.showError(e.toString());
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Create Team")),
        body: myFormController == null ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child:   AutoSizeText(widget.race.getName, maxLines: 1, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
                ),
                Container(padding: EdgeInsets.all(10), child: Text("Create Team", textAlign: TextAlign.center,)),
                Column(children: <Widget> [
                  Container(padding: EdgeInsets.only(left: 20, right: 20), child: MyForm(controller: myFormController!)),
                  Container(padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10), child: ElevatedButton(
                    onPressed: () async {
                      if(myFormController!.validate()) {
                        await createTeam();
                      }
                      setState(() {

                      });
                    },
                    child: Text("Create"),
                  )),
                  Container(height: 100),
                ]),
              ],
            )
        )
    );
  }
}
