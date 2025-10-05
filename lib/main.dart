import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 3, // 3 buttons per row
          crossAxisSpacing: 8.0, // Spacing between columns
          mainAxisSpacing: 8.0, // Spacing between rows
          children: List.generate(9, (index) {
            return ElevatedButton(
              onPressed: () {
                // TODO: Implement action for button ${index + 1}
                print('Button ${index + 1} pressed');
              },
              child: Text(
                'Action ${index + 1}',
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ),
    );
  }
}
