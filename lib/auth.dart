import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

import 'config.dart';

final logger = Logger();

Future<void> loginWithEmail(String email, Function callback) async {
  const url = '$host/login';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    logger.d('Login response: ${response.body}');

    callback(response.statusCode);
  } catch (e) {
    logger.e('Failed to login: $e');
    callback(-1); // Error code for login failure
  }
}

Future<void> loginCode(String email, String code, Function callback) async {
  const url = '$host/loginCode';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    logger.d('Login code response: ${response.body}');

    if (response.statusCode == 200) {
      final String accessToken = await jsonDecode(response.body)['access_token'];
      callback(response.statusCode, accessToken);
    } else {
      callback(response.statusCode, '');
    }
  } catch (e) {
    logger.e('Failed to login with code: $e');
    callback(-1, '');
  }
}