//------------------- FLUTTER IMPORTS -------------------
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olaf/user_loader.dart';

//--------------------- PLANT STATE ---------------------
class PlantPage extends StatefulWidget {
  const PlantPage({super.key});

  @override
  _PlantTabState createState() => _PlantTabState();
}

//---------------------- PLANT TAB ----------------------
class _PlantTabState extends State<PlantPage> {
  int index = 0;
  int plantsLength = User.getInstance().plants.length - 1;
  void changeIndex(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (index < 0) {
      index = plantsLength;
    } else if (index > plantsLength) {
      index = 0;
    }

    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlantStatus(
            User.getInstance().plants[index],
            index,
            changeIndex: changeIndex,
          ),
        ],
      ),
    ));
  }
}

//--------------------- PLANT STATUS --------------------
class PlantStatus extends StatelessWidget {
  final Plant plant;
  final int currentIndex;
  final void Function(int) changeIndex;

  PlantStatus(this.plant, this.currentIndex, {required this.changeIndex});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 18);

    final mediaQuery = MediaQuery.sizeOf(context);
    return SingleChildScrollView(
      child: Padding(
        // Padding left/right
        padding: EdgeInsets.only(
          left: mediaQuery.width * 0.08,
          right: mediaQuery.width * 0.08,
        ),
        child: Card(
          color: theme.colorScheme.primary,
          child: SizedBox(
            height: mediaQuery.height * 0.6,
            child: Column(
              children: [
                //--------------- TITLE ---------------
                StatusTitle(
                  plant,
                  currentIndex,
                  changeIndex: changeIndex,
                ),

                Text("General", style: style.copyWith(fontSize: 20)),

                // Separation line
                Container(
                  height: MediaQuery.of(context).size.height * 0.02,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 2, // the line's size
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: mediaQuery.height * 0.02),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Global status: ", style: style),
                          Icon(
                            Icons.add_reaction,
                            color: Colors.white,
                          )
                        ],
                      ),
                      SizedBox(
                        height: mediaQuery.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Temperature:  ", style: style),
                          Icon(
                            Icons.thumb_up,
                            color: _getColorForTemperature(plant.temperature),
                          )
                        ],
                      ),
                      SizedBox(
                        height: mediaQuery.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Soil humidity:  ", style: style),
                          Icon(
                            Icons.water_drop_rounded,
                            color: _getColorForhumidity(plant.soilHumidity),
                          )
                        ],
                      ),
                      SizedBox(
                        height: mediaQuery.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Air humidity:  ", style: style),
                          Icon(
                            Icons.water_drop,
                            color: _getColorForhumidity(plant.airHumidity),
                          ),
                          Icon(
                            Icons.air,
                            color: _getColorForhumidity(plant.airHumidity),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: mediaQuery.height * 0.04,
                ),
                Text("Additional data", style: style.copyWith(fontSize: 20)),

                // Separation line
                Container(
                  height: MediaQuery.of(context).size.height * 0.02,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 2, // the line's size
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: mediaQuery.height * 0.02),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Temperature:", style: style),
                            Text(
                              " ${plant.temperature}",
                              style: style,
                            ),
                          ]),
                      SizedBox(
                        height: mediaQuery.height * 0.02,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Soil humidity:", style: style),
                            Text(
                              " ${plant.soilHumidity}",
                              style: style,
                            ),
                          ]),
                      SizedBox(
                        height: mediaQuery.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Air humidity:", style: style),
                          Text(
                            " ${plant.airHumidity}",
                            style: style,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// This function get modifies the color of the temperature
Color _getColorForTemperature(String temperature) {
  // Remove all non-number characters
  String newTemp = temperature.replaceAll(RegExp(r'[^0-9.]'), '').trim();
  // Parse double from string
  double finalTemp = double.parse(newTemp);
  if (finalTemp <= 10) {
    return Colors.blue.shade800;
  } else if (finalTemp >= 30) {
    return Colors.red;
  } else {
    return Colors.white; // Or any other default color you prefer
  }
}

Color _getColorForhumidity(String temperature) {
  // Remove all non-number characters
  String newTemp = temperature.replaceAll(RegExp(r'[^0-9.]'), '').trim();
  // Parse double from string
  double finalTemp = double.parse(newTemp);
  if (finalTemp <= 50) {
    return Colors.red;
  } else if (finalTemp >= 90) {
    return Colors.blue.shade900;
  } else {
    return Colors.white; // Or any other default color you prefer
  }
}

/// This widget contains the image and the selection of the plant
class StatusTitle extends StatelessWidget {
  final Plant plant;
  final int currentIndex;
  final void Function(int) changeIndex;

  StatusTitle(this.plant, this.currentIndex, {required this.changeIndex});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);
    return Column(children: [
      //--------------- IMAGE ---------------
      SizedBox(
        width: mediaQuery.width * 0.15,
        height: mediaQuery.height * 0.03,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.loose,
          children: [
            Positioned(
              left: -mediaQuery.width * 0.42,
              top: -mediaQuery.height * 0.02,
              child: Container(
                width: mediaQuery.width * 0.15,
                height: mediaQuery.height * 0.075,
                decoration: BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: DecorationImage(
                    image: NetworkImage(
                      plant.image,
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      //------------- SELECTION -------------
      Padding(
        padding: EdgeInsets.only(
          left: mediaQuery.width * 0.03,
        ),
        child: Row(
          children: [
            //--------- PREVIOUS --------
            IconButton(
              onPressed: () {
                changeIndex(currentIndex - 1);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: mediaQuery.width * 0.1,
              ),
            ),
            //----------- NAME ----------
            Expanded(
              child: AutoSizeText(
                plant.name,
                style: style,
                maxLines: 1,
                maxFontSize: 40,
                minFontSize: 20,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            //----------- NEXT ----------
            IconButton(
              onPressed: () {
                changeIndex(currentIndex + 1);
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: mediaQuery.width * 0.1,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
