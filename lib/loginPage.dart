import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth.dart';
import 'config.dart';

final logger = Logger();
const storage = FlutterSecureStorage();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Prosím zadejte Váš email';
    }
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Prosím zadejte platný email';
    }
    return null;
  }

  LoginPageState createState() => LoginPageState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Přihlášení'),
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Zadejte prosím Váš email, který jste uvedli při registraci',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: _validateEmail,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Disable login button
                        setState(() {
                          _formKey.currentState!.save();
                        });
                        // login with callback to navigate to the next page
                        loginWithEmail(_emailController.text, (statusCode) async {
                          if (statusCode == 200) {
                            logger.d('Invoked logging in');    
                            await storage.write(key: authEmailKey, value: _emailController.text);
                            Navigator.pushNamed(context, '/loginCode');
                          } else {
                            if (statusCode == 401) {
                              logger.e('Unauthorized');
                              // Show error message to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Neplatný email'),
                                ),
                              );
                            } else {
                              logger.e('Failed to login');
                              // Show error message to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Přihlášení se nezdařilo'),
                                ),
                              );
                            }
                            // Enable login button
                            _formKey.currentState!.reset();
                            setState(() {});
                          }
                        });
                      }
                    },
                    child: const Text('Přihlásit se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}