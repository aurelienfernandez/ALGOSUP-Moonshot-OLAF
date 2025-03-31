import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/plants/plant_data_widgets.dart';
//--------------------- PLANT STATUS --------------------

class PlantStatus extends StatelessWidget {
  final Plant plant;

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
    
    Text createStatusText(String message, Color color) {
      return Text(
      message,
      style: GoogleFonts.itim(
        fontSize: mediaQuery.width * 0.1,
        color: color,
      ),
      textAlign: TextAlign.center,
      );
    }
    
    final Set<Text> titleList = {
      createStatusText("Everything is fine", goodColor),
      createStatusText("The temperature is too high", highTempColor),
      createStatusText("The temperature is too low", lowTempColor),
      createStatusText("Low soil humidity", lowHumidityColor),
      createStatusText("High soil humidity", highHumidityColor),
      createStatusText("Low air humidity", lowHumidityColor),
      createStatusText("High air humidity", highHumidityColor),
    };
    Widget title;
    final lexicaPlant = cacheData.getInstance().lexica.plants.firstWhere(
      (p) => p.name == plant.name,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DashboardDataCard(
                "temperature", plant.temperature.first.toString(), 0),
            DashboardDataCard(
                "soil humidity", plant.soilHumidity.first.toString(), 1),
          ],
        ),
        //========== SPACE ===========
        SizedBox(
          height: mediaQuery.height * 0.03,
        ),
        //============ AIR ===========
        DashboardDataCard(
            "air humidity", plant.airHumidity.first.toString(), 2),
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
