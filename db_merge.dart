class Amount {
  late int amt;
  String? currency;
  Amount(this.amt, this.currency);
  Amount.create(dynamic x, String defaultCurrency) {
    try{
      Amount.fromDouble(x, defaultCurrency);
    } catch(e) {
      Amount.fromJson(x);
    }
  }
  Amount.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    amt = json['amt'];
  }
  Amount.fromDouble(double x, String currency) {
    this.currency = currency;
    if(x == null) {
      amt = 0;
    } else if(currency == 'USD') {
      amt = (x*100).round();
    } else {
      amt = x.toInt();
    }
  }

  Map<String, dynamic> toJson() {
    return { "amt": amt, "currency": currency };
  }

  String display({int qty: 1, bool bare: false}) {
    int amt_ = (amt ?? 0) * qty;
    if('USD' == this.currency) {
      double x = amt_/100.0;
      if(bare) {
        return "${NumberFormat("####0.00", "en_US").format(x)}";
      } else {
        return "\$${NumberFormat("#,##0.00", "en_US").format(x)}";
      }
    } else {
      return "${amt_}";
    }
  }

  String toString() {
    return display();
  }
}


class Participant{
  int? tagt;
  String get name => "${firstname} ${lastname}";

}

class Race {
  bool get isOYO => status == STATUS_OYO;
  String get getName => "${series?.name}${name.isEmpty ? '' : ' ' + name}";
}
class RaceEvent {
  DateTime? get getDate => date == null ? race?.date : date;
}

class MyUser {
  bool isHostStaff = false;
  String get name => "$first_name $last_name";
  
  String toString() {
    return "${id}: ${email}";
  }
}
