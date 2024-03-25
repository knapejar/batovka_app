import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

import 'auth.dart';
import 'config.dart';

final logger = Logger();
const storage = FlutterSecureStorage();

class LoginCodePage extends StatefulWidget {
  const LoginCodePage({Key? key}) : super(key: key);

  @override
  LoginCodePageState createState() => LoginCodePageState();
}

class LoginCodePageState extends State<LoginCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Prosím zadajte kód z e-mailu';
    }
    final codeRegex = RegExp(r'^[0-9]{6}$');
    if (!codeRegex.hasMatch(value)) {
      return 'Prosím zadajte platný kód';
    }
    return null;
  }

  LoginCodePageState createState() => LoginCodePageState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kód z e-mailu'),
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
                      'Zadejte prosím kód, který jste obdrželi e-mailem',
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
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Kód v e-mailu',
                        alignLabelWithHint: true, // Align the label with the center of the field
                      ),
                      textAlign: TextAlign.center, // Center the text within the field
                      validator: _validateCode,
                      style: const TextStyle(
                        fontSize: 24.0, // Set the font size to 24.0
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                      keyboardType: TextInputType.number, // Set the keyboard type to numbers
                      maxLength: 6, // Limit the input to 6 characters
                      // allow only numbers
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
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
                        String email = await storage.read(key: authEmailKey) ?? '';
                        loginCode(email, _codeController.text, (statusCode, accessToken) {
                          if (statusCode == 200) {
                            logger.d('Logged in');
                            storage.write(key: authTokenKey, value: accessToken);
                            Navigator.pushNamed(context, '/');
                          } else {
                            if (statusCode == 401) {
                              logger.e('Unauthorized');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Neplatný kód'),
                                ),
                              );
                            } else if (statusCode == 402) {
                              logger.e('Code expired');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kód vypršel, přihlaste se prosím znovu'),
                                ),
                              );
                            } else if (statusCode == 403) {
                              logger.e('Too many attempts');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Příliš mnoho pokusů, zkuste to znovu později'),
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
                              //return;
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