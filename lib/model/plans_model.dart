class PlansModel {
  late List<Data> data;

  PlansModel({required this.data});

  PlansModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String product = "";
  String name = "";
  int intervalCount = 0;
  String interval = "";
  String id = "";
  String currency = "";
  int created = 0;
  String amountDecimal = "";
  int amount = 0;
  bool active = false;

  Data(
      {required this.product,
        required this.name,
        required this.intervalCount,
        required this.interval,
        required this.id,
        required this.currency,
        required this.created,
        required this.amountDecimal,
        required this.amount,
        required this.active});

  Data.fromJson(Map<String, dynamic> json) {
    product = json['product'];
    name = json['name'];
    intervalCount = json['interval_count'];
    interval = json['interval'];
    id = json['id'];
    currency = json['currency'];
    created = json['created'];
    amountDecimal = json['amount_decimal'];
    amount = json['amount'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product'] = this.product;
    data['name'] = this.name;
    data['interval_count'] = this.intervalCount;
    data['interval'] = this.interval;
    data['id'] = this.id;
    data['currency'] = this.currency;
    data['created'] = this.created;
    data['amount_decimal'] = this.amountDecimal;
    data['amount'] = this.amount;
    data['active'] = this.active;
    return data;
  }
}