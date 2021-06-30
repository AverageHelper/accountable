import 'package:accountable/data/moneyAccounts.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/utilities/CreateAccountDialog.dart';
import 'package:flutter/material.dart';

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
  List<MoneyAccount>? loadedAccounts;
  VoidCallback? unsubscribeAccounts;

  @override
  initState() {
    super.initState();
    this.refreshList();
  }

  @override
  dispose() {
    super.dispose();
    if (this.unsubscribeAccounts != null) {
      this.unsubscribeAccounts!();
      this.unsubscribeAccounts = null;
    }
  }

  Future<Null> refreshList() async {
    setState(() {
      this.loadedAccounts = null;
    });

    if (unsubscribeAccounts != null) {
      unsubscribeAccounts!();
      unsubscribeAccounts = null;
    }
    unsubscribeAccounts = watchMoneyAccountsForUser((accounts) {
      List<MoneyAccount> sorted = accounts.values.toList();
      sorted.sort((a, b) => a.title.compareTo(b.title));
      setState(() {
        this.loadedAccounts = sorted;
      });
    });
  }

  Future<dynamic> displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new CreateAccountDialog(createMoneyAccount);
        });
  }

  Widget moneyListItem(MoneyAccount account) {
    return ListTile(
      title: Text(account.title),
      subtitle: account.notes != null ? Text(account.notes!) : null,
    );
  }

  Widget loadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator.adaptive(),
          Container(
            margin: EdgeInsets.all(8),
            child: Text("Loading Accounts..."),
          ),
        ],
      ),
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
        child: this.loadedAccounts == null
            ? loadingState()
            : ListView.builder(
                itemCount: this.loadedAccounts!.length,
                itemBuilder: (context, idx) =>
                    moneyListItem(this.loadedAccounts![idx]),
              ),
      ),
      floatingActionButton: this.loadedAccounts == null
          ? null
          : FloatingActionButton(
              onPressed: () => displayDialog(context),
              tooltip: 'Add an Account',
              child: Icon(Icons.add),
            ),
    );
  }
}
