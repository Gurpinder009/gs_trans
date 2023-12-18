import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:go_router/go_router.dart";
import 'package:gs_trans/cubits/theme_mode_cubit.dart';
import 'package:gs_trans/cubits/trans_cubit.dart';
import 'package:gs_trans/models/transactions.dart';

void main() {
  runApp(const ProviderWidget(child: MyApp()));
}

class ProviderWidget extends StatelessWidget {
  final Widget child;
  const ProviderWidget({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<TransCubit>(create: (context) => TransCubit()),
      BlocProvider<ThemeModeCubit>(create: (context) => ThemeModeCubit())
    ], child: child);
  }
}

final GoRouter _router = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) {
      return const MyHomePage();
    },
  ),
  GoRoute(
      path: "/add",
      builder: (context, state) {
        return const PageLayout(child: AddWidget());
      })
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeModeCubit, bool>(builder: (context, state) {
      return MaterialApp.router(
        themeMode: (state) ? ThemeMode.light : ThemeMode.dark,
        darkTheme: ThemeData(
            useMaterial3: true,
            cardColor: const Color.fromARGB(60, 40, 40, 40),
            textTheme: const TextTheme(
                titleLarge: TextStyle(color: Colors.white70),
                titleMedium: TextStyle(color: Colors.white70),
                labelLarge: TextStyle(color: Colors.white70),
                labelMedium: TextStyle(color: Colors.white70)),
            appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(129, 75, 75, 75),
                elevation: 10,
                foregroundColor: Colors.white70),
            scaffoldBackgroundColor: const Color.fromARGB(1, 18, 18, 18),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedItemColor: Colors.white70,
                backgroundColor: Color.fromARGB(129, 70, 70, 70),
                elevation: 8),
            primaryColor: Colors.indigo[200],
            secondaryHeaderColor: Colors.green[200]),
        theme: ThemeData(
            secondaryHeaderColor: Colors.green[600],
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white, elevation: 20),
            primaryColor: Colors.indigo,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.indigo, foregroundColor: Colors.white)),
        routerConfig: _router,
      );
    });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GS Trans"),
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
              onPressed: () {
                BlocProvider.of<ThemeModeCubit>(context).toggle();
              },
              icon: BlocProvider.of<ThemeModeCubit>(context).state
                  ? const Icon(Icons.sunny)
                  : const Icon(Icons.dark_mode)),
          IconButton(
              onPressed: () {
                GoRouter.of(context).push("/add");
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: const SafeArea(
        child: DataListWidget(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 70,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            "Account Balance",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          BlocBuilder<TransCubit, List<Transactions>>(
            builder: (context, state) => Text(
              BlocProvider.of<TransCubit>(context).calculate().toString(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          )
        ]),
      ),
    );
  }
}

class DataListWidget extends StatelessWidget {
  const DataListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: BlocBuilder<TransCubit, List<Transactions>>(
          builder: (context, state) {
            return ListView.builder(
                physics: const BouncingScrollPhysics(),
                reverse: true,
                itemCount: state.length,
                itemBuilder: (context, index) => Column(
                      children: [
                        TileWidget(
                            id: state[index].id!,
                            title: state[index].title,
                            amount: state[index].amount,
                            date: state[index].date,
                            type: state[index].type),
                        const Padding(padding: EdgeInsets.all(8)),
                      ],
                    ));
          },
        ));
  }
}

class TileWidget extends StatelessWidget {
  final String title;
  final int id;
  final int amount;
  final String date;
  final String type;
  const TileWidget(
      {super.key,
      required this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(width: 1, color: Colors.black54)),
      child: Dismissible(
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete_forever),
            ),
          ),
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          onDismissed: ((direction) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete Alert"),
                    content: const Text('You really want to delete your data'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          BlocProvider.of<TransCubit>(context).load();
                          GoRouter.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          BlocProvider.of<TransCubit>(context).remove(id: id);
                          GoRouter.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          }),
          child: SizedBox(
            height: 70,
            child: Row(
              children: [
                Container(
                    width: 15,
                    decoration: BoxDecoration(
                        color: (type == "DEBIT")
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).secondaryHeaderColor)),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title,
                              style: Theme.of(context).textTheme.titleMedium),
                          const Padding(padding: EdgeInsets.only(bottom: 3)),
                          Text(
                            date.toString(),
                            style: Theme.of(context).textTheme.labelMedium,
                          )
                        ],
                      )),
                ),
                Text(
                  amount.toString(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Padding(padding: EdgeInsets.only(right: 10))
              ],
            ),
          )),
    );
  }
}

class PageLayout extends StatelessWidget {
  final Widget child;
  const PageLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: SafeArea(child: Scaffold(body: child)),
    );
  }
}

class AddWidget extends StatefulWidget {
  const AddWidget({super.key});
  @override
  State<AddWidget> createState() => AddWidgetState();
}

class AddWidgetState extends State<AddWidget> {
  final globalKey = GlobalKey<FormState>();
  String? title;
  int? amount;
  String? type;
  var data = "CREDIT";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Form(
        key: globalKey,
        child: ListView(
          children: [
            Text("Add new trans",
                style: Theme.of(context).textTheme.headlineLarge),
            const Padding(padding: EdgeInsets.only(bottom: 30)),
            TextFormField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              onSaved: (value) {
                title = value;
              },
              decoration: const InputDecoration(
                  labelText: "Title", border: OutlineInputBorder()),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            TextFormField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onSaved: (value) {
                if (value != "") {
                  amount = int.parse(value!);
                }
              },
              decoration: const InputDecoration(
                  labelText: "Amount", border: OutlineInputBorder()),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            Container(
                height: 65,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black54),
                    borderRadius: BorderRadius.circular(2)),
                child: Center(
                  child: DropdownButton(
                      value: data,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                            value: "CREDIT", child: Text("CREDIT")),
                        DropdownMenuItem(value: "DEBIT", child: Text("DEBIT")),
                      ],
                      onChanged: (newValue) {
                        setState(() {
                          data = newValue!;
                        });
                      }),
                )),
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            SizedBox(
                height: 55,
                child: ElevatedButton(
                    onPressed: () {
                      globalKey.currentState!.save();
                      var data1 = Transactions(
                          title: title!,
                          amount: amount!,
                          date: DateTime.now().toString(),
                          type: data);
                      BlocProvider.of<TransCubit>(context).add(data: data1);

                      GoRouter.of(context).pop("/");
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const ContinuousRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white),
                    child: const Text("Submit"))),
          ],
        ),
      ),
    );
  }
}
