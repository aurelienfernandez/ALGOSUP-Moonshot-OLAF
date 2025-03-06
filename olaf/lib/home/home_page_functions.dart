//------------------------ FLUTTER ------------------------
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
//------------------------- UTILS -------------------------
import 'package:olaf/classes.dart';

//------------------------ GARDENS ------------------------
class Gardens extends ConsumerStatefulWidget {
  @override
  _GardensState createState() => _GardensState();
}

//--------------------- GARDENS STATE ---------------------
class _GardensState extends ConsumerState<Gardens> {
  List<Plant> plantsList = cacheData.getInstance().savedPlants;
  late User user;
  final allImages = cacheData.getInstance().images;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(children: [
              for (int i = 0; i < 10; i ++)
              for (int i = 0; i < allImages.length; i += 2)
                PlantCard([allImages[i].name, allImages[i].result],
                    allImages[i].image)
            ]),
            Column(
              children: [
              for (int i = 0; i < 10; i ++)
                for (int i = 1; i < allImages.length; i += 2)
                  PlantCard([allImages[i].name, allImages[i].result],
                      allImages[i].image)
              ],
            )
          ],
        )
      ],
    ));
  }
}

//----------------------- PLANT CARD ----------------------
class PlantCard extends StatelessWidget {
  final List<String> text;
  final String image;
  PlantCard(this.text, this.image);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);

    return SizedBox(
      width: mediaQuery.width * 0.4,
      height: mediaQuery.height * 0.25,
      child: Padding(
        padding: EdgeInsets.only(top: mediaQuery.height * 0.02),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: mediaQuery.width * 0.3, // Match the Image width
                  height: mediaQuery.width * 0.3, // Match the Image height
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 4), // Add border
                    borderRadius:
                        BorderRadius.circular(10), // Optional rounded corners
                  ),
                  child: ClipRRect(
                    // Ensures border-radius applies correctly
                    borderRadius: BorderRadius.circular(5),
                    child: Image(
                      fit: BoxFit.fill,
                      image: MemoryImage(base64Decode(image)),
                    ),
                  ),
                ),
                SizedBox(
                  width: mediaQuery.width * 0.35,
                  height: mediaQuery.height * 0.05,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0.57),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Center(
                      child: Text(
                        text[0].substring(0, 10) +
                            "\n" +
                            text[1].split(" ").first +
                            "\n" +
                            text[1].substring(text[1].indexOf(" ") + 1),
                        style: TextStyle(fontSize: mediaQuery.width * 0.025),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
