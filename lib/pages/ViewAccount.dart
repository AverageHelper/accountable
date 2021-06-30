import 'package:accountable/data/moneyAccounts.dart';
import 'package:accountable/data/transactionRecords.dart';
import 'package:accountable/extensions/StandardColor.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/model/TransactionRecord.dart';
import 'package:accountable/pages/CreateTransaction.dart';
import 'package:flutter/material.dart';

/// A page that displays an account's data
class ViewAccountPage extends StatefulWidget {
  ViewAccountPage(this.accountId, {Key? key}) : super(key: key);

  final String accountId;

  @override
  _ViewAccountPageState createState() => _ViewAccountPageState();
}

class _ViewAccountPageState extends State<ViewAccountPage> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();
  MoneyAccount? account;
  VoidCallback? unsubscribeAccount;
  List<TransactionRecord>? loadedTransactions;
  VoidCallback? unsubscribeTransactions;

  @override
  initState() {
    super.initState();
    refreshList();
  }

  @override
  dispose() {
    this.stopListening();
    super.dispose();
  }

  void stopListening() {
    if (unsubscribeAccount != null) {
      unsubscribeAccount!();
      unsubscribeAccount = null;
    }
    if (unsubscribeTransactions != null) {
      unsubscribeTransactions!();
      unsubscribeTransactions = null;
    }
  }

  Future<Null> refreshList() async {
    setState(() {
      this.loadedTransactions = null;
      this.account = null;
    });

    this.stopListening();
    unsubscribeAccount = watchMoneyAccountWithId(
      this.widget.accountId,
      (MoneyAccount? account) {
        setState(() {
          this.account = account;
        });
      },
    );
    unsubscribeTransactions = watchTransactionsForAccountWithId(
      this.widget.accountId,
      (transactions) {
        List<TransactionRecord> sorted = transactions.values.toList();
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        setState(() {
          this.loadedTransactions = sorted;
        });
      },
    );
  }

  Future<dynamic> displayDialog(BuildContext context) async {
    if (this.account == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            new CreateTransactionPage(this.account!, createTransactionRecord),
      ),
    );
  }

  void displayTransactionDetails(String transactionId) {
    // TODO: Navigate to this transaction's page
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => new ViewTransactionPage(transactionId),
    //   ),
    // );
  }

  Widget transactionListItem(TransactionRecord transaction) {
    return ListTile(
      title: Text(transaction.title),
      subtitle: transaction.notes != null ? Text(transaction.notes!) : null,
      leading: Icon(
        Icons.circle,
        // color: account.color.primaryColor,
      ),
      trailing: Text(
        transaction.amountEarned.toString(),
        style: transaction.amountEarned.isPositive
            ? null // default
            : new TextStyle(color: Colors.red),
      ),
      onTap: () => displayTransactionDetails(transaction.id),
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
            child: const Text("Loading Account..."),
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.attach_money,
            size: 100,
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: const Text("Press + to create a transaction"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
        primarySwatch: this.account?.color.materialColor ?? Colors.green,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(this.account?.title ?? "Loading Account..."),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {}, // TODO: Display a details editor
            ),
          ],
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: refreshList,
          child: this.account == null || this.loadedTransactions == null
              ? loadingState()
              : this.loadedTransactions?.isEmpty == true
                  ? emptyState()
                  : ListView.builder(
                      itemCount: this.loadedTransactions!.length,
                      itemBuilder: (_, idx) =>
                          transactionListItem(this.loadedTransactions![idx]),
                    ),
        ),
        floatingActionButton: this.loadedTransactions == null
            ? null
            : FloatingActionButton(
                onPressed: () => displayDialog(context),
                tooltip: 'Add an Account',
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
