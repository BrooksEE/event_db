library db;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'RPC.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter/widgets.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/google_pay_constants.dart' as google_pay_constants;
import 'dart:math';
import 'dart:io' show Platform;
import 'dialogs.dart' as dlg;
import 'package:db/db.dart';

final List<String> states = ["__","AB","AK","AL","AR","AZ","BC","CA","CO","CT","DC","DE","FL","GA","HI","IA","ID","IL","IN","KS","KY","LA","MA","MB","MD","ME","MI","MN","MO","MS","MT","NB","NC","ND","NE","NH","NJ","NL","NM","NS","NT","NU","NV","NY","OH","OK","ON","OR","PA","PE","QC","RI","SC","SD","SK","TN","TX","UT","VT","VA","WA","WI","WV","WY","YT",];
final List country_choices = [
  ["AF", "Afghanistan"],
  ["AX", "Aland Islands"],
  ["AL", "Albania"],
  ["DZ", "Algeria"],
  ["AS", "American Samoa"],
  ["AD", "Andorra"],
  ["AO", "Angola"],
  ["AI", "Anguilla"],
  ["AQ", "Antarctica"],
  ["AG", "Antigua And Barbuda"],
  ["AR", "Argentina"],
  ["AM", "Armenia"],
  ["AW", "Aruba"],
  ["AU", "Australia"],
  ["AT", "Austria"],
  ["AZ", "Azerbaijan"],
  ["BS", "Bahamas"],
  ["BH", "Bahrain"],
  ["BD", "Bangladesh"],
  ["BB", "Barbados"],
  ["BY", "Belarus"],
  ["BE", "Belgium"],
  ["BZ", "Belize"],
  ["BJ", "Benin"],
  ["BM", "Bermuda"],
  ["BT", "Bhutan"],
  ["BO", "Bolivia"],
  ["BA", "Bosnia And Herzegovina"],
  ["BW", "Botswana"],
  ["BV", "Bouvet Island"],
  ["BR", "Brazil"],
  ["IO", "British Indian Ocean Territory"],
  ["BN", "Brunei Darussalam"],
  ["BG", "Bulgaria"],
  ["BF", "Burkina Faso"],
  ["BI", "Burundi"],
  ["KH", "Cambodia"],
  ["CM", "Cameroon"],
  ["CA", "Canada"],
  ["CV", "Cape Verde"],
  ["KY", "Cayman Islands"],
  ["CF", "Central African Republic"],
  ["TD", "Chad"],
  ["CL", "Chile"],
  ["CN", "China"],
  ["CX", "Christmas Island"],
  ["CC", "Cocos [Keeling], Islands"],
  ["CO", "Colombia"],
  ["KM", "Comoros"],
  ["CG", "Congo"],
  ["CD", "Congo, Democratic Republic"],
  ["CK", "Cook Islands"],
  ["CR", "Costa Rica"],
  ["CI", "Cote D'ivoire"],
  ["HR", "Croatia"],
  ["CU", "Cuba"],
  ["CY", "Cyprus"],
  ["CZ", "Czech Republic"],
  ["DK", "Denmark"],
  ["DJ", "Djibouti"],
  ["DM", "Dominica"],
  ["DO", "Dominican Republic"],
  ["EC", "Ecuador"],
  ["EG", "Egypt"],
  ["SV", "El Salvador"],
  ["GQ", "Equatorial Guinea"],
  ["ER", "Eritrea"],
  ["EE", "Estonia"],
  ["ET", "Ethiopia"],
  ["FK", "Falkland Islands [Malvinas]"],
  ["FO", "Faroe Islands"],
  ["FJ", "Fiji"],
  ["FI", "Finland"],
  ["FR", "France"],
  ["GF", "French Guiana"],
  ["PF", "French Polynesia"],
  ["TF", "French Southern Territories"],
  ["GA", "Gabon"],
  ["GM", "Gambia"],
  ["GE", "Georgia"],
  ["DE", "Germany"],
  ["GH", "Ghana"],
  ["GI", "Gibraltar"],
  ["GR", "Greece"],
  ["GL", "Greenland"],
  ["GD", "Grenada"],
  ["GP", "Guadeloupe"],
  ["GU", "Guam"],
  ["GT", "Guatemala"],
  ["GG", "Guernsey"],
  ["GN", "Guinea"],
  ["GW", "Guinea-Bissau"],
  ["GY", "Guyana"],
  ["HT", "Haiti"],
  ["HM", "Heard Island And Mcdonald Islands"],
  ["VA", "Holy See [Vatican City State]"],
  ["HN", "Honduras"],
  ["HK", "Hong Kong"],
  ["HU", "Hungary"],
  ["IS", "Iceland"],
  ["IN", "India"],
  ["ID", "Indonesia"],
  ["IR", "Iran, Islamic Republic Of"],
  ["IQ", "Iraq"],
  ["IE", "Ireland"],
  ["IM", "Isle Of Man"],
  ["IL", "Israel"],
  ["IT", "Italy"],
  ["JM", "Jamaica"],
  ["JP", "Japan"],
  ["JE", "Jersey"],
  ["JO", "Jordan"],
  ["KZ", "Kazakhstan"],
  ["KE", "Kenya"],
  ["KI", "Kiribati"],
  ["KP", "Korea, Democratic People's Republic"],
  ["KR", "Korea, Republic Of"],
  ["KW", "Kuwait"],
  ["KG", "Kyrgyzstan"],
  ["LA", "Lao People's Democratic Republic"],
  ["LV", "Latvia"],
  ["LB", "Lebanon"],
  ["LS", "Lesotho"],
  ["LR", "Liberia"],
  ["LY", "Libyan Arab Jamahiriya"],
  ["LI", "Liechtenstein"],
  ["LT", "Lithuania"],
  ["LU", "Luxembourg"],
  ["MO", "Macao"],
  ["MK", "Macedonia, Former Yugoslav Republic"],
  ["MG", "Madagascar"],
  ["MW", "Malawi"],
  ["MY", "Malaysia"],
  ["MV", "Maldives"],
  ["ML", "Mali"],
  ["MT", "Malta"],
  ["MH", "Marshall Islands"],
  ["MQ", "Martinique"],
  ["MR", "Mauritania"],
  ["MU", "Mauritius"],
  ["YT", "Mayotte"],
  ["MX", "Mexico"],
  ["FM", "Micronesia, Federated States Of"],
  ["MD", "Moldova, Republic Of"],
  ["MC", "Monaco"],
  ["MN", "Mongolia"],
  ["MS", "Montserrat"],
  ["MA", "Morocco"],
  ["MZ", "Mozambique"],
  ["MM", "Myanmar"],
  ["NA", "Namibia"],
  ["NR", "Nauru"],
  ["NP", "Nepal"],
  ["NL", "Netherlands"],
  ["AN", "Netherlands Antilles"],
  ["NC", "New Caledonia"],
  ["NZ", "New Zealand"],
  ["NI", "Nicaragua"],
  ["NE", "Niger"],
  ["NG", "Nigeria"],
  ["NU", "Niue"],
  ["NF", "Norfolk Island"],
  ["MP", "Northern Mariana Islands"],
  ["NO", "Norway"],
  ["OM", "Oman"],
  ["PK", "Pakistan"],
  ["PW", "Palau"],
  ["PS", "Palestinian Territory, Occupied"],
  ["PA", "Panama"],
  ["PG", "Papua New Guinea"],
  ["PY", "Paraguay"],
  ["PE", "Peru"],
  ["PH", "Philippines"],
  ["PN", "Pitcairn"],
  ["PL", "Poland"],
  ["PT", "Portugal"],
  ["PR", "Puerto Rico"],
  ["QA", "Qatar"],
  ["RE", "Reunion"],
  ["RO", "Romania"],
  ["RU", "Russian Federation"],
  ["RW", "Rwanda"],
  ["SH", "Saint Helena"],
  ["KN", "Saint Kitts And Nevis"],
  ["LC", "Saint Lucia"],
  ["PM", "Saint Pierre And Miquelon"],
  ["VC", "Saint Vincent And The Grenadines"],
  ["WS", "Samoa"],
  ["SM", "San Marino"],
  ["ST", "Sao Tome And Principe"],
  ["SA", "Saudi Arabia"],
  ["SN", "Senegal"],
  ["CS", "Serbia And Montenegro"],
  ["SC", "Seychelles"],
  ["SL", "Sierra Leone"],
  ["SG", "Singapore"],
  ["SK", "Slovakia"],
  ["SI", "Slovenia"],
  ["SB", "Solomon Islands"],
  ["SO", "Somalia"],
  ["ZA", "South Africa"],
  ["GS", "South Georgia & Sandwich Islands"],
  ["ES", "Spain"],
  ["LK", "Sri Lanka"],
  ["SD", "Sudan"],
  ["SR", "Suriname"],
  ["SJ", "Svalbard And Jan Mayen"],
  ["SZ", "Swaziland"],
  ["SE", "Sweden"],
  ["CH", "Switzerland"],
  ["SY", "Syrian Arab Republic"],
  ["TW", "Taiwan, Province Of China"],
  ["TJ", "Tajikistan"],
  ["TZ", "Tanzania, United Republic Of"],
  ["TH", "Thailand"],
  ["TL", "Timor-leste"],
  ["TG", "Togo"],
  ["TK", "Tokelau"],
  ["TO", "Tonga"],
  ["TT", "Trinidad And Tobago"],
  ["TN", "Tunisia"],
  ["TR", "Turkey"],
  ["TM", "Turkmenistan"],
  ["TC", "Turks And Caicos Islands"],
  ["TV", "Tuvalu"],
  ["UG", "Uganda"],
  ["UA", "Ukraine"],
  ["AE", "United Arab Emirates"],
  ["GB", "United Kingdom"],
  ["US", "United States"],
  ["UM", "United States Minor Outlying Islands"],
  ["UY", "Uruguay"],
  ["UZ", "Uzbekistan"],
  ["VU", "Vanuatu"],
  ["VE", "Venezuela"],
  ["VN", "Viet Nam"],
  ["VG", "Virgin Islands, British"],
  ["VI", "Virgin Islands, U.S."],
  ["WF", "Wallis And Futuna"],
  ["EH", "Western Sahara"],
  ["YE", "Yemen"],
  ["ZM", "Zambia"],
  ["ZW", "Zimbabwe"],
];

class LineItem {
    late String name;
    late String type;
    late Amount amt;
    late String info;
    late DateTime timestamp;
    Amount? taxable_amount;
    Amount? tax_amount;
    String? tax_category;
    int? race_id;
    int? trans_number;
    String? receipt;

    LineItem.fromJSON(Map<String, dynamic> j) {
      name=j['name'];
      type=j['type'];
      amt = Amount.fromDouble(j['amount'], j['currency']);
      info =j['info'];
      timestamp = DateTime.parse(j['timestamp']);
      trans_number = j['trans_number'];
    }
}

class Invoice {
  late String number;
  late String email;
  late DateTime timestamp;
  late Address shipping;
  late String notes;
  late String currency;
  late List<LineItem> items;
  late LineItem payment;
  late List<Map> instructions = [];
  late Map transaction;

  Invoice.fromJSON(Map json) {
    number = json["number"];
    email=json["email"];
    shipping = Address();
    shipping.update(json['shipping_name'], json['shipping_address'], json['shipping_city'], json['shipping_state'], json["shipping_country"], json['shipping_zip']);
    notes = json['notes'] ?? "";
    currency = json['currency'];
    items = [];
    for(int idx=0; idx<json['items'].length; idx++) {
      items.add(LineItem.fromJSON(json['items'][idx]));
    }
    payment = LineItem.fromJSON(json['payment']);
    transaction = json["transaction"];
    timestamp = DateTime.parse(json["timestamp"]);
  }
}


class CartItem {
  String type;
  String name;
  String desc;
  Amount amt;
  int qty;
  String thumb;
  Map? data;
  CartItem? parent;
  bool shippingRequired;
  bool deletable = true;
  late int id;

  Function(Invoice)? onComplete;

  CartItem(this.type, this.name, this.desc, this.amt, this.qty, {this.data: null, this.parent: null, this.thumb: "", this.shippingRequired: false, this.onComplete: null, this.deletable: true}) {
    id = Random().nextInt(0xFFFFFFFF);
  }
  Map toMap() {
    return {"id":id, "type":type, "name": name, "desc": desc, "amt": amt.amt, "currency": amt.currency, "qty": qty, "data": data, "shipping_required": shippingRequired, "parent": parent?.id };
  }

  void complete(Invoice inv) {
    if(onComplete != null) {
      onComplete?.call(inv);
    }
  }
}

class Address {
  String _name="";
  String _address="";
  String _city="";
  String _state="";
  String _country="US";
  String _zip="";
  Address();

  Map toJSON() {
    return {
      "name": this._name,
      "address": this._address,
      "city": this._city,
      "state": this._state,
      "country": this._country,
      "zip": this._zip,
    };
  }
  void update(String name, String address, String city, String state, String country, String zip) {
    this._name    = name == null ? "" : name.trim();
    this._address = address == null ? "" : address.trim();
    this._city    = city == null ? "" : city.trim();
    this._state   = state == null ? "" : state.trim();
    this._country = country == null ? "" : country.trim();
    this._zip     = zip == null ? "" : zip.trim();
  }
  String get name => _name;
  String get address => _address;
  String get city => _city;
  String get state => _state;
  String get country => _country;
  String get zip => _zip;
  void set name(String x)    { _name    = x.trim(); }
  void set address(String x) { _address = x.trim(); }
  void set city(String x)    { _city    = x.trim(); }
  void set state(String x)   { _state   = x.trim(); if(states.indexWhere((s) => s == _state) == -1) { _state=""; }  }
  void set country(String x) { _country = x.trim(); if(country_choices.indexWhere((c) => c[0] == _country) == -1) { _country="US"; }  }
  void set zip(String x)     { _zip     = x.trim(); }
  Address.fromJSON(Map<String, dynamic> j) {

    this._name = j["name"];
    this._address = j["address"];
    this._city = j["city"];
    this._state = j["state"];
    this._country = j["country"];
    this._zip = j["zip"];
  }
}
String _host_key = "???"; // TODO: set this
class Cart {
  static Address shippingAddress = Address();
  static List<CartItem> cartItems = [];
  static String invoiceNumber = genInvoiceNumber(_host_key);

  static addItem(CartItem item) {
    cartItems.add(item);
  }
  static setHostKey(String h) {
    _host_key = h.toUpperCase();
    invoiceNumber = genInvoiceNumber(_host_key);
  }

  static removeItem(CartItem item) {
    cartItems.remove(item);
    cartItems.removeWhere((c) => c.parent == item);
  }

  static bool has(String type) {
    for(int idx=0; idx<cartItems.length; idx++) {
      if(cartItems[idx].type == type) {
        return true;
      }
    }
    return false;
  }

  static void resetCart() {
    invoiceNumber = genInvoiceNumber(_host_key);
    cartItems.clear();
  }

  static Amount getTotal() {
    Amount total = Amount(0, "USD");
    for(int idx=0; idx<cartItems.length; idx++) {
      total.amt += cartItems[idx].amt.amt;
      assert(cartItems[idx].amt.currency == "USD");
    }
    if(total.amt < 0) {
      total.amt = 0;
    }
    return total;
  }

  static bool shippingRequired() {
    for(int idx=0; idx<cartItems.length; idx++) {
      if(cartItems[idx].shippingRequired) {
        return true;
      }
    }
    return false;
  }

  static String genInvoiceNumber(String host_key) {
    return "${host_key}-${Random().nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8,'0')}".toUpperCase();
  }

  static Map toMap() {
    List items = [];
    for(int idx=0; idx < cartItems.length; idx++) {
      items.add(cartItems[idx].toMap());
    }
    return {"items":items};
  }
}

class CartView extends StatefulWidget {
  CartView({Key? key, this.appleMerchId, required this.squareAppId, this.googlePayId, required this.host_key, required this.scaffoldBuilder}) : super(key: key);
  String? appleMerchId;
  String squareAppId;
  String? googlePayId;
  String host_key;
  Function scaffoldBuilder;
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<CartView> {
  bool init=false;
  Invoice? invoice = null;
  final _formKey = GlobalKey<FormState>();
  final shippingNameController = TextEditingController();
  final shippingAddressController = TextEditingController();
  final shippingCityController = TextEditingController();
  final shippingZipController = TextEditingController();
  final promocodeController = TextEditingController();
  bool _googlePayEnabled = false;
  bool _applePayEnabled = false;

  Future<void> checkPayOptions() async {
    var canUseGooglePay = false;
    var canUseApplePay = false;
    if(Platform.isAndroid && widget.googlePayId != null) {
      // initialize the google pay with square location id
      // use test environment first to quick start
      await InAppPayments.initializeGooglePay(
          widget.googlePayId!,
          google_pay_constants.environmentProduction
          //google_pay_constants.environmentTest
      );
      // always check if google pay supported on that device
      // before enable google pay
      canUseGooglePay = await InAppPayments.canUseGooglePay;
    } else if(Platform.isIOS && widget.appleMerchId != null) {//TODO: get applypay working and approved
      // initialize the apple pay with apple pay merchant id
      await InAppPayments.initializeApplePay(widget.appleMerchId!);
      // always check if apple pay supported on that device
      // before enable apple pay
      canUseApplePay = await InAppPayments.canUseApplePay;
      print("CAN USE APPLE PAY: ${canUseApplePay}");
    }
    setState(() {
      _googlePayEnabled = canUseGooglePay;
      _applePayEnabled = canUseApplePay;
    });
  }

  @override void initState() {
    super.initState();
    init = false;
    InAppPayments.setSquareApplicationId(widget.squareAppId).then((_) {
      init=true;
      checkPayOptions();
    });

    print("SHIPPING NAME: ${Cart.shippingAddress.name}");
    shippingNameController.text = Cart.shippingAddress.name;
    shippingAddressController.text = Cart.shippingAddress.address;
    shippingCityController.text = Cart.shippingAddress.city;
    shippingZipController.text = Cart.shippingAddress.zip;
  }

  @override void dispose() {
    shippingNameController.dispose();
    shippingAddressController.dispose();
    shippingCityController.dispose();
    shippingZipController.dispose();
    super.dispose();
  }

  Future<void> _onStartCardEntryFlow() async {
    await InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: _onCardEntryCardNonceRequestSuccess,
        onCardEntryCancel: _onCancelCardEntryFlow);
  }

  void _onCancelCardEntryFlow() {
    // Handle the cancel callback
  }

  Future<Invoice?> checkout(Map args) async {
    args["invoice_number"] = Cart.invoiceNumber;
    args["total"]          = Cart.getTotal().amt;
    args["currency"]       = Cart.getTotal().currency;
    args["cart_items"]     = Cart.toMap();
    args["shipping"]       = Cart.shippingAddress.toJSON();
    args["host_key"]       = widget.host_key;
    invoice = null;
    try {
      Map inv = await RPC().rpc("shop","AppStore","payment", args, "Completing Transaction");
      setState(() {
        invoice = Invoice.fromJSON(inv);
        for(int idx=0; idx<Cart.cartItems.length; idx++) {
          Cart.cartItems[idx].complete(invoice!);
        }
      });
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);
      dlg.showError(e.toString());
    }
    return invoice;
  }

  void _onCardEntryCardNonceRequestSuccess(CardDetails cardDetails) async {
    try {
      await checkout({"which":"squareweb", "nonce": cardDetails.nonce});
      if(invoice == null) {
        InAppPayments.completeCardEntry(onCardEntryComplete: showError);
      } else {
        InAppPayments.completeCardEntry(onCardEntryComplete: showReceipt);
      }
    } catch (ex) {
      // payment failed to complete due to error
      // notify card entry to show processing error
      InAppPayments.showCardNonceProcessingError(ex.toString());
    }
  }

  void showError() {
    print("showError called");
  }

  void showReceipt() {
    setState(() {
      Cart.resetCart();
    });
    // Update UI to notify user that the payment flow is finished successfully
  }

  void _onStartApplePay() async {
    String price = Cart.getTotal().display(bare:true);
    try {
      await InAppPayments.requestApplePayNonce(
          price: price,
          summaryLabel: 'Brooksee Endurance Events',
          countryCode: 'US',
          currencyCode: 'USD',
          paymentType: ApplePayPaymentType.finalPayment,
          onApplePayNonceRequestSuccess: _onApplePayNonceRequestSuccess,
          onApplePayNonceRequestFailure: _onGooglePayNonceRequestFailure,
          onApplePayComplete: showReceipt);
    } on PlatformException catch (ex) {
      print("_onStartApplePay: $ex");
      dlg.showError(ex.toString());
    }
  }
  void _onApplePayNonceRequestSuccess(CardDetails cardDetails) async {
    try {
      await checkout({"which":"squareweb", "nonce": cardDetails.nonce});
      await InAppPayments.completeApplePayAuthorization(isSuccess: invoice != null);
    } on Exception catch (ex) {
      await InAppPayments.completeApplePayAuthorization(
          isSuccess: false,
          errorMessage: ex.toString());
    }
  }
  void _onStartGooglePay() async {
    String price = Cart.getTotal().display(bare:true);
    print("PRICE: ${price}");
    try {
      await InAppPayments.requestGooglePayNonce(
          price: price,
          priceStatus: 3, // TOTAL_PRICE_STATUS_FINAL
          currencyCode: 'USD',
          onGooglePayNonceRequestSuccess: _onGooglePayNonceRequestSuccess,
          onGooglePayNonceRequestFailure: _onGooglePayNonceRequestFailure,
          onGooglePayCanceled:            _onGooglePayCancel);
    } on InAppPaymentsException catch(ex) {
      print("_onStartGooglePay $ex");
      dlg.showError(ex.toString());
    }
  }
  void _onGooglePayNonceRequestSuccess(CardDetails cardDetails) async {
    try {
      await checkout({"which":"squareweb", "nonce": cardDetails.nonce});
    } catch (ex, stacktrace) {
      print("_onGooglePayNonceRequestSuccess $ex");
      print(stacktrace);
      dlg.showError(ex.toString());
    }
  }

  /**
   * Callback when google pay is canceled
   * google pay sheet has been closed when this callback is invoked
   */
  void _onGooglePayCancel() {
    // handle google pay canceled
  }

  /**
   * Callback when failed to get the card nonce
   * google pay sheet has been closed when this callback is invoked
   */
  void _onGooglePayNonceRequestFailure(ErrorInfo errorInfo) {
    print("_onGooglePayNonceRequestFailure $errorInfo");
    dlg.showError(errorInfo.toString());
    // handle google pay failure
  }

  @override
  Widget build(BuildContext context) {
    Amount tot = Cart.getTotal();
    return widget.scaffoldBuilder(
        appBar: "Cart",
        leading: IconButton(
             icon: new Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(null),
           ),
        endDrawer: Drawer(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DrawerHeader(
                    child: Text("Shopping Cart Options"),
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text("Empty Cart"),
                    ),
                    onTap: () {
                        print("Empty Cart");
                        setState(() {
                          Cart.resetCart();
                        });
                        Navigator.pop(context);
                    },
                  ),
                  Expanded(child: Container(width: 0)),
                  ListTile(
                    leading: Icon(Icons.confirmation_number),
                    title: Text("${Cart.invoiceNumber}"),
                  ),
                ],
            ),
        ),
        body: invoice != null ? SingleChildScrollView(child:
        Column(children:
        invoice!.instructions.map<Widget>((w) {
          return Padding(padding: EdgeInsets.all(10), child: mt.Card(child: Padding(padding: EdgeInsets.all(10), child: Column(children: <Widget> [
            AutoSizeText(w["title"],
              style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor),
              maxLines: 1,
            ),
            AutoSizeText(w["msg"],
              style: TextStyle(fontSize: 20),
              maxLines: 3,
            ),
          ]))));
        }).toList()
            + [
              Container(height: 20),
          AutoSizeText(
            'Reciept',
            style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).primaryColor),
            maxLines: 1,
          ),
        ] +
            invoice!.items.map<Widget>((li) {
              return Container(
                  decoration: BoxDecoration(
                  border: Border(
                  top: BorderSide(
                  color: Theme.of(context).primaryColor,
              width: 0.5),
              bottom: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 0.5),
              )),
              child: ListTile(
                title: Text("${li.name}: ${li.info}"),
                trailing: Text("${li.amt.display()}"),
              ));
            }).toList()
            +
            [
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                top: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.5),
                                bottom: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2.0),
                              )),
                              child: ListTile(
                                title: Text('PAYMENT: ${invoice?.transaction["method"]}'),
                                trailing: Text(
                                    "${invoice!.payment.amt.display(qty: -1)}"),
                              )),
                          ListTile(
                            title: Text(
                                'Confirmation Code: ${invoice!.number}'),
                            subtitle: Text('Date: ${invoice!.timestamp}'),
                          ),
                          Container(height: 20),
                          RaisedButton(
                            child: Text("Done"),
                            onPressed: () {
                                Navigator.pop(context);
                            },
                          ),
                          Container(height: 20),
                        ])) :

        Cart.cartItems.length == 0 ? Center(child: Text("Cart is Empty")) :
        SingleChildScrollView(child:

        Form(
    key: _formKey,
    child: Column(
            children: <Widget>[
              ListView(
                  physics: NeverScrollableScrollPhysics(),
             shrinkWrap: true,
              children: Cart.cartItems.map((CartItem item) {
                      String subtitle = "${item.desc.isEmpty ? "" : "${item.desc}"}${item.qty>1 ? '\nQty: ${item.qty}' : ''}";
                      return Container(
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 0.5),
                            bottom: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 0.5),
                          )),
                          child: ListTile(
                            leading: item.thumb == null || item.thumb == ""
                                ? Container(width: 0)
                                : Image.network(item.thumb),
                            title: Text(item.name),
                            isThreeLine: !subtitle.isEmpty,
                            subtitle: Text(subtitle),
                          trailing: Row(mainAxisSize:MainAxisSize.min,
                              children: <Widget>[
                        (!item.deletable) ? Container(width:0) : IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: Text("Delete Item?"),
                                        content: Text(
                                            "Are you sure you want to delete this item from your cart?"),
                                        actions: <Widget>[
                                          TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }),
                                          TextButton(
                                              child: Text("Delete"),
                                              onPressed: () {
                                                setState(() {
                                                  Cart.removeItem(item);
                                                });
                                                Navigator.pop(context);
                                              })
                                        ]);
                                  },
                                );
                              },
                            ),
                              Text(item.amt.display(qty: item.qty)),

                              ]),
                        ));
                    }).toList(),
                  ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                        bottom: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  child: ListTile(
                    title: Text("TOTAL:", style:TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(tot.display(), style:TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(height: 20),
                Cart.shippingRequired() ?
                    mt.Card(child: Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                        children: <Widget> [
                          Padding( padding: EdgeInsets.only(top: 10), child: AutoSizeText("Shipping Information",
                            style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor, ),
                            maxLines: 1,
                          )),
                          TextFormField(
                            controller: shippingNameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                            ),
                            validator: (value) {
                              if(value?.isEmpty ?? true) {
                                return 'Enter your name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: shippingAddressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                            ),
                            validator: (value) {
                              if(value?.isEmpty ?? true) {
                                return 'Enter your address';
                              }
                              return null;
                            },
                          ),
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      //crossAxisAlignment:CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Expanded(
                                            child: TextFormField(
                                          controller: shippingCityController,
                                          decoration: InputDecoration(
                                            labelText: 'City',
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return 'Enter your city';
                                            }
                                            return null;
                                          },
                                        )),
                                        Container(width: 20),
                                        Expanded(child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'State',
                                          ),
                                          value: Cart.shippingAddress.state.isEmpty ? null : Cart.shippingAddress.state,
                                          items: states.map((s) {
                                            return DropdownMenuItem<String>(value: s, child: Text(s));
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              if(value != null) Cart.shippingAddress.state = value;
                                            });
                                          },
                                        )),
                                      ]),
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      //crossAxisAlignment:CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Expanded(
                                            child: TextFormField(
                                          controller: shippingZipController,
                                          decoration: InputDecoration(
                                            labelText: 'Zip',
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return 'Enter your zip';
                                            }
                                            return null;
                                          },
                                        )),
                                        Container(width: 20),
                                        Expanded(child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Country',
                                          ),
                                          value: Cart.shippingAddress.country.isEmpty ? null : Cart.shippingAddress.country,
                                          items: country_choices.map((s) {
                                            return DropdownMenuItem<String>(
                                                value: s[0], child: Text(s[1]));
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              if(value != null) {
                                                Cart.shippingAddress.country = value;
                                              }
                                            });
                                          },
                                        )),
                                      ]),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        //crossAxisAlignment:CrossAxisAlignment.stretch,
                        children: <Widget>[
]),
                                ],
                      ),
                    ))
                    : Container(),
                Cart.has("promocode") ? Container() : FlatButton(
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Discount Code", style: TextStyle(color:Theme.of(context).primaryColor, decoration: TextDecoration.underline)),
                      ],
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text("Discount Code"),
                            content: TextFormField(
                              controller: promocodeController,
                              decoration: InputDecoration(
                                labelText: 'Code',
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              TextButton(
                                  child: Text("Apply"),
                                  onPressed: () async {
                                    Map result;
                                    try {
                                      result = await RPC().rpc("shop","AppStore","promocode", {"code":promocodeController.text, "host_key": widget.host_key}, "Checking Code");
                                    } catch(e) {
                                      dlg.showError(e.toString());
                                      return;
                                    }
                                    if(result["type"] != 0) {
                                      dlg.showError("Cannot apply this type of discount code. Currently, you can only use flat rate codes.");
                                      return;
                                    }
                                    setState(() {
                                      Cart.addItem(CartItem(
                                        "promocode",
                                        "Discount Code",
                                        result["name"],
                                        Amount(-result["amt"], result["currency"]),
                                        1,
                                        data: {"code":result},
                                      ));
                                    });
                                    Navigator.pop(context);
                                  })
                            ]);
                      },
                    );
                  }),
                Container(height: 20),
                Row(
                    //direction: Axis.vertical,//MediaQuery.of(context).size.width > 10 ? Axis.horizontal : Axis.vertical,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget> [
                  Expanded(child: Container(width: 0)),
                  tot.amt == 0 ? RaisedButton(
                    child: Text("Checkout"),
                    onPressed: () async {
                      if(_formKey.currentState?.validate() ?? false) {
                          await checkout({"which":"free", "nonce": ""});
                          if(invoice != null) {
                            showReceipt();
                          }
                      }
                    },
                  ) :
                RaisedButton(
                  child: Text("Pay With Credit Card"),
                  onPressed: () async {
                    if(_formKey.currentState?.validate() ?? false) {
                        await _onStartCardEntryFlow();
                    }
                  },
                ),
                  Container(width: _googlePayEnabled && tot.amt > 0 ? 20 : 0),
                  _googlePayEnabled && tot.amt > 0 ? RaisedButton(
                    color: Color.fromARGB(0xFF, 0, 0, 0),
                    child: Image.asset("assets/google_pay.png", height: 20),
                    onPressed: () async {
                      if(_formKey.currentState?.validate() ?? false) {
                        _onStartGooglePay();
                      }
                    },
                  ) : Container(width: 0),
                      Container(width: _applePayEnabled && tot.amt > 0 ? 20 : 0),
                      _applePayEnabled && tot.amt > 0 ? RaisedButton(
                        color: Color.fromARGB(0xFF, 0, 0, 0),
                        child: Image.asset("assets/apple_pay.png", height: 20),
                        onPressed: () async {
                          if(_formKey.currentState?.validate() ?? false) {
                            _onStartApplePay();
                          }
                        },
                      ) : Container(width: 0),
                      Expanded(child: Container(width: 0)),
                ]),
                Container(height: 20),
              ]
      )
    )));
  }
}
