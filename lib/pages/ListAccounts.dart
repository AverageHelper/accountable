import 'package:accountable/data/backend/auth.dart';
import 'package:accountable/data/moneyAccounts.dart';
import 'package:accountable/extensions/StandardColor.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/pages/CreateAccount.dart';
import 'package:accountable/pages/ViewAccount.dart';
import 'package:accountable/utilities/LoadingScreen.dart';
import 'package:flutter/material.dart';

class ListAccounts extends StatefulWidget {
  ListAccounts({Key? key}) : super(key: key);

  @override
  _ListAccountsPageState createState() => _ListAccountsPageState();
}

class _ListAccountsPageState extends State<ListAccounts> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();
  Set<MoneyAccount> selectedAccounts = new Set();
  List<MoneyAccount>? loadedAccounts;
  VoidCallback? unsubscribeAccounts;

  bool get isEditing {
    return this.selectedAccounts.isNotEmpty;
  }

  @override
  initState() {
    super.initState();
    this.refreshList();
  }

  @override
  dispose() {
    this.stopListening();
    super.dispose();
  }

  selectAccount(final MoneyAccount account) {
    setState(() {
      selectedAccounts.add(account);
    });
  }

  deselectAccount(final MoneyAccount account) {
    setState(() {
      selectedAccounts.remove(account);
    });
  }

  toggleAccountSelection(final MoneyAccount account) {
    if (selectedAccounts.contains(account)) {
      deselectAccount(account);
    } else {
      selectAccount(account);
    }
  }

  void stopListening() {
    if (unsubscribeAccounts != null) {
      unsubscribeAccounts!();
      unsubscribeAccounts = null;
    }
  }

  Future<void> refreshList() async {
    setState(() {
      this.loadedAccounts = null;
    });

    this.stopListening();
    unsubscribeAccounts = await watchMoneyAccountsForUser((accounts) {
      List<MoneyAccount> sorted = accounts.values.toList();
      sorted.sort((a, b) => a.title.compareTo(b.title));
      setState(() {
        this.loadedAccounts = sorted;
      });
    });
  }

  void presentDeletionDialog() {
    if (selectedAccounts.isEmpty) return;

    final String title = selectedAccounts.length == 1
        ? "Delete '${selectedAccounts.first.title}'?"
        : "Delete ${selectedAccounts.length} accounts?";
    final String message = "All associated transactions will also be deleted.";

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () async {
                    await Future.forEach(selectedAccounts, deleteMoneyAccount);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<void> onFinishedCreatingAccount({
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
      displayAccountDetails(newAccount);
    }
  }

  Future<dynamic> displayDialog(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => new CreateAccountPage(onFinishedCreatingAccount),
      ),
    );
  }

  void displayAccountDetails(MoneyAccount account) {
    // Navigate to this account's page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => new ViewAccount(account),
      ),
    );
  }

  Widget accountListItem(MoneyAccount account) {
    return new ListTile(
      title: Text(account.title),
      subtitle: account.notes != null ? Text(account.notes!) : null,
      leading: Icon(
        Icons.circle,
        color: account.color.primaryColor,
      ),
      selected: selectedAccounts.contains(account),
      selectedTileColor: Colors.grey.withOpacity(0.3),
      onTap: () {
        if (isEditing) {
          toggleAccountSelection(account);
        } else {
          displayAccountDetails(account);
        }
      },
      onLongPress: () {
        if (isEditing) {
          toggleAccountSelection(account);
        } else {
          selectAccount(account);
        }
      },
    );
  }

  Widget loadingState() {
    return LoadingScreen("Loading Accounts...");
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance,
            size: 100,
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: const Text("Press + to create an account"),
          ),
        ],
      ),
    );
  }

  Widget drawer(BuildContext context) {
    return new Drawer(
      child: ListView(
        children: const <Widget>[
          DrawerHeader(
            child: const Text("Accountable"),
          ),
          ListTile(
            title: const Text("Log Out"),
            onTap: logOut,
          ),
        ],
      ),
    );
  }

  List<Widget> appBarActions() {
    if (!isEditing) {
      return <Widget>[];
    }
    return <Widget>[
      IconButton(
        onPressed: presentDeletionDialog,
        icon: Icon(Icons.delete),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
        actions: appBarActions(),
      ),
      drawer: !isEditing ? drawer(context) : null,
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: this.loadedAccounts == null
            ? loadingState()
            : this.loadedAccounts!.isEmpty == true
                ? emptyState()
                : ListView.builder(
                    itemCount: this.loadedAccounts!.length,
                    itemBuilder: (_, idx) =>
                        accountListItem(this.loadedAccounts![idx]),
                  ),
      ),
      floatingActionButton: this.loadedAccounts == null
          ? null
          : FloatingActionButton(
              onPressed: () => displayDialog(context),
              tooltip: 'Add an Account',
              child: const Icon(Icons.attach_money),
            ),
    );
  }
}
