import 'package:accountable/model/Keys.dart';
import 'package:accountable/pages/ObtainCredentials.dart';
import 'package:accountable/utilities/LoadingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Main extends StatelessWidget {
  final Future<Keys?> _environment = dotenv.load(fileName: ".env").then(
    (_) {
      final String? appId = dotenv.env["PARSE_APP_ID"];
      final String? clientKey = dotenv.env["PARSE_CLIENT_KEY"];
      if (appId == null || clientKey == null) return null;

      return new Keys(
        appId: appId,
        clientKey: clientKey,
      );
    },
  );

  Widget errorState(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(16),
        child: Text(
          error,
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _environment,
        builder: (_, AsyncSnapshot<Keys?> snapshot) {
          if (snapshot.hasError) {
            return errorState(snapshot.error.toString());
          }

          // Loaded!
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return errorState(
                  "Missing value(s) for environment keys 'PARSE_APP_ID' and 'PARSE_CLIENT_KEY'. Add them in .env");
            }

            return ObtainCredentials(snapshot.data!);
          }

          // Still loading...
          return LoadingScreen("Initializing backend service...");
        },
      ),
    );
  }
}
