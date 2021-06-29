import 'package:flutter/material.dart';
import './utilities/CreateAccountDialog.dart';
import './model/MoneyAccount.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'accountable',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: AccountsList(),
    );
  }
}

class AccountsList extends StatefulWidget {
  AccountsList({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _AccountsListPageState createState() => _AccountsListPageState();
}

class _AccountsListPageState extends State<AccountsList> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();
  List<MoneyAccount> loadedAccounts = [];

  Future<Null> refreshList() async {
    setState(() {
      loadedAccounts.clear();
    });
  }

  void createAccount({
    required String title,
    required String notes,
  }) {
    setState(() {
      MoneyAccount acct = new MoneyAccount(null);
      acct.title = title;
      acct.notes = notes;

      this.loadedAccounts.add(acct);
    });
  }

  Future<dynamic> displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new CreateAccountDialog(this.createAccount);
        });
  }

  Widget moneyListItem(MoneyAccount account) {
    return ListTile(
      title: Text(account.title),
      subtitle: account.notes.isNotEmpty ? Text(account.notes) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accounts"),
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: ListView.builder(
          itemBuilder: (context, idx) =>
              moneyListItem(this.loadedAccounts[idx]),
          itemCount: this.loadedAccounts.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => displayDialog(context),
        tooltip: 'Add an Account',
        child: Icon(Icons.add),
      ),
    );
  }
}
