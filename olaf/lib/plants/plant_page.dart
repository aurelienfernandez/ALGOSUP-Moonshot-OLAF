//------------------- FLUTTER IMPORTS -------------------
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:olaf/app_localization.dart';

//-------------------- CUSTOM IMPORTS -------------------
import 'package:olaf/classes.dart';
import 'package:olaf/plants/plant_data.dart';

//--------------------- PROVIDERS ----------------------
final plantsIndex = StateProvider<int>((ref) => 0);
final GraphChoice = StateProvider<int>((ref) => 0);

//--------------------- PLANT STATE ---------------------
class PlantPage extends ConsumerStatefulWidget {
  const PlantPage({super.key});

  @override
  _PlantTabState createState() => _PlantTabState();
}

//---------------------- PLANT TAB ----------------------
class _PlantTabState extends ConsumerState<PlantPage> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);

    Widget body;

    if (ref.watch(plantsIndex) != 0) {
      body = PlantStatus(
          cacheData.getInstance().savedPlants[ref.read(plantsIndex) - 1]);
    } else {
      final savedPlants = cacheData.getInstance().savedPlants;
      if (savedPlants.isEmpty) {
        body = Center(
          child: Card(
            margin: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: MediaQuery.of(context).size.width * 0.15,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                // Replace with your localization method if different
                AppLocalizations.of(context).translate("no_plant_pots_saved"),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      } else {
        body = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //========== SPACE ===========
            SizedBox(
              height: mediaQuery.height * 0.03,
            ),
            ListView.builder(
              itemCount: savedPlants.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var plant = savedPlants[index];
                return Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: MediaQuery.of(context).size.width * 0.15,
                  ),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade500,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      ref.read(GraphChoice.notifier).state = 0;
                      ref.read(plantsIndex.notifier).state = index + 1;
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.memory(
                                  // Decode the base64 string to bytes
                                  base64Decode(plant.imageBase64),
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  height: MediaQuery.of(context).size.width * 0.2,
                                  fit: BoxFit.cover, errorBuilder:
                                      (BuildContext context, Object exception,
                                          StackTrace? stackTrace) {
                                return const Icon(Icons.error);
                              }),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.05,
                        ),
                        Expanded(
                          child: AutoSizeText(
                            plant.potName,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.06,
                              color: Colors.black,
                            ),
                            minFontSize: 12,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(child: body),
      ),
    );
  }
}
