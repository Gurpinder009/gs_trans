class Transactions {
  int? id;
  String title;
  int amount;
  String type;
  String date;
  Transactions(
      {this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.type});

  static List<Transactions> toTransactions(
      {required List<Map<String, Object?>> data}) {
    List<Transactions> t1 = [];

    for (var e in data) {
      var tmp = Transactions(
          id: int.parse(e["id"].toString()),
          title: e["title"].toString(),
          amount: int.parse(e["amount"].toString()),
          date: e["date"].toString(),
          type: e["type"].toString());
      t1.add(tmp);
    }
    return t1;
  }

  @override
  String toString() {
    return "{id: $id, title:$title, amount:$amount, date:$date, type:$type}";
  }

  Map<String, Object> toMap() {
    return {"title": title, "amount": amount, "date": date, "type": type};
  }
}
