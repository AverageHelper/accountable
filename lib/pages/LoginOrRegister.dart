import 'package:accountable/data/backend/Keys.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class LoginOrRegister extends StatefulWidget {
  LoginOrRegister(
    this.keys, {
    required this.tryLogin,
    required this.tryRegister,
    Key? key,
  }) : super(key: key);

  final Keys keys;

  final Future<void> Function({
    required Keys keys,
    required String url,
    required String username,
    required String password,
  }) tryLogin;

  final Future<void> Function({
    required Keys keys,
    required String url,
    required String email,
    required String username,
    required String password,
  }) tryRegister;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginOrRegister> {
  final String parseServerUrl = "https://parseapi.back4app.com";

  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? error;
  bool canCommitLogin = false;
  bool isCommittingLogin = false;
  bool showsAdvancedOptions = false;
  bool isRegisteringNewAccount = true;

  @override
  void initState() {
    _urlController.text = parseServerUrl;
    super.initState();
  }

  void checkCanCommitLogin(String _) {
    setState(() {
      this.error = null;
      this.canCommitLogin = _usernameController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          (!isRegisteringNewAccount || _emailController.text.trim().isNotEmpty);
    });
  }

  void toggleAdvanced() {
    setState(() {
      this.showsAdvancedOptions = !this.showsAdvancedOptions;
    });
  }

  void toggleRegistrationView() {
    setState(() {
      this._emailController.clear();
      this.isRegisteringNewAccount = !this.isRegisteringNewAccount;
    });
    checkCanCommitLogin("");
  }

  Future<void> commitForm() async {
    if (isCommittingLogin) return;

    setState(() {
      error = null;
      isCommittingLogin = true;
    });

    final String url = _urlController.text.trim().isNotEmpty
        ? _urlController.text.trim()
        : parseServerUrl;
    final String email = _emailController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    try {
      if (isRegisteringNewAccount) {
        await widget.tryRegister(
          keys: widget.keys,
          url: url,
          email: email,
          username: username,
          password: password,
        );
      } else {
        await widget.tryLogin(
          keys: widget.keys,
          url: url,
          username: username,
          password: password,
        );
      }
    } catch (e, stackTrace) {
      debugPrint("${e.runtimeType.toString()}: ${e.toString()}\n$stackTrace");
      String message;
      if (e is ParseError) {
        message = e.message;
      } else {
        message = e.toString();
      }
      setState(() {
        this.error = message;
      });
    } finally {
      setState(() {
        this.isCommittingLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Branding
                Center(
                  child: Text(
                    "Accountable",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ** Prompt
                Center(
                  child: Text(
                    isRegisteringNewAccount
                        ? 'User Registration'
                        : 'User Login',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                if (isRegisteringNewAccount)
                  TextFormField(
                    controller: _emailController,
                    onChanged: checkCanCommitLogin,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      labelText: "Email Address",
                    ),
                  ),
                if (isRegisteringNewAccount) const SizedBox(height: 8),

                // Username
                TextFormField(
                  controller: _usernameController,
                  onChanged: checkCanCommitLogin,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    labelText: "Username",
                  ),
                ),
                const SizedBox(height: 8),

                // Password
                TextFormField(
                  controller: _passwordController,
                  onChanged: checkCanCommitLogin,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    labelText: "Password",
                  ),
                ),
                const SizedBox(height: 8),

                if (error != null)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                // ** Advanced options
                TextButton(
                  child: Row(
                    children: <Widget>[
                      Icon(showsAdvancedOptions
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down),
                      const Text('Advanced'),
                    ],
                  ),
                  onPressed: toggleAdvanced,
                ),

                // Server URL
                if (showsAdvancedOptions)
                  TextFormField(
                    controller: _urlController,
                    onChanged: checkCanCommitLogin,
                    keyboardType: TextInputType.url,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      labelText: "Server URL",
                      hintText: parseServerUrl,
                    ),
                  ),
                if (showsAdvancedOptions) const SizedBox(height: 8),

                // ** Submit
                TextButton(
                  child: isCommittingLogin
                      ? const CircularProgressIndicator()
                      : Text(isRegisteringNewAccount ? 'Register' : 'Log In'),
                  onPressed: canCommitLogin ? commitForm : null,
                ),
                TextButton(
                  child: Text(isRegisteringNewAccount
                      ? 'Log into existing'
                      : 'Create a new account'),
                  onPressed: toggleRegistrationView,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
