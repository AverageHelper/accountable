import 'package:accountable/model/Keys.dart';
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
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  String? error;
  bool canCommitLogin = false;
  bool isCommittingLogin = false;
  bool showsAdvancedOptions = false;
  bool isRegisteringNewAccount = false;

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
          (!isRegisteringNewAccount ||
              (_emailController.text.trim().isNotEmpty &&
                  _repeatPasswordController.text.isNotEmpty &&
                  _passwordController.text == _repeatPasswordController.text));
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
      this._repeatPasswordController.clear();
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

  Widget urlField(FocusScopeNode node) {
    return TextFormField(
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
    );
  }

  Widget emailField(FocusScopeNode node) {
    return TextFormField(
      controller: _emailController,
      onChanged: checkCanCommitLogin,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      autofillHints: [AutofillHints.email],
      textInputAction: TextInputAction.next,
      onEditingComplete: () => node.nextFocus(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
        ),
        labelText: "Email address",
      ),
    );
  }

  Widget usernameField(FocusScopeNode node) {
    return TextFormField(
      controller: _usernameController,
      onChanged: checkCanCommitLogin,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      autofillHints: [
        isRegisteringNewAccount
            ? AutofillHints.newUsername
            : AutofillHints.username
      ],
      textInputAction: TextInputAction.next,
      onEditingComplete: () => node.nextFocus(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
        ),
        labelText: "Username",
      ),
    );
  }

  Widget passwordField(FocusScopeNode node) {
    return TextFormField(
      controller: _passwordController,
      onChanged: checkCanCommitLogin,
      obscureText: true,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      autofillHints: [
        isRegisteringNewAccount
            ? AutofillHints.newPassword
            : AutofillHints.password
      ],
      textInputAction: isRegisteringNewAccount ? TextInputAction.next : null,
      onEditingComplete:
          isRegisteringNewAccount ? () => node.nextFocus() : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
        ),
        labelText: "Password",
      ),
    );
  }

  Widget repeatPasswordField(FocusScopeNode node) {
    return TextFormField(
      controller: _repeatPasswordController,
      onChanged: checkCanCommitLogin,
      obscureText: true,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      autofillHints: [AutofillHints.newPassword],
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
        ),
        labelText: "Repeat password",
      ),
    );
  }

  Widget errorView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        error ?? "",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget advancedToggleButton() {
    return TextButton(
      child: Row(
        children: <Widget>[
          Icon(showsAdvancedOptions
              ? Icons.arrow_drop_up
              : Icons.arrow_drop_down),
          const Text('Advanced'),
        ],
      ),
      onPressed: toggleAdvanced,
    );
  }

  Widget submitButton() {
    return TextButton(
      child: isCommittingLogin
          ? const CircularProgressIndicator()
          : Text(isRegisteringNewAccount ? 'Register' : 'Log In'),
      onPressed: canCommitLogin ? commitForm : null,
      // style: ButtonStyle(alignment: Alignment.centerRight),
    );
  }

  Widget toggleViewButton() {
    return TextButton(
      child: Text(
        isRegisteringNewAccount ? 'Log into existing' : 'Create a new account',
      ),
      onPressed: toggleRegistrationView,
      // style: ButtonStyle(alignment: Alignment.centerRight),
    );
  }

  Widget branding() {
    return Container(
      // color: Colors.blueGrey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Accountable",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRegisteringNewAccount
                  ? 'Create an account'
                  : 'Log into your account',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget form(BuildContext context) {
    final FocusScopeNode node = FocusScope.of(context);
    return Container(
      // color: Colors.lightGreen,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Fields
                if (isRegisteringNewAccount) emailField(node),
                usernameField(node),
                passwordField(node),
                if (isRegisteringNewAccount) repeatPasswordField(node),
                if (error != null) errorView(),

                // Advanced
                advancedToggleButton(),
                if (showsAdvancedOptions) urlField(node),

                // Buttons
                submitButton(),
                toggleViewButton(),
              ]
                  .map(
                    (e) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ),
                      child: e,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: branding(),
            ),
            Expanded(
              flex: 2,
              child: form(context),
            ),
          ],
        ),
      ),
    );
  }
}
