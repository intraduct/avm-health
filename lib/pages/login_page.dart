import 'package:avm_symptom_tracker/notifications/notifications_helper.dart' as nh;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../database/database_helper.dart';
import '../database/secure_storage_helper.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: ListTile(
            leading: Image.asset('assets/icons/app_icon.png'),
            title: Text(
              'Alltagsstudie\nVaskuläre\nMalformation',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 200,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final auth = LocalAuthentication();

  bool? _quickUnlock;
  String? _user;
  String? _pass;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    SecureStorageHelper.read('user').then((user) => setState(() {
          _user = user;
          _usernameController.text = user ?? '';
        }));
    SecureStorageHelper.read('pass').then((pass) => setState(() => _pass = pass));
    SecureStorageHelper.readQuickUnlock().then((quickUnlock) {
      setState(() => _quickUnlock = quickUnlock);
      if (_quickUnlock == true) {
        _handleQuickUnlock();
      }
    });
  }

  void _handleQuickUnlock() {
    auth.isDeviceSupported().then((isSupported) {
      auth.getAvailableBiometrics().then((availableBiometrics) {
        if (isSupported && availableBiometrics.isNotEmpty) {
          return auth
              .authenticate(
                  localizedReason: 'Zum schnellen Login, bitte Anweisungen befolgen!',
                  options: const AuthenticationOptions(biometricOnly: true))
              .then((authenticated) {
            if (authenticated) {
              setState(() => _authenticated = true);
              _handleLogin();
            }
          });
        } else {
          SecureStorageHelper.writeQuickUnlock(false);
        }
      });
    });
  }

  Future<void> _handleLogin() async {
    String user;
    String pass;
    if (_authenticated && _user != null && _pass != null) {
      user = _user!;
      pass = _pass!;
    } else {
      user = _usernameController.text;
      pass = _passwordController.text;
    }

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Username und Passwort eingeben'),
        ),
      );
      return;
    }

    if (true) {
      // replace this condition with server evaluation of creds
      await SecureStorageHelper.write('user', user);
      await SecureStorageHelper.write('pass', pass);

      // set default quick-unlock to true
      await SecureStorageHelper.readQuickUnlock().then((quickUnlock) {
        if (quickUnlock == null) SecureStorageHelper.writeQuickUnlock(true);
      });

      DatabaseHelper().fetchNotifications().then((dbNotifications) {
        nh.scheduleNotifications(dbNotifications);
        return Navigator.pushReplacementNamed(context, '/calendar', arguments: user);
      });
    } /* else {
      // reset the login 
      setState(() {
        _user = null;
        _pass = null;
      });
    } */
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Login',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _handleLogin(),
            child: const Text('Login'),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
