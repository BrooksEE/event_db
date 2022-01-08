class Amount {
  late int amt;
  String? currency;
  Amount(this.amt, this.currency) {
    if(amt == null) {
      amt = 0;
    }
  }
  static Amount create(dynamic x, String defaultCurrency) {
    if(x is double) {
      return Amount.fromDouble(x, defaultCurrency);
    } else {
      return Amount.fromJson(x);
    }
    return Amount(0,"USD");
  }
  Amount.fromJson(Map<String, dynamic> json) {
    currency = json['currency'] ?? "USD";
    amt = json['amt'] ?? 0;
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
    return { "amt": amt, "currency": currency ?? "USD"};
  }

  String display({int qty: 1, bool bare: false}) {
    int amt_ = amt * qty;
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
  TrainingProfile? profile;
  
  String toString() {
    return "${id}: ${email}";
  }
}

