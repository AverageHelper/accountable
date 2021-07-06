import 'package:accountable/data/moneyAccounts.dart';
import 'package:accountable/data/transactionRecords.dart';
import 'package:accountable/extensions/StandardColor.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/model/StandardColor.dart';
import 'package:accountable/model/TransactionRecord.dart';
import 'package:accountable/pages/CreateTransaction.dart';
import 'package:accountable/utilities/LoadingScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A page that displays an account's data
class ViewAccountPage extends StatefulWidget {
  ViewAccountPage(this.account, {Key? key}) : super(key: key);

  final MoneyAccount account;

  @override
  _ViewAccountPageState createState() => _ViewAccountPageState();
}

class _ViewAccountPageState extends State<ViewAccountPage> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();
  late String accountTitle;
  late StandardColor accountColor;
  VoidCallback? unsubscribeAccount;
  List<TransactionRecord>? loadedTransactions;
  VoidCallback? unsubscribeTransactions;

  @override
  initState() {
    super.initState();
    this.accountTitle = this.widget.account.title;
    this.accountColor = this.widget.account.color;
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

  Future<void> refreshList() async {
    setState(() {
      this.loadedTransactions = null;
    });

    this.stopListening();
    unsubscribeAccount = await watchMoneyAccountWithId(
      this.widget.account.id,
      (MoneyAccount? account) {
        debugPrint("Received account change.");
        if (account == null) {
          return;
        }
        setState(() {
          if (this.accountTitle != account.title) {
            this.accountTitle = account.title;
          }
          if (this.accountColor != account.color) {
            this.accountColor = account.color;
          }
        });
      },
    );
    unsubscribeTransactions = await watchTransactionsForAccount(
      this.widget.account,
      (transactions) {
        List<TransactionRecord> sorted = transactions.values.toList();
        debugPrint("Fetched transactions. Got ${sorted.length} of them.");
        sorted.sort((a, b) => b.createdAt.compareTo(b.createdAt));
        setState(() {
          this.loadedTransactions = sorted;
        });
      },
    );
  }

  Future<dynamic> displayDialog(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => new CreateTransactionPage(
            this.widget.account, createTransactionRecord),
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
    final DateFormat formatter = DateFormat.yMMMMd().add_jm();
    final String createdAt = formatter.format(transaction.createdAt);

    return ListTile(
      title: Text(transaction.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          transaction.notes != null
              ? Text(transaction.notes!)
              : const SizedBox.shrink(),
          Text(createdAt),
        ],
      ),
      leading: Icon(
        Icons.circle,
        // color: account.color.primaryColor,
      ),
      trailing: Text(
        transaction.amountEarned.toString(),
        style: transaction.amountEarned.isPositive
            ? null // default
            : const TextStyle(color: Colors.red),
      ),
      onTap: () => displayTransactionDetails(transaction.id),
    );
  }

  Widget loadingState() {
    return LoadingScreen("Loading Account...");
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
        primarySwatch: this.accountColor.materialColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(this.accountTitle),
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
          child: this.loadedTransactions == null
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
