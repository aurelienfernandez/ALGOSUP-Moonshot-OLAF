//------------------------- PAGES -------------------------
import 'package:olaf/home/home_page.dart';
import 'package:olaf/cache/loader.dart';
import 'package:olaf/settings/settings.dart';
import 'package:olaf/plants/plant_page.dart';
import 'package:olaf/lexica/lexica_page.dart';
//------------------------ FLUTTER ------------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/app_localization.dart';
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
class LayoutManager extends ConsumerStatefulWidget {
  @override
  _LayoutManagerState createState() => _LayoutManagerState();
}

//-------------------- HOMEPAGE STATE ---------------------
class _LayoutManagerState extends ConsumerState<LayoutManager> {
  final List<Widget> _tabs = [
    HomeScreen(),
    PlantPage(),
    LexicaPage(),
  ];

  bool _isDataLoaded = false; // Flag to track loading state

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await loadAllData(); // Load your data here
    setState(() {
      _isDataLoaded = true; // Set flag to true after loading
    });
  }

  void pageAnimation(int index) {
    // Push the setting route when the setting button is pressed
    if (index == 4) {
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
    if (!_isDataLoaded) {
      return Center(
          child: CircularProgressIndicator()); // Show loading indicator
    }
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      //---------- TITLE ----------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: mediaQuery.height * 0.08,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 5.0,
        title: ref.read(pageIndex)==0? Text("Welcome " + cacheData.getInstance().user.username,
            style: TextStyle(fontFamily: "Inter")):Text(""),
        //------ SETTINGS ------
        actions: <Widget>[
          IconButton(
            icon: ImageIcon(
              AssetImage("assets/images/settings.png"),
              size: mediaQuery.height * 0.04,
            ),
            padding: EdgeInsets.only(
                top: mediaQuery.height * 0.01, right: mediaQuery.height * 0.01),
            onPressed: () {
              pageAnimation(4);
            },
          ),
        ],
      ),

      // What is displayed in the center of the app
      body: PageView(
        physics: ScrollPhysics(),
        controller: ref.watch(_pageController),
        children: _tabs,
        onPageChanged: ((newIndex) =>
            {ref.read(pageIndex.notifier).state = newIndex}),
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
            type: BottomNavigationBarType.fixed,
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
                  "assets/images/lexicon.png",
                  width: ref.watch(pageIndex) == 2
                      ? mediaQuery.height * 0.09
                      : mediaQuery.height * 0.05,
                ),
                label: AppLocalizations.of(context).translate('lexica'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
