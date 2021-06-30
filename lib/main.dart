import 'package:accountable/data/moneyAccounts.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/pages/CreateAccount.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accountable',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: AccountsList(),
    );
  }
}

class AccountsList extends StatefulWidget {
  AccountsList({Key? key}) : super(key: key);

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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => new CreateAccountPage(createMoneyAccount),
      ),
    );
  }

  Widget moneyListItem(MoneyAccount account) {
    return ListTile(
      title: Text(account.title),
      subtitle: account.notes != null ? Text(account.notes!) : null,
      leading: Icon(
        Icons.circle,
        color: account.color.primaryColor,
      ),
    );
  }

  Widget loadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator.adaptive(),
          Container(
            margin: const EdgeInsets.all(8),
            child: const Text("Loading Accounts..."),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
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
              child: const Icon(Icons.add),
            ),
    );
  }
}
