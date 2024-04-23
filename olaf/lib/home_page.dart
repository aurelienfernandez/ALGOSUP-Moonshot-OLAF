//------------------------- PAGES -------------------------

import 'plant_page.dart';
import 'encyclopedia_page.dart';
//------------------------ FLUTTER ------------------------
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
//-------------------------- JSON -------------------------
import 'json_parser.dart';

//---------------- HOMEPAGE INITIALIZATION ----------------
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//-------------------- HOMEPAGE STATE ---------------------
class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    HomeScreen(),
    PlantScreen(),
    EncyclopediaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //---------- TITLE ----------
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        // Create CircleAvatar
        title: CircleAvatar(
          radius: MediaQuery.of(context).size.height * 0.035,
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
              size: MediaQuery.of(context).size.height * 0.06,
            ),
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
                right: MediaQuery.of(context).size.height * 0.01),
            onPressed: () {
              // Here it should open the "setting page"
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),

      body: _tabs[_currentIndex],
      //---------- NAVBAR ----------
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0), // Adjust the radius as needed
          topRight: Radius.circular(30.0), // Adjust the radius as needed
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.09,
          child: BottomNavigationBar(
            //---- STYLE ----
            selectedLabelStyle: TextStyle(color: Colors.white),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            //---- STATE ----
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
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
                label: 'Encyclopedia',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//------------------------ HOMEPAGE -----------------------
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [Status(), Gardens()])));
  }
}

//------------------------- STATUS ------------------------
class Status extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 25.0);
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: theme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Text(
                "Hello ${User.getInstance().username},\n Your plants are fine",
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//------------------------ GARDENS ------------------------
class Gardens extends StatefulWidget {
  @override
  _GardensState createState() => _GardensState();
}

//--------------------- GARDENS STATE ---------------------
class _GardensState extends State<Gardens> {
  List<Plant> plantsList = User.getInstance().plants;
  late User user;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      // Return a loading indicator or placeholder widget while data is being loaded
      return Padding(
        padding: EdgeInsets.only(top: 50),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      );
    }

    // For each plants in user's account, add it to the widget list
    List<Widget> plantCards = [];
    for (var i = 0; i < plantsList.length; i++) {
      plantCards.add(
        Card(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.height * 0.05,
          ),
          color: theme.primaryColor,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              child: PlantCard(plantsList[i].name, plantsList[i].image)),
        ),
      );
    }

    if (plantCards.isNotEmpty) {
      plantCards.last = Padding(
        padding: EdgeInsets.only(bottom: 30.0),
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
        fontSize: 25.0,
        backgroundColor: theme.colorScheme.primary);

    return SizedBox(
        height: 50,
        width: 120,
        child: Stack(clipBehavior: Clip.none, fit: StackFit.loose, children: [
          //---------- IMAGE ----------
          Positioned(
            left: -100,
            top: -15,
            child: Container(
              width: 80.0,
              height: 80.0,
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
          Positioned(
            top: 8,
            left: -15,
            width: 150,
            child: AutoSizeText(
              text, style: style, maxLines: 1, maxFontSize: 25.0,
              minFontSize: 20,
              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
            ),
          ),
        ]));
  }
}
