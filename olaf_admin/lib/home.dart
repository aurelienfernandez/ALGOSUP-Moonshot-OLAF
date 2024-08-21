//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf_admin/amplify.dart';
import 'package:olaf_admin/cache/shared_preferences.dart';

//------------------- FLUTTER IMPORTS -------------------
import 'package:flutter/material.dart';
import 'package:olaf_admin/lexica/lexica_choice.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool waitingRefresh = false;

  Future<void> initialization() async {
    try {
      final dynamodb = await initializeDynamoDB();
      await awsToCache(dynamodb);
      await getCachedData();
    } catch (error) {
      debugPrint("Error: $error");
      throw "Couldn't load dynamoDB, $error";
    } finally {
      debugPrint("Initialization finished");
    }
  }

  @override
  void initState() {
    super.initState();
    initialization();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() async {
    if (waitingRefresh == false) {
      await _controller.forward(from: 0).then((value) => waitingRefresh = true);
      getCachedData().then((value) {
        setState(() {
          waitingRefresh = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: mediaQuery.height * 0.7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaQuery.width * 0.15),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(mediaQuery.width * 0.15,
                              mediaQuery.height * 0.07),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Update model",
                            style:
                                TextStyle(fontSize: mediaQuery.width * 0.015),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: mediaQuery.height * 0.02,
                                bottom: mediaQuery.height * 0.01),
                            child: ImageIcon(
                              const AssetImage(
                                'assets/images/aiIcon-admin.png',
                              ),
                              size: mediaQuery.width * 0.035,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const VerticalDivider(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: mediaQuery.width * 0.15),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                            Size(mediaQuery.width * 0.15,
                                mediaQuery.height * 0.07),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LexicaPage()),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Update lexica",
                              style:
                                  TextStyle(fontSize: mediaQuery.width * 0.015),
                            ),
                            ImageIcon(
                              const AssetImage(
                                'assets/images/lexica-admin.png',
                              ),
                              size: mediaQuery.width * 0.04,
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        SizedBox(
          height: mediaQuery.height * 0.05,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _handlePress,
              icon: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value *
                        2 *
                        3.1416, // Full rotation (360 degrees)
                    child: child,
                  );
                },
                child: Icon(
                  waitingRefresh == false
                      ? Icons.refresh
                      : Icons.access_time_rounded,
                  size: mediaQuery.width * 0.03,
                ),
              ),
            ),
            SizedBox(width: mediaQuery.width * 0.02),
            ElevatedButton.icon(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(mediaQuery.width * 0.15, mediaQuery.height * 0.07)),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: mediaQuery.width * 0.02,
                ),
                label: Text(
                  "Nothing to push",
                  style: TextStyle(
                      color: Colors.green, fontSize: mediaQuery.width * 0.013),
                ))
          ],
        )
      ]),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}
