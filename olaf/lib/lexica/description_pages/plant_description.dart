import 'package:flutter/material.dart';
import 'package:olaf/app_localization.dart';
import 'package:olaf/lexica/lexica_page.dart';

/// This class creates the page displaying all information related to a plant
/// from the lexicon.
///
/// Parameters:
/// - `name`: the name of the plant.
/// - `image`: The picture of the plant.
/// - `description`: The description of how to take care of this plant.
/// - `tips`: Tips dedicated to this plant.
/// - `temperatureRange`: The ideal temperature range for the plant.
/// - `soilHumidityRange`: The ideal soil humidity range for the plant.
/// - `airHumidityRange`: The ideal air humidity range for the plant.
/// - `season`: The season when the plant grows best.
class PlantDescription extends StatelessWidget {
  final String name;
  final String image;
  final String description;
  final List<String> tips;
  final List<int> temperatureRange;
  final List<int> soilHumidityRange;
  final List<int> airHumidityRange;
  final String? season;

  PlantDescription(
    this.name,
    this.image,
    this.description,
    this.tips,
    this.temperatureRange,
    this.soilHumidityRange,
    this.airHumidityRange,
    this.season,
  );

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    final Widget tipWidget = Text(
      tips
          .map((tip) => '• $tip')
          .join('\n\n'), // Place all tips inside a single text widget
      style: TextStyle(
          fontSize: mediaQuery.width * 0.05,
          height: mediaQuery.height * 0.0015),
    );

    final Widget descriptionWidget = Text(
      description,
      style: TextStyle(fontSize: mediaQuery.width * 0.05),
    );

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            //========== SPACE ===========
            SizedBox(
              height: mediaQuery.height * 0.03,
            ),
            //=========== NAME ===========
            Container(
              width: mediaQuery.width * 0.7,
              height: mediaQuery.height * 0.08,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: theme.colorScheme.secondary),
              child: Center(
                child: Text(
                  name,
                  style: TextStyle(
                      color: Colors.black, fontSize: mediaQuery.width * 0.07),
                ),
              ),
            ),
            //========== SPACE ===========
            SizedBox(
              height: mediaQuery.height * 0.03,
            ),
            //========== IMAGE ===========
            Container(
              width: mediaQuery.width * 0.5,
              height: mediaQuery.width * 0.5,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: theme.colorScheme.secondary),
              child: Center(
                  child: Container(
                width: mediaQuery.width * 0.43,
                height: mediaQuery.width * 0.43,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: theme.colorScheme.primary,
                      width: mediaQuery.width * 0.015),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              )),
            ),
            //========== SPACE ===========
            SizedBox(
              height: mediaQuery.height * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //======= TEMP & AIR =========
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    dataCard(
                      AppLocalizations.of(context)
                          .translate("ideal_temperature"),
                      "${temperatureRange[0]}°C - ${temperatureRange[1]}°C",
                      "temperature",
                    ),
                    //========== SPACE ===========
                    SizedBox(
                      height: mediaQuery.height * 0.03,
                    ),
                    dataCard(
                      AppLocalizations.of(context).translate("ideal_air"),
                      "${airHumidityRange[0]}% - ${airHumidityRange[1]}%",
                      "air_humidity",
                    ),
                  ],
                ),
                //====== SOIL & SEASON =======
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    dataCard(
                      AppLocalizations.of(context).translate("ideal_soil"),
                      "${soilHumidityRange[0]}% - ${soilHumidityRange[1]}%",
                      "soil_humidity",
                    ),
                    //========== SPACE ===========
                    SizedBox(
                      height: mediaQuery.height * 0.03,
                    ),
                    SeasonCard(season!),
                  ],
                )
              ],
            ),
            //========== SPACE ===========
            SizedBox(
              height: mediaQuery.height * 0.03,
            ),
            //======= DESCRIPTION ========
            DescriptionAndTipsCard(
                AppLocalizations.of(context).translate("how_to"),
                descriptionWidget),
            //========== SPACE ===========
            SizedBox(
              height: mediaQuery.height * 0.03,
            ),
            //========== TIPS ============
            DescriptionAndTipsCard(
                AppLocalizations.of(context).translate("tips"), tipWidget),
            //========== SPACE ===========
            SizedBox(
              height: mediaQuery.height * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}

/// This class creates a card containing a title and a text following it.
///
/// Parameters:
/// - `title`: A string containing the title.
/// - `bodyWidget`: A text widget containing the text and its formatting.
class DescriptionAndTipsCard extends StatelessWidget {
  final String title;
  final Widget bodyWidget;
  DescriptionAndTipsCard(this.title, this.bodyWidget);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Container(
      width: mediaQuery.width * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //=========== TITLE ===========
          LayoutBuilder(
            builder: (context, constraints) {
              // Get dynamic height of the title
              return Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: mediaQuery.width * 0.06),
                ),
              );
            },
          ),

          //=========== BODY ============
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: mediaQuery.width * 0.75,
                margin: EdgeInsets.only(bottom: mediaQuery.height * 0.01),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color.fromRGBO(255, 255, 255, 0.55),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: mediaQuery.width * 0.02,
                      top: mediaQuery.height * 0.01),
                  child: bodyWidget,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// This class creates a card containing a type representing either the temperature or humidity, a value assigned to the title and an
/// icon displayed on the top left corner of the card.
///
/// Parameters:
/// - `type`: The type of value the card should contain.
/// - `value`: A range of either temperature (in °C) or the percentage (%) of humidity
/// - `icon`: The icon of the type represented.
class dataCard extends StatelessWidget {
  final String type;
  final String value;
  final String icon;
  dataCard(this.type, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    return Container(
      width: mediaQuery.width * 0.4,
      constraints: BoxConstraints(
        minHeight: mediaQuery.width * 0.4,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: theme.colorScheme.secondary),
      child: Stack(
        children: [
          //============= ICON =============
          Positioned(
            left: mediaQuery.width * 0.01,
            top: mediaQuery.height * 0.005,
            child: Image.asset(
              "./assets/images/lexicon/" + icon + ".png",
              width: mediaQuery.width * 0.1,
              height: mediaQuery.width * 0.1,
            ),
          ),
          //============= CONTENT =============
          Padding(
            padding: EdgeInsets.only(
              top: mediaQuery.height * 0.05,
              bottom: mediaQuery.height * 0.02,
              left: mediaQuery.width * 0.02,
              right: mediaQuery.width * 0.02,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //========= TYPE OF DATA =========
                  Flexible(
                    child: Text(
                      type,
                      style: TextStyle(fontSize: mediaQuery.width * 0.05),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  SizedBox(height: mediaQuery.height * 0.01),
                  //============ VALUE =============
                  Container(
                    width: mediaQuery.width * 0.35,
                    constraints: BoxConstraints(
                      minHeight: mediaQuery.height * 0.07,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.55),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(mediaQuery.width * 0.02),
                      child: Center(
                        child: Text(
                          value,
                          style: TextStyle(fontSize: mediaQuery.width * 0.05),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// This class creates a card with a centered icon and text below it.
///
/// Parameters:
/// - `title`: The title to be displayed below the icon (will be translated).
/// - `icon`: The name of the icon asset to be displayed.
class SeasonCard extends StatelessWidget {
  final String title;

  SeasonCard(this.title);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Container(
      width: mediaQuery.width * 0.4,
      constraints: BoxConstraints(
        minHeight: mediaQuery.width * 0.48,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: theme.colorScheme.secondary,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //========== TITLE ===========
          Text(
            AppLocalizations.of(context).translate("when_to_grow"),
            style: TextStyle(fontSize: mediaQuery.width * 0.05),
            textAlign: TextAlign.center,
          ),

          //=========== ICON ===========
          // Centered icon
          Image.asset(
            "assets/images/lexicon/" +
                (title.contains(RegExp(r'[ -]'))
                    ? title.split(RegExp(r'[ -]'))[1]
                    : title) +
                ".png",
            width: mediaQuery.width * 0.15,
            height: mediaQuery.width * 0.15,
          ),
          SizedBox(height: mediaQuery.height * 0.005),
          // Text below icon
          Container(
            width: mediaQuery.width * 0.35,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.55),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(
              vertical: mediaQuery.height * 0.001,
              horizontal: mediaQuery.width * 0.02,
            ),
            child: Text(
              AppLocalizations.of(context).translate(title),
              style: TextStyle(fontSize: mediaQuery.width * 0.05),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
