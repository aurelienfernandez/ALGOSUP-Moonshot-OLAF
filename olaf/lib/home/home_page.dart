//------------------------- PAGES -------------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/user_loader.dart';
import '../settings/settings.dart';
import '../plants/plant_page.dart';
import '../lexica/lexica_page.dart';
//------------------------ FLUTTER ------------------------
import 'package:marquee/marquee.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

//--------------------- PROVIDERS ----------------------
final pageIndex = StateProvider<int>((ref) => 0);

//---------------- HOMEPAGE INITIALIZATION ----------------
class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

//-------------------- HOMEPAGE STATE ---------------------
class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController();
  final List<Widget> _tabs = [
    HomeScreen(),
    PlantPage(),
    LexicaPage(),
    SettingsPage(),
  ];

  // A short animation when changing page
  void pageAnimation(int index) {
    _tabs[ref.watch(pageIndex)];

    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);
    return Scaffold(
      //---------- TITLE ----------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: mediaQuery.height * 0.08,
        // Create CircleAvatar
        title: CircleAvatar(
          radius: mediaQuery.height * 0.035,
          backgroundImage: NetworkImage(
            User.getInstance().profilePicture,
          ),
        ),
        //------- BUTTON -------
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
        controller: _pageController,
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
            selectedLabelStyle: TextStyle(color: Colors.white),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            backgroundColor: theme.colorScheme.primary,
            //---- STATE ----
            onTap: (int index) {
              ref.invalidate(tab);
              // If the current index is tapped again, reset the state of the current page
              if (ref.read(pageIndex) == index && index == 2) {
                _tabs[ref.read(pageIndex)] = LexicaPage(key: UniqueKey());
              } else {
                pageAnimation(index);
                ref.read(pageIndex.notifier).state = index;
              }
            },
            //---- ITEMS ----
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Plants',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'lexica',
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
      body: SingleChildScrollView(
        child: Column(children: [Status(), Gardens()]),
      ),
    );
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
                "Hello ${User.getInstance().username},\nYour plants are fine",
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
  List<Plant> plantsList = User.getInstance().plants;
  late User user;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);

    if (isLoading) {
      // Return a loading indicator or placeholder widget while data is being loaded
      return Padding(
        padding: EdgeInsets.only(top: 50),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      );
    }

    // For each plants in user's account, add it to the widget list
    List<Widget> plantCards = [];
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
                  ref.read(pageIndex.notifier).state = 1;
                  ref.read(plantsIndex.notifier).state = i;
                },
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: mediaQuery.height * 0.012,
                          horizontal: mediaQuery.width * 0.1),
                      child: PlantCard(plantsList[i].name, plantsList[i].image),
                    ),
                  ],
                ))),
      );
    }

    // Add a padding at the end of the column
    if (plantCards.isNotEmpty) {
      plantCards.last = Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.height * 0.02),
        child: plantCards.last,
      );
    }
    return Column(
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
        fontSize: 22,
        backgroundColor: theme.colorScheme.primary);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textWidth = textPainter.width;
    Widget textWidget;

    final mediaQuery = MediaQuery.sizeOf(context);

    if (textWidth > mediaQuery.width * 0.3) {
      textWidget = Align(
        alignment:
            Alignment.centerRight, // Aligns the Marquee widget to the right
        child: SizedBox(
          width: mediaQuery.width * 0.3,
          child:
              // Use Marquee if text exceeds available width
              Marquee(
            text: text,
            style: style.copyWith(backgroundColor: Colors.transparent),
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
      // Use AutoSizeText if text fits within available width
      textWidget = Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: Text(
            textAlign: TextAlign.center,
            text,
            style: style.copyWith(backgroundColor: Colors.transparent),
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
            left: -mediaQuery.width * 0.24,
            top: -mediaQuery.height * 0.018,
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
