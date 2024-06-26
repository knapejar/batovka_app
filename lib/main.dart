import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

import 'config.dart';

import 'loginCodePage.dart';
import 'loginPage.dart';


void main() {
  runApp(const MyApp());
}
final logger = Logger();
const storage = FlutterSecureStorage();

String email = '';
String authToken = '';

const requestTimeout = Duration(seconds: 5);

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Baťovka'),
        '/login': (context) => const LoginPage(),
        '/loginCode': (context) => const LoginCodePage(),
        '/questions': (context) => const QuestionsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    checkAccount();
  }

  Future<void> checkAccount() async {
    logger.d('Checking account');
    authToken = await storage.read(key: authTokenKey) ?? '';
    email = await storage.read(key: authEmailKey) ?? '';
    if (authToken.isEmpty) {
      Navigator.pushNamed(context, '/login');
    }
    if (email.isEmpty) {
      Navigator.pushNamed(context, '/loginCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Vítejte na konferenci',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/questions');
        },
        tooltip: 'Otázky',
        child: const Icon(Icons.question_answer),
      ),
    );
  }
}

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({Key? key});

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  List<dynamic> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('$host/user/question/1')).timeout(requestTimeout);
      if (response.statusCode == 200) {
        setState(() {
          questions = jsonDecode(response.body);
          logger.d('Fetched questions: $questions');
        });
      } else {
        logger.e('Failed to fetch questions: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Failed to fetch questions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Otázky'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return ListTile(
              title: Text(question['content']),
              subtitle: Text('Author: ${question['authorName']}, Likes: ${question['likes']}'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        tooltip: 'Back',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
