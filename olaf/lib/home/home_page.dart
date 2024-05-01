//------------------------- PAGES -------------------------

import '../plants/plant_page.dart';
import '../lexica/lexica_page.dart';
//------------------------ FLUTTER ------------------------
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
//-------------------------- JSON -------------------------
import '../user_loader.dart';

//---------------- HOMEPAGE INITIALIZATION ----------------
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//-------------------- HOMEPAGE STATE ---------------------
class _MyHomePageState extends State<MyHomePage> {
  int currentIndex;

  _MyHomePageState([this.currentIndex = 0]);

  final List<Widget> _tabs = [
    HomeScreen(),
    PlantScreen(),
    LexicaPage(),
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

      body: _tabs[currentIndex],
      //---------- NAVBAR ----------
      bottomNavigationBar: ClipRRect(
        // Rounded corners
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.09, // Navbar size
          child: BottomNavigationBar(
            //---- STYLE ----
            selectedLabelStyle: TextStyle(color: Colors.white),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            //---- STATE ----
            currentIndex: currentIndex,
            onTap: (int index) {
              setState(() {
                if (currentIndex == index && index == 2) {
                  // If the current index is tapped again, reset the state of the current page
                  _tabs[currentIndex] = LexicaPage(key: UniqueKey());
                } else {
                  currentIndex = index;
                }
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
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.012,
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              child: PlantCard(plantsList[i].name, plantsList[i].image)),
        ),
      );
    }

    if (plantCards.isNotEmpty) {
      plantCards.last = Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
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
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Stack(clipBehavior: Clip.none, fit: StackFit.loose, children: [
          //---------- IMAGE ----------
          Positioned(
            left: -MediaQuery.of(context).size.width * 0.24,
            top: -MediaQuery.of(context).size.height * 0.018,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
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
