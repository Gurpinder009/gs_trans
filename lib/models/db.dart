import "package:gs_trans/models/transactions.dart";
import "package:sqflite/sqflite.dart";

class DatabaseConnection {
  static Database? conn;
  static Future<Database?> getInstance() async {
    conn = await openDatabase(
      "my_db2.db",
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            "Create table trans(id Integer primary key autoincrement,title TEXT, date TEXT,amount Integer, type Text);");

        // var values = [
        //   {
        //     "title": "demo payment 1",
        //     "date": DateTime.now().toString(),
        //     "amount": 12000,
        //     "type": "CREDIT"
        //   },
        //   {
        //     "title": "demo payment 2",
        //     "date": DateTime.now().toString(),
        //     "amount": 12000,
        //     "type": "CREDIT"
        //   },
        //   {
        //     "title": "demo payment 3",
        //     "date": DateTime.now().toString(),
        //     "amount": 12000,
        //     "type": "CREDIT"
        //   },
        //   {
        //     "title": "demo payment 4",
        //     "date": DateTime.now().toString(),
        //     "amount": 12000,
        //     "type": "CREDIT"
        //   }
        // ];

        // await db.insert("trans", values[0]);
        // await db.insert("trans", values[1]);
        // await db.insert("trans", values[2]);
        // await db.insert("trans", values[3]);
      },
    );
    return conn;
  }

  static Future<List<Transactions>> getTrans() async {
    var conn = await getInstance();
    var data = await conn!
        .query("trans", columns: ["id", "title", "date", "amount", "type"]);
    var trans = Transactions.toTransactions(data: data);

    return trans;
  }

  static Future<int> insertTrans(Transactions data) async {
    var conn = await getInstance();
    var mappedData = data.toMap();
    return await conn!.insert("trans", mappedData);
  }

  static Future<int> deleteTrans(int id) async {
    var conn = await getInstance();
    return await conn!.delete("trans", where: "id = ?", whereArgs: [id]);
  }
}
