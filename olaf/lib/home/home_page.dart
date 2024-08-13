//------------------------- PAGES -------------------------
import 'dart:io';

import 'package:olaf/main.dart';
import 'package:olaf/settings/settings.dart';
import 'package:olaf/plants/plant_page.dart';
import 'package:olaf/lexica/lexica_page.dart';
import 'package:olaf/camera/camera.dart';
//------------------------ FLUTTER ------------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:olaf/app_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:async';
//------------------------- UTILS -------------------------
import 'package:olaf/utils.dart';
import 'package:olaf/classes.dart';

//--------------------- PROVIDERS ----------------------
final pageIndex = StateProvider<int>((ref) => 0);

final _pageController =
    StateProvider<PageController>(((ref) => PageController()));

//---------------- HOMEPAGE INITIALIZATION ----------------
class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

//-------------------- HOMEPAGE STATE ---------------------
class _HomePageState extends ConsumerState<HomePage> {
  final List<Widget> _tabs = [
    HomeScreen(),
    PlantPage(),
    LexicaPage(),
  ];

  Timer? _authCheckTimer;
  void _startAuthCheckTimer() {
    _authCheckTimer = Timer.periodic(Duration(milliseconds: 1), (timer) async {
      try {
        final result = await Amplify.Auth.fetchAuthSession();
        if (result.isSignedIn) {
          ref.read(themeChangerProvider.notifier).setTheme(stdTheme);
          _authCheckTimer?.cancel();
        }
      } catch (e) {
        print('Error checking auth status: $e');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startAuthCheckTimer();
  }

  void pageAnimation(int index) {
    // Push the setting route when the setting button is pressed
    if (index == 3) {
      Navigator.push(context, SlideToSettings(page: SettingsPage()))
          .then((value) => setState(() {}));
    } else if (index != ref.read(pageIndex)) {
      // A short animation when changing page
      ref.read(_pageController.notifier).state.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);
    if (!cacheData.isInitialized()) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      //---------- TITLE ----------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: mediaQuery.height * 0.08,
        // Create CircleAvatar
        title: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: mediaQuery.height * 0.035,
          backgroundImage: cacheData.getInstance().user.profilePicture ==
                  "assets/images/no-image.png"
              ? AssetImage("assets/images/no-image.png") as ImageProvider
              : FileImage(File(cacheData.getInstance().user.profilePicture)),
        ),
        //------ SETTINGS ------
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              size: mediaQuery.height * 0.06,
            ),
            padding: EdgeInsets.only(
                top: mediaQuery.height * 0.01, right: mediaQuery.height * 0.01),
            onPressed: () {
              pageAnimation(3);
            },
          ),
        ],
        backgroundColor: theme.colorScheme.secondary,
      ),

      // What is displayed in the center of the app
      body: PageView(
        physics: ScrollPhysics(),
        controller: ref.watch(_pageController),
        children: _tabs,
      ),

      //---------- NAVBAR ----------
      bottomNavigationBar: ClipRRect(
        // Rounded corners
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: SizedBox(
          height: mediaQuery.height * 0.09,
          child: BottomNavigationBar(
            //---- STYLE ----
            selectedLabelStyle: TextStyle(fontSize: 0),
            unselectedLabelStyle: TextStyle(fontSize: 0),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            backgroundColor: theme.colorScheme.primary,
            //---- STATE ----
            onTap: (int index) {
              ref.invalidate(tab);

              pageAnimation(index);
              ref.read(pageIndex.notifier).state = index;
            },
            //---- ITEMS ----
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/home.png",
                  width: ref.watch(pageIndex) == 0
                      ? mediaQuery.height * 0.09
                      : mediaQuery.height * 0.05,
                ),
                label: AppLocalizations.of(context).translate('home'),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/plants.png",
                  width: ref.watch(pageIndex) == 1
                      ? mediaQuery.height * 0.09
                      : mediaQuery.height * 0.05,
                ),
                label: AppLocalizations.of(context).translate('plants'),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/lexica.png",
                  width: ref.watch(pageIndex) == 2
                      ? mediaQuery.height * 0.09
                      : mediaQuery.height * 0.05,
                ),
                label: AppLocalizations.of(context).translate('lexica'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//------------------------ HOMEPAGE -----------------------
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.invalidate(pageIndex);
    return Scaffold(
        body: SizedBox.expand(
      child: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [Status(), Gardens()],
          ),
        ),
        Analyse()
      ]),
    ));
  }
}

//------------------------- STATUS ------------------------
class Status extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 25);
    final mediaQuery = MediaQuery.sizeOf(context);

    return Container(
      margin: EdgeInsets.only(top: mediaQuery.height * 0.05),
      child: Center(
        child: Card(
          color: theme.colorScheme.primary,
          child: SizedBox(
            width: mediaQuery.width * 0.9,
            child: Padding(
              padding: EdgeInsets.all(
                  mediaQuery.width * 0.05), // Adjust padding as needed
              child: AutoSizeText(
                AppLocalizations.of(context).translate('hello_fine').replaceAll(
                    '{username}', cacheData.getInstance().user.username),

                style: style, maxLines: 2,
                maxFontSize: 25,
                minFontSize: 20,
                overflow:
                    TextOverflow.ellipsis, // Handle overflow with ellipsis
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//------------------------ GARDENS ------------------------
class Gardens extends ConsumerStatefulWidget {
  @override
  _GardensState createState() => _GardensState();
}

//--------------------- GARDENS STATE ---------------------
class _GardensState extends ConsumerState<Gardens> {
  List<Plant> plantsList = cacheData.getInstance().savedPlants;
  late User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);

    // For each plants in user's account, add it to the widget list
    List<Widget> plantCards = [];
    if (plantsList.isEmpty) {
      var name = "new plant";
      var image =
          "https://www.southernliving.com/thmb/8sJLpOMVrdM3RO6GeyuSVAJa9G8=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-1365178498-81dd069cd1514e288e68516bc96df8d4.jpg";

      plantCards.add(Card(
        child: TextButton.icon(
            onPressed: () {
              setState(() {
                plantCards.remove(0);
                cacheData.getInstance().savedPlants.add(Plant(
                    name: name,
                    image: image,
                    disease: "none",
                    maturation: "mature",
                    soilHumidity: "90M",
                    airHumidity: "70%",
                    temperature: "23°"));
                plantCards.add(
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: mediaQuery.height * 0.05,
                        left: mediaQuery.height * 0.1,
                        right: mediaQuery.height * 0.08,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary),
                        onPressed: () {
                          ref
                              .read(_pageController.notifier)
                              .state
                              .animateToPage(1,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                          ref.read(pageIndex.notifier).state = 1;
                          ref.read(plantsIndex.notifier).state = 0;
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: mediaQuery.height * 0.012,
                                  horizontal: mediaQuery.width * 0.08),
                              child: PlantCard(name, image),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
            icon: Icon(Icons.add),
            label: Text("Add a plant")),
      ));
    }
    for (var i = 0; i < plantsList.length; i++) {
      plantCards.add(
        Container(
            margin: EdgeInsets.only(
              top: mediaQuery.height * 0.05,
              left: mediaQuery.height * 0.1,
              right: mediaQuery.height * 0.08,
            ),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary),
                onPressed: () {
                  ref.read(_pageController.notifier).state.animateToPage(1,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                  ref.read(pageIndex.notifier).state = 1;
                  ref.read(plantsIndex.notifier).state = i;
                },
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: mediaQuery.height * 0.012,
                          horizontal: mediaQuery.width * 0.08),
                      child: PlantCard(plantsList[i].name, plantsList[i].image),
                    ),
                  ],
                ))),
      );
    }

    // Add a padding at the end of the column

    plantCards.last = Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.height * 0.02),
      child: plantCards.last,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: plantCards,
    );
  }
}

//----------------------- PLANT CARD ----------------------
class PlantCard extends StatelessWidget {
  final String text;
  final String imagePath;
  PlantCard(this.text, this.imagePath);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary);
    final mediaQuery = MediaQuery.sizeOf(context);
    final textPainter = TextPainter(
      text: TextSpan(
          text: text, style: style.copyWith(fontSize: mediaQuery.width * 0.05)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textWidth = textPainter.width;
    Widget textWidget;

    if (textWidth > mediaQuery.width * 0.3) {
      textWidget = Align(
        child: SizedBox(
          width: mediaQuery.width * 0.3,
          child:
              // Use Marquee if text exceeds available width
              Marquee(
            text: text,
            style: style.copyWith(
                backgroundColor: Colors.transparent,
                fontSize: mediaQuery.width * 0.05),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: mediaQuery.width * 0.3,
            velocity: 30.0,
            pauseAfterRound: Duration(seconds: 1),
            startPadding: 5.0,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
      );
    } else {
      // Use a normal text field if text fits within available width
      textWidget = Positioned.fill(
        bottom: mediaQuery.height * 0.002,
        child: Align(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: style.copyWith(
                backgroundColor: Colors.transparent,
                fontSize: mediaQuery.width * 0.05),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return SizedBox(
      height: mediaQuery.height * 0.06,
      width: mediaQuery.width * 0.3,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.loose,
        children: [
          //---------- IMAGE ----------
          Positioned(
            left: -mediaQuery.width * 0.2,
            top: -mediaQuery.height * 0.015,
            child: Container(
              width: mediaQuery.width * 0.2,
              height: mediaQuery.width * 0.2,
              decoration: BoxDecoration(
                color: const Color(0xff7c94b6),
                image: DecorationImage(
                  image: NetworkImage(
                    imagePath,
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 4.0,
                ),
              ),
            ),
          ),
          //---------- NAME ----------
          textWidget
        ],
      ),
    );
  }
}

class Analyse extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.sizeOf(context);
    return Positioned(
        top: mediaQuery.height * 0.63,
        left: mediaQuery.width * 0.83,
        child: IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CameraScreen(
                          cameras: ref.read(CamerasProvider),
                        )));
          },
          icon: Icon(
            Icons.search,
            size: mediaQuery.width * 0.15,
          ),
          color: Colors.green.shade900,
        ));
  }
}
