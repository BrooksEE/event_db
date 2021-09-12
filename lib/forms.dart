library db;
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'RPC.dart';
import 'db.dart';
import 'cart.dart';
import 'dart:math';
import 'dialogs.dart' as dlg;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info/device_info.dart';
import "dart:io";
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


typedef SetCartItemDesc = String? Function(Field);
typedef SetCartItemName = String? Function(Field);

class MyFormController {
  GlobalKey<FormState> key;
  final List<Field> fields = [];
  SetCartItemName? setCartItemName;
  SetCartItemDesc? setCartItemDesc;

  MyFormController(this.key, {
    this.setCartItemName : null,
    this.setCartItemDesc : null,
  });

  bool validate() {
    bool passing = true;
    for(int idx=0; idx<fields.length; idx++) {
      String? err = fields[idx].validate();
      if(err != null) {
        passing = false;
      }
    }
    passing = passing && (key.currentState?.validate() ?? false);
    return passing;
  }

  Field? getField(String key) {
    for(int idx=0; idx<fields.length; idx++) {
      Field f=fields[idx];
      if(f.key == key) {
        return f;
      }
    }
    return null;
  }

  Map<String, dynamic> getFormData() {
    Map<String, dynamic> data = {};
    for(int idx=0; idx<fields.length; idx++) {
      Field f=fields[idx];
      data[f.key] = f.getValue();
    }
    return data;
  }

  List<CartItem> addToCart({String? parent_key: null}) {
    List<CartItem> items = [];
    CartItem? parent = null;
    if(parent_key != null) {
      for(int idx=0; idx<fields.length; idx++) {
        Field field = fields[idx];
        if(field.key == parent_key) {
          CartItem? item = field.addToCart(null, this);
          if(item != null) {
            items.add(item);
            parent = _setParent(item);
          }
        }
      }
    }
    for(int idx=0; idx<fields.length; idx++) {
      Field field = fields[idx];
      if(field.key == parent_key) {
        continue;
      }
      CartItem? item = field.addToCart(parent, this);
      if(item != null) {
        items.add(item);
        if (parent == null) {
          parent = _setParent(item);
        }
      }
    }
    return items;
  }

  CartItem _setParent(CartItem item) {
    if(item.data == null) {
      item.data = {};
    }
    item.data!["__form__"] = getFormData();
    print("FORMDATA: ${item.data!["__form__"]}");
    return item;
  }

  String? getCartItemDescription(Field f) {
    return this.setCartItemDesc?.call(f);
  }

  String? getCartItemName(Field f) {
    return this.setCartItemName?.call(f);
  }

  void addField(Field f) {
    print("FIELD: ${f}");
    fields.add(f);
  }
  void insertField(int idx, Field f) {
    print("FIELD: ${f}");
    fields.insert(idx, f);
  }

  void fromJSON(List<dynamic> fs) {
    this.setCartItemDesc = setCartItemDesc;
    this.setCartItemName = setCartItemName;
    fs.forEach((f) {
      print("JSON: $f");
      print("CART_INFO: ${f["cart_info"]}");
      if(f["active"] != null && !f["active"]) {
        return;
      }
      switch(f["widget"]) {
        case "TextInput":
        case "EmailInput": {
          addField(TextField.fromJSON(f));
          break;
        }
        case "RadioSelect": {
          addField(RadioField.fromJSON(f));
          break;
        }
        case "Select": {
          addField(SelectField.fromJSON(f));
          break;
        }
        case "CheckboxInput": {
          addField(CheckboxField.fromJSON(f));
          break;
        }
        case "MerchandiseInput": {
          addField(MerchField.fromJSON(f));
          break;
        }
        case "DateInput": {
          addField(DateField.fromJSON(f));
          break;
        }
        case "HiddenInput": {
          addField(HiddenField.fromJSON(f));
          break;
        }
        default: {
          addField(UnknownField.fromJSON(f));
          break;
        }
      }
    });
  }

}

abstract class Field<T> {
  late var key;
  late String label;
  late var value;
  late var initial;
  late bool required;
  late String widget;
  late String type;
  Map? data;
  String? errorTxt;
  Map? cart_info;
  Function(T)? changeListener;

  dynamic getValue() {
    return value;
  }

  void listen(Function(T) f) {
    changeListener = f;
  }

  Widget getWidget(State state, BuildContext context);

  String? validate() {
    errorTxt = _validate();
    return errorTxt;
  }

  String? _validate() {
    return null;
  }

  CartItem? addToCart(CartItem? parent, MyFormController controller) {
    return null;
  }

  void _fromJSON(Map j) {
    key = j["key"];
    label = j["label"];
    value = initial = j["initial"];
    required = j["required"];
    widget = j["widget"];
    type = j["type"];
    data = j["data"];
    cart_info = j["cart_info"];
  }

  String toString() {
    return "key=${key}, name=${label}";
  }
}

class TextField extends Field<String> {
  int? maxLen;
  late FocusNode focusNode;
  late TextEditingController controller;
  late List<String> autofillHints;
  TextInputType? keyboardType;
  TextCapitalization? textCapitalization;
  late bool multiline = false;

  TextField.fromJSON(Map j) {
    _fromJSON(j);
    maxLen = j["max_len"];
    focusNode = FocusNode();
    controller = TextEditingController();
    if(initial != null) {
      controller.text = initial;
    }
    if(j["multiline"] != null && j["multiline"]) {
      multiline = true;
    }
    autofillHints = [];
    if(j["autofillHints"] != null && j["autofillHints"] is List) {
      j["autofillHints"].forEach((String s) {
        switch(s) {
          case "givenName":        { autofillHints.add(AutofillHints.givenName);        break; }
          case "familyName":       { autofillHints.add(AutofillHints.familyName);       break; }
          case "email":            { autofillHints.add(AutofillHints.email);            break; }
          case "telephoneNumber":  { autofillHints.add(AutofillHints.telephoneNumber);  break; }
          case "fullStreetAddress":{ autofillHints.add(AutofillHints.fullStreetAddress);break; }
          case "addressCity":      { autofillHints.add(AutofillHints.addressCity);      break; }
          case "postalCode":       { autofillHints.add(AutofillHints.postalCode);       break; }
          case "name":             { autofillHints.add(AutofillHints.name);             break; }
        }
      });
    } else {
        print("NO AUOTFILL HINTS");
    }

    if(j["keyboardType"] != null) {
      switch(j["keyboardType"]) {
        case "name":         { keyboardType = TextInputType.name; break; }
        case "email":        { keyboardType = TextInputType.emailAddress; break; }
        case "phone":        { keyboardType = TextInputType.phone;        break; }
        case "streetAddress":{ keyboardType = TextInputType.streetAddress;break; }
        case "text":         { keyboardType = TextInputType.text;         break; }
        case "number":       { keyboardType = TextInputType.number;       break; }
      }
    }
    if(multiline) {
      keyboardType = TextInputType.multiline;
    }

    if(j["textCapitalization"] != null) {
      switch(j["textCapitalization"]) {
        case "words": { textCapitalization = TextCapitalization.words; break; }
      }
    }
    if(textCapitalization == null) {
      textCapitalization = TextCapitalization.none;
    }
    print("TEXTFIELD: ${keyboardType} ${textCapitalization} ${autofillHints}");
  }

  @override Widget getWidget(State state, BuildContext context) {
    return TextFormField(
        controller: controller,
        autofillHints: autofillHints,
        decoration: InputDecoration(
          labelText: label,
        ),
        onChanged: (e) {
          value = controller.text.trim();
        },
        focusNode: focusNode,
        inputFormatters: maxLen == null ? const [] : [ LengthLimitingTextInputFormatter(maxLen),],
        keyboardType: keyboardType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        maxLines: multiline ? null : 1,
        validator: (value) {
          if (this.required && (value?.isEmpty ?? false)) {
            focusNode.requestFocus();
            return 'Required';
          } else {
            return null;
          }
        }
    );
  }
}

class HiddenField extends Field<String> {
  HiddenField.fromJSON(Map j) {
    _fromJSON(j);
  }

  @override Widget getWidget(State state, BuildContext context) {
    return Container(height: 0);
  }
}

class DateField extends Field<DateTime> {
  late DateTime firstDate;
  late DateTime lastDate;
  DateField.fromJSON(Map j) {
    if(j["initial"] != null) {
      j["initial"] = DateTime.parse(j["initial"]);
    } else {
      j["initial"] = DateTime.now();
    }
    firstDate = DateTime.parse(j["firstDate"]);
    lastDate = DateTime.parse(j["lastDate"]);
    _fromJSON(j);
  }
  String getValue() {
    return value.toString();
  }
  @override Widget getWidget(State state, BuildContext context) {
    return InputDatePickerFormField(
      initialDate : value,
      firstDate: firstDate,
      lastDate: lastDate,
      fieldLabelText: label,
    );
  }
}

class MerchField extends Field<Map> {
  late Map merch;
  late Amount discount;
  Amount? regular_cost;
  late Amount cost;
  late Amount yourPrice;
  int? variant_id;
  int? qty;
  var _merchkey = GlobalKey();
  ExpandableController descController = ExpandableController();
  int photoPage = 0;
  MerchField.fromJSON(Map j) {
    _fromJSON(j);
    if(data == null || data!["item"] == null) {
      throw(Exception("Merch field meta data is required."));
    } else {
      merch = data!["item"]!;
    }
    print("MERCH: ${merch}");
    cost = Amount.fromDouble(merch["cost"] * 1.0, "USD");
    discount = Amount.fromDouble(data!["option"]["merchandise_discount"] * 1.0, "USD");
    regular_cost = merch["regular_cost"] == null ? null : Amount.fromDouble(merch["regular_cost"] * 1.0, "USD");
    yourPrice = Amount(cost.amt - discount.amt, cost.currency);
  }

  @override CartItem? addToCart(CartItem? parent, MyFormController controller) {
    print("ADDTOCART: ${label} ${value}");
    if(value ?? false) {
      CartItem item = CartItem(
          (cart_info ?? const {})["type"] ?? "merch", //type
          controller.setCartItemName?.call(this) ?? merch["name"], // name
          (controller.getCartItemDescription.call(this) ?? variant_id) != null && merch["variant_name"] != null ? "${merch["variant_name"]}: ${(this.variant ?? const {})["name"]}" : "", //desc
          yourPrice, // Amount
          qty ?? 1, //qty,
          data: {"merch_id" : merch["id"], "variant_id": variant_id, "key": key},
          parent: parent,
          thumb: (cart_info ?? const {})["thumb"],
          shippingRequired: (cart_info ?? const {})["shippingRequired"],
          onComplete: null,
          deletable: false,
      );
      Cart.addItem(item);
      return item;
    }
    return null;
  }

  @override String? _validate() {
    BuildContext? ctx = _merchkey.currentState?.context;
    if(value ?? false) {
      if(!merch["variant_name"].isEmpty) {
        if(variant_id == null) {
          if(ctx != null) Scrollable.ensureVisible.call(ctx);
          return "${merch["variant_name"]} Required";
        }
      }
      if(qty == null) {
        if(ctx != null) Scrollable.ensureVisible.call(ctx);
        return "Quantity Required";
      }
      return null;
    }
  }

  Map? get variant {
    if(variant_id == null) {
      return null;
    }
    for(int idx=0; idx<data!["variants"].length; idx++) {
      Map v = data!["variants"][idx];
      if(v["id"] == variant_id) {
        return v;
      }
    }
    return null;
  }

  @override Widget getWidget(State state, BuildContext context) {
    List variants = data!["variants"];
    Map? variant = this.variant;
    List photos = data!["photos"];
    Color bgColor = Color.fromARGB(0xFF, 0xe0, 0xe0, 0xe0);
    double rad=12;
    return Column(children: <Widget> [
      Container(height: 20),
      Container(
        padding: EdgeInsets.only(left:0, top: 20, bottom: 0, right: 20),
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child:
        Row(mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              Checkbox(
                key: _merchkey,
                value: this.value ?? false,
                onChanged: (value) {
                  state.setState(() {
                    this.value = value;
                  });
                }),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.start, children: <Widget> [
                    Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(children: [
                      Container(padding: EdgeInsets.only(top: 5, bottom: 5), child: Text("Regular Price: ")),
                      Container(padding: EdgeInsets.only(top: 5, bottom: 5), child: Text("${cost.display()}", style: TextStyle(decoration: TextDecoration.lineThrough)))
                    ]),
                    Text("Your Price: ${yourPrice.display()}"),
                    (errorTxt == null) ? Container(height: 0) : Container(padding: EdgeInsets.only(top: 20), child: Text(errorTxt!, style: TextStyle(color: Colors.red))),
                    (value ?? false) && !merch["variant_name"].isEmpty  ?
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: merch["variant_name"],
                      ),
                      value: variant_id,
                      items: data!["variants"].map<DropdownMenuItem<int>>((s) {
                        print(s);
                        bool sold_out = !(s["sell_when_sold_out"] || (s["inventory_count"] > 0));
                        return DropdownMenuItem<int>(
                            value: s["id"], child: Text("${s["name"]}${sold_out ? ' (SOLD OUT)' : ""}", style: sold_out ? TextStyle(color: Color.fromARGB(255, 0x80, 0x80, 0x80)) : TextStyle()));
                      }).toList(),
                      onChanged: (int? value) {
                        state.setState(() {
                          variant_id = value;
                          qty = null;
                        });
                      },
                    ) : Container(height: 0),
                    (this.value ?? false) && (variant == null || variant["sell_when_sold_out"] || variant["inventory_count"] > 0) ?
                    DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: "Quantity",
                        ),
                        value: qty,
                        items: List<int>.generate(variant == null || variant["sell_when_sold_out"] ? 20 : variant["inventory_count"], (i) => i + 1).map<DropdownMenuItem<int>>((q) {
                          return DropdownMenuItem<int>(
                              value: q, child: Text("$q"));
                        }).toList(),
                        onChanged: (value) {
                          state.setState(() {
                            qty = value;
                          });
                        }) : Container(height: 0),
                    Container(padding: EdgeInsets.only(top: 10, bottom: 5), child: AutoSizeText("${merch["shipping_info"]}", maxLines: 2, style: TextStyle(fontStyle: FontStyle.italic))),
                    Expandable(
                      controller: descController,
                      collapsed: GestureDetector(onTap: () {
                        print("here1 ${descController.expanded}");
                        state.setState(() { descController.toggle();});
                      }, child: Text(merch["desc"], softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,)),
                      expanded: GestureDetector(onTap: () {
                        print("here2 ${descController.expanded}");
                        state.setState(() { descController.toggle();});
                      }, child: Text(merch["desc"], softWrap: true, )),
                    ),
                  ])
              ),
            ]
        )),
        Container(height: 320,
            decoration: BoxDecoration(
              border: Border.all(width: 3.0, color: bgColor),
            ),
            child:
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(photos[index]["url_orig"]),
                  //initialScale: PhotoViewComputedScale.contained * 0.8,
                  //heroAttributes: PhotoViewHeroAttributes(tag: photos[index].id),
                  //minScale: 1.0,
                );
              },
              itemCount: photos.length,
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null || event.cumulativeBytesLoaded == null || event.expectedTotalBytes == null
                        ? 0
                        : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  ),
                ),
              ),
              backgroundDecoration: BoxDecoration(
                color: bgColor,
              ),
              //pageController: photoController,
              onPageChanged: (page) { state.setState(() { photoPage = page; }); },
            )),
            Container(height: rad*2.0,
            decoration: BoxDecoration(
              color: bgColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[Expanded(child: Container(height: 0)) ] + List<Widget>.generate(photos.length*2, (idx) {
                if(idx & 1 == 1) {
                  return Container(width: rad, height: rad,
                    decoration: BoxDecoration(
                      color: photoPage*2 == idx-1 ? Theme.of(context).primaryColor : bgColor,
                      borderRadius: BorderRadius.all(Radius.circular(rad/2)),
                      border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                    ),
                  );
                } else {
                  return Container(width: rad*0.75);
                }
              }) + <Widget>[Container(width: rad*0.75), Expanded(child: Container(height: 0)) ],
            ))
    ]);
  }
}

class Choice {
  String? key;
  String? label;
  bool disabled = false;
  Amount? amt;
  Choice.fromJSON(var j) {
    if (j is List) {
      key = j[0].toString();
      label = j[1].toString();
      disabled = false;
    } else {
      key = j["key"].toString();
      label = j["name"];
      disabled = j["disabled"] ?? false;
      amt = j["cost"] != null ? Amount.fromDouble(j["cost"], j["currency"]) : null;
    }
  }
  String toString() {
    return "CHOICE: ${label}";
  }
}

abstract class ChoiceField extends Field<String> {
  var _choicekey = GlobalKey();
  final List<Choice> choices = [];
  Choice? get choice { int idx = choices.indexWhere((e) {
      return e.key.toString() == this.value.toString();
    });
    return idx < 0 ? null : choices[idx];
  }
  ChoiceField.fromJSON(Map j) {
    _fromJSON(j);
    j["choices"].forEach((c) {
      Choice choice = Choice.fromJSON(c);
      choices.add(choice);
      //print(choice);
    });
  }
  @override
  CartItem? addToCart(CartItem? parent, MyFormController controller) {
    Choice? c = choice;
    print("ADDTOCART: ${label} ${c} cart_info=${cart_info} choice.amt=${c != null ? c.amt : ""}  parent=${parent}");
    if(cart_info != null && c != null && c.amt != null && (c.amt?.amt ?? 0) > 0) {

      CartItem item = CartItem(
              cart_info!["type"], //type
              controller.setCartItemName?.call(this) ?? c.label ?? "?", // name
              controller.getCartItemDescription.call(this) ?? "", //desc
              c.amt!, // Amount
              1, //qty,
              data: {"key" : this.key, "value": value },
              parent: parent,
              thumb: cart_info!["thumb"],
              shippingRequired: cart_info!["shippingRequired"],
              onComplete: null,
              deletable: parent == null, // can't delete children because it will effect the form choices and not sure how to resolve that.
      );
      Cart.addItem(item);
      return item;
    }
    return null;
  }
}

class RadioField extends ChoiceField {
  RadioField.fromJSON(Map j) : super.fromJSON(j);

  @override Widget getWidget(State state, BuildContext context) {
    return choices.length == 0 ? Container(height: 0) : RadioFormField(
      key: _choicekey,
      radioField: this,
      validator: (value) {
        //print("VALIDATOR: ${value} ${this.key} ${this.value} ${this.required}");
        if(this.required && this.value == null) {
          print("SCROLLING TO ${this.key}");
          if(_choicekey.currentState?.context != null) {
            Scrollable.ensureVisible(_choicekey.currentState!.context);
          }
          return "Required";
        }
        if(this.value == null) {
          return null;
        }
        int idx = this.choices.indexWhere((e) {
          //print("VALIDATOR: ${e.key} == ${this.value}");
          return e.key == this.value;
        });
        //print("VALIDATOR: ${idx}");
        if(idx == -1) {
          return "Invalid Selection";
        }
      },
    );
  }
}

class SelectField extends ChoiceField {
  SelectField.fromJSON(Map j) : super.fromJSON(j);

  @override Widget getWidget(State state, BuildContext context) {
    return DropdownButtonFormField<String>(
          key : _choicekey,
          decoration: InputDecoration(
            labelText: label,
          ),
          value: value,
          items: choices.map<DropdownMenuItem<String>>((s) {
            return DropdownMenuItem<String>(
                value: s.key, child: Text("${s.label}${s.amt != null && s.amt!.amt > 0 ? " (Add ${s.amt!.display()})" : ""}"));
          }).toList(),
          validator: (value) {
            if(value == "") {
              value = null;
            }
            if(this.required && value == null) {
              print("SCROLLING TO ${this.key}");
              if(_choicekey.currentState?.context != null) {
                Scrollable.ensureVisible(_choicekey.currentState!.context);
              }
              return "Required";
            }
            if(this.value == null) {
              return null;
            }
            int idx = this.choices.indexWhere((e) {
              //print("VALIDATOR: ${e.key} == ${this.value}");
              return e.key == this.value;
            });
            //print("VALIDATOR: ${idx}");
            if(idx == -1) {
              return "Invalid Selection";
            }
          },
          onChanged: (String? value) {
            state.setState(() {
              this.value = value == "" ? null : value;
            });
            if(changeListener != null && value != null) {
              changeListener!(value);
            }
          },
        );
  }
}

class CheckboxField extends Field<bool> {
  Amount? cost;
  CheckboxField.fromJSON(Map j) {
    _fromJSON(j);
    if(j["cost"] != null) {
      cost = Amount.fromDouble(j["cost"], j["currency"]);
    }
  }

  CartItem? addToCart(CartItem? parent, MyFormController controller) {
    print("ADDTOCART: ${label} ${value}");
    if((value ?? false) && cost != null) {
      CartItem item = CartItem(
        cart_info!["type"], //type
        controller.setCartItemName?.call(this) ?? label, // name
        controller.getCartItemDescription.call(this) ?? "", //desc
        cost!, // Amount
        1, //qty,
        data: { "value": value, "key": key },
        parent: parent,
        thumb: cart_info!["thumb"],
        shippingRequired: cart_info!["shippingRequired"],
        onComplete: null,
        deletable: false,
      );
      Cart.addItem(item);
      return item;
    }
    return null;
  }


  @override Widget getWidget(State state, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget> [
        Checkbox(
            value: value ?? false,
            onChanged: (value) {
              state.setState(() {
                this.value = value;
              });
            }
        ),
        Expanded(child: Text("${label}${cost != null ? ' (Add ${cost})' : ''}")),
      ],
    );
  }

}

class UnknownField<T> extends Field<T> {
  UnknownField.fromJSON(Map j) {
    _fromJSON(j);
  }

  @override Widget getWidget(State state, BuildContext context) {
    return Text("UNKNOWN: widget=${widget} label=${label} key=${key}");
  }
}



class RadioFormField extends FormField<String> {
  RadioField radioField;

  RadioFormField({
    required this.radioField,
    Key? key,
    FormFieldSetter<String>? onSaved,
    required FormFieldValidator<String> validator,
    ValueChanged<String>? onChanged,
//    AutovalidateMode autovalidateMode,
  }) : super(
    key: key,
    onSaved: onSaved,
    validator: validator,
    enabled: true,
//    autovalidateMode: autovalidateMode ?? AutovalidateMode.always,
    builder: (FormFieldState<String> field) {
      final _RadioFormFieldState state = field as _RadioFormFieldState;
      final RadioFormField widget = state.widget as RadioFormField;
      //final InputDecoration effectiveDecoration = (decoration ?? const InputDecoration())
      //    .applyDefaults(Theme.of(field.context).inputDecorationTheme);
      void onChangedHandler(String value) {
        field.didChange(state.value);
        if (onChanged != null) {
          onChanged(value);
        }
        state.setState(() {
        });
      }

      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget> [
            Container(height: 20),
            Text(widget.radioField.label, textAlign: TextAlign.left),
            state.hasError ? Text("${state.errorText}", style: TextStyle(color: Colors.red)) : Container(height: 0),
          ] +
              widget.radioField.choices.map<Widget>((c) {
                return RadioListTile(
                  value: c.key,
                  title: Text("${c.label}${!c.disabled && c.amt != null && c.amt!.amt > 0 ? ' - ' + c.amt!.display() : ""}"),//Text("${e[2]} - ${e[1]}${e[3] ? " (SOLD OUT)" : ""}"),
                  groupValue: widget.radioField.value,
                  onChanged: c.disabled ? null : (value) {
                    state.setState(() {
                      widget.radioField.value = value;
                    });
                  },
                );
              }).toList()
      );
    },
  );

  @override _RadioFormFieldState createState() => _RadioFormFieldState();
}

class _RadioFormFieldState extends FormFieldState<String> {
}


Function(Field, List, State, BuildContext)? formAddition;

class MyForm extends StatefulWidget {
  MyFormController controller;
  Map? pre;
  Map? post;
  MyForm({required this.controller, this.pre, this.post});

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for(int idx=0; idx < widget.controller.fields.length; idx++) {
      Field field = widget.controller.fields[idx];
      if(widget.pre != null && widget.pre![field.key] != null) {
        widget.pre![field.key](field, children, this, context);
      }
      children.add(field.getWidget(this, context));
      if(widget.post != null && widget.post![field.key] != null) {
        widget.post![field.key](field, children, this, context);
      }
    }
    return AutofillGroup(
        child: Form(
          key: widget.controller.key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children
          ),
        ));
  }
}

