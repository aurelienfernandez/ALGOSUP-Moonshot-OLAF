import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/plants/plant_data_widgets.dart';
import 'package:olaf/app_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';

//--------------------- PLANT STATUS --------------------

class PlantStatus extends StatelessWidget {
  final SavedPlant plant;

  PlantStatus(this.plant);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    
    // Define status colors
    final Color goodColor = Color.fromRGBO(116, 193, 79, 1);
    final Color highTempColor = Color.fromRGBO(237, 45, 45, 1);
    final Color lowTempColor = Color.fromRGBO(66, 148, 255, 1);
    final Color lowHumidityColor = Color.fromRGBO(222, 125, 7, 1);
    final Color highHumidityColor = Color.fromRGBO(92, 69, 246, 1);
    
    Text createStatusText(String translationKey, Color color) {
      return Text(
      AppLocalizations.of(context).translate(translationKey),
      style: GoogleFonts.itim(
        fontSize: mediaQuery.width * 0.11,
        color: color,
      ),
      textAlign: TextAlign.center,
      );
    }
    
    final Set<Text> titleList = {
      createStatusText("everything_fine", goodColor),
      createStatusText("temperature_too_high", highTempColor),
      createStatusText("temperature_too_low", lowTempColor),
      createStatusText("soil_humidity_low", lowHumidityColor),
      createStatusText("soil_humidity_high", highHumidityColor),
      createStatusText("air_humidity_low", lowHumidityColor),
      createStatusText("air_humidity_high", highHumidityColor),
    };
    Widget title;
    final lexicaPlant = cacheData.getInstance().lexica.plants.firstWhere(
      (p) => p.name == plant.plantName,
      orElse: () => cacheData.getInstance().lexica.plants.first,
    );
    if (plant.temperature.first > lexicaPlant.temperatureRange[1]) {
      title = titleList.elementAt(1);
    } else if (plant.temperature.first < lexicaPlant.temperatureRange[0]) {
      title = titleList.elementAt(2);
    } else if (plant.soilHumidity.first < lexicaPlant.soilHumidityRange[0]) {
      title = titleList.elementAt(3);
    } else if (plant.soilHumidity.first > lexicaPlant.soilHumidityRange[1]) {
      title = titleList.elementAt(4);
    } else if (plant.airHumidity.first < lexicaPlant.airHumidityRange[0]) {
      title = titleList.elementAt(5);
    } else if (plant.airHumidity.first > lexicaPlant.airHumidityRange[1]) {
      title = titleList.elementAt(6);
    } else {
      title = titleList.elementAt(0);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        //========== SPACE ===========
        SizedBox(
          height: mediaQuery.height * 0.03,
        ),
        //========== TITLE ===========
        title,
        //========== SPACE ===========
        SizedBox(
          height: mediaQuery.height * 0.03,
        ),
        //========== DATA ===========
        Column(
          children: [
            // Plant name
            AutoSizeText(
              plant.plantName,
              style: GoogleFonts.itim(
                fontSize: mediaQuery.width * 0.11,
                color: Colors.black,
              ),
              minFontSize: 16,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DashboardDataCard(
                "temperature", plant.temperature.last.toString(), 0),
            DashboardDataCard(
                "soil humidity", plant.soilHumidity.last.toString(), 1),
          ],
        ),
        //========== SPACE ===========
        SizedBox(
          height: mediaQuery.height * 0.03,
        ),
        //============ AIR & IMAGE ROW ===========
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DashboardDataCard(
              "air humidity",
              plant.airHumidity.last.toString(),
              2,
            ),
            // Use the new overlay-enabled image card
            ImageDataCard(base64Image: plant.imageBase64),
          ],
        ),
        //========== SPACE ===========
        SizedBox(
          height: mediaQuery.height * 0.03,
        ),
        //========== GRAPH ===========
        DataGraph(
          plant: plant,
        ),
        //==== DISCONNECT BUTTON =====
        disconnectButton(plant: plant),
        //========== SPACE ===========
        SizedBox(
          height: mediaQuery.height * 0.03,
        ),
      ],
    );
  }
}
