import 'package:accountable/data/moneyAccounts.dart';
import 'package:accountable/model/MoneyAccount.dart';
import 'package:accountable/model/StandardColor.dart';
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

  @override
  initState() {
    super.initState();
    refreshList();
  }

  @override
  dispose() {
    super.dispose();
    this.stopListening();
  }

  void stopListening() {
    if (unsubscribeAccount != null) {
      unsubscribeAccount!();
      unsubscribeAccount = null;
    }
  }

  Future<Null> refreshList() async {
    setState(() {
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
          child: this.account == null
              ? loadingState()
              : ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, idx) => ListTile(
                    title: Text("foo"),
                  ),
                ),
        ),
      ),
    );
  }
}
