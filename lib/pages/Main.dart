import 'package:accountable/pages/Login.dart';
import 'package:flutter/material.dart';

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.value(null),
        builder: (BuildContext _, AsyncSnapshot<Null> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(16),
                child: Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // Loaded!
          if (snapshot.connectionState == ConnectionState.done) {
            return Login();
          }

          // Still loading...
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Initializing Firebase..."),
              ],
            ),
          );
        },
      ),
    );
  }
}
