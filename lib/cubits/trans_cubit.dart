import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gs_trans/models/db.dart';
import 'package:gs_trans/models/transactions.dart';

class TransCubit extends Cubit<List<Transactions>> {
  TransCubit() : super([]) {
    load();
  }

  Future<void> load() async {
    emit((await DatabaseConnection.getTrans()));
  }

  void add({required Transactions data}) async {
    var trans = [...state];
    data.id = await DatabaseConnection.insertTrans(data);
    trans.add(data);
    emit(trans);
  }

  void remove({required id}) {
    DatabaseConnection.deleteTrans(id);
    load();
  }

  int calculate() {
    var s = 0;
    for (var ele in state) {
      if (ele.type == "CREDIT") {
        s += ele.amount;
      } else {
        s -= ele.amount;
      }
    }

    return s;
  }
}
