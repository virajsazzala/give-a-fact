import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Facts(),
      child: MaterialApp(
        title: 'Facts API Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class Facts extends ChangeNotifier {
  final List<String> facts = [];
  var currentFact = 'Loading...';
  String? apiKey;

  Facts() {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey!.isEmpty) {
        currentFact = 'API key not found. Please check your .env file.';
      } else {
        final response = await http.get(
          Uri.parse('https://api.api-ninjas.com/v1/facts?limit=1'),
          headers: {'X-Api-Key': apiKey!},
        );

        if (response.statusCode == 200) {
          List<Map<String, dynamic>> apiFacts =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          facts.clear();
          facts.addAll(apiFacts.map((fact) => fact['fact'] as String));
          updateCurrentFact();
        } else {
          currentFact = 'Failed to fetch data';
        }
      }
    } catch (error) {
      currentFact = 'Error: $error';
    }
    notifyListeners();
  }

  void updateCurrentFact() {
    Random random = Random();
    var randomFact = facts[random.nextInt(facts.length)];
    currentFact = randomFact;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<Facts>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Text(
                appState.currentFact,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    appState.fetchData();
                  },
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 60.0),
                ElevatedButton(
                  onPressed: () {
                    Share.share(
                        "Hey! Did you know that: ${appState.currentFact}");
                  },
                  child: const Icon(Icons.share),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
