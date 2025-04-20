import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/lexica/lexica_page.dart';
import 'package:olaf/lexica/description_pages/plant_description.dart';
import 'package:olaf/lexica/description_pages/disease_description.dart';

//------------------ LEXICA DESCRIPTION ------------------
class LexicaDescription extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget description;
    switch (ref.read(PlantorDisease).runtimeType) {
      case LexPlant: // If the current element is a plant

        description = PlantDescription(
          ref.read(PlantorDisease).name,
          ref.read(PlantorDisease).image,
          ref.read(PlantorDisease).howTo,
          ref.read(PlantorDisease).tips,
          ref.read(PlantorDisease).temperatureRange,
          ref.read(PlantorDisease).soilHumidityRange,
          ref.read(PlantorDisease).airHumidityRange,
          ref.read(PlantorDisease).season,
        );
        break;

      case Disease: // If the current element is a disease

        description = DiseaseDescription(
          ref.read(PlantorDisease).name,
          ref.read(PlantorDisease).image,
          ref.read(PlantorDisease).description,
          ref.read(PlantorDisease).prevent,
          ref.read(PlantorDisease).cure,
        );
        break;

      default:
        throw ("Error: invalid type");
    }

    return description;
  }
}
