import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/flutter_simulator.dart';

void main() {
  runFlutterSimulatorApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
    ).copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
            color: Colors.white,
            foregroundColor: Colors.black,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
    );

    final darkTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      useInheritedMediaQuery: true,
      color: Colors.yellow,
      scrollBehavior: FlutterSimulatorScrollBehavior(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
      Colors.indigo,
      Colors.brown,
      Colors.grey,
      Colors.amber,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.blueGrey,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      resizeToAvoidBottomInset: true,
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.newspaper),
      //       label: 'News',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
      body: ListView.builder(
        itemBuilder: (context, i) {
          if (i % 5 == 0) {
            return const ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 128.0,
                child: TextField(
                  maxLines: 3,
                  keyboardAppearance: Brightness.light,
                ),
              ),
            );
          }
          if (i % 5 == 1) {
            return const ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: double.infinity,
                height: 128.0,
                child: TextField(
                  maxLines: 3,
                ),
              ),
            );
          }

          if (i % 5 == 2) {
            return Row(
              children: [
                for (var j = 0; j < 5; j++)
                  Expanded(
                    child: ColoredBox(
                      color: (i + j) % 2 == 0 ? Colors.white : Colors.black,
                      child: const SizedBox(
                        width: double.infinity,
                        height: 128.0,
                      ),
                    ),
                  ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: ColoredBox(
                  color: colors[i % colors.length],
                  child: const SizedBox(
                    width: double.infinity,
                    height: 128.0,
                  ),
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: colors[(i + 5) % colors.length],
                  child: const SizedBox(
                    width: double.infinity,
                    height: 128.0,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
