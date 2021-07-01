import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(this.label),
        ],
      ),
    );
  }
}
