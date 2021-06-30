import 'package:accountable/data/moneyAccounts.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/pages/CreateAccount.dart';
import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/pages/ViewAccount.dart';
import 'package:flutter/material.dart';

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
    this.stopListening();
  }

  void stopListening() {
    if (unsubscribeAccounts != null) {
      unsubscribeAccounts!();
      unsubscribeAccounts = null;
    }
  }

  Future<Null> refreshList() async {
    setState(() {
      this.loadedAccounts = null;
    });

    this.stopListening();
    unsubscribeAccounts = watchMoneyAccountsForUser((accounts) {
      List<MoneyAccount> sorted = accounts.values.toList();
      sorted.sort((a, b) => a.title.compareTo(b.title));
      setState(() {
        this.loadedAccounts = sorted;
      });
    });
  }

  Future<Null> onFinishedCreatingAccount({
    required String title,
    required String notes,
    required StandardColor color,
    required bool shouldCloseAccountsWhenFinished,
  }) async {
    MoneyAccount newAccount = await createMoneyAccount(
      title: title,
      notes: notes,
      color: color,
    );

    if (shouldCloseAccountsWhenFinished) {
      displayAccountDetails(newAccount.id);
    }
  }

  Future<dynamic> displayDialog(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => new CreateAccountPage(onFinishedCreatingAccount),
      ),
    );
  }

  void displayAccountDetails(String accountId) {
    // Navigate to this account's page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => new ViewAccountPage(accountId),
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
      onTap: () => displayAccountDetails(account.id),
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
