//------------------------ FLUTTER ------------------------
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
//------------------------- UTILS -------------------------
import 'package:olaf/classes.dart';
import 'package:olaf/utils.dart';

//------------------------ GARDENS ------------------------
class Gardens extends ConsumerStatefulWidget {
  @override
  _GardensState createState() => _GardensState();
}

//--------------------- GARDENS STATE ---------------------
class _GardensState extends ConsumerState<Gardens>
    with AutomaticKeepAliveClientMixin {
  List<Plant> plantsList = cacheData.getInstance().savedPlants;
  late User user;
  final allImages = cacheData.getInstance().images;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    return Center(
        child: Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(children: [
              for (int i = 0; i < 10; i++)
                for (int i = 0; i < allImages.length; i += 2)
                  CardWidget(
                      allImages[i].name.substring(0, 10) +
                          "\n" +
                          allImages[i].result.split(" ").first +
                          "\n" +
                          allImages[i].result.split(" ").sublist(1).join(" "),
                      Image(
                        image: MemoryImage(
                          base64Decode(allImages[i].image),
                        ),
                        fit: BoxFit.fill,
                      ),
                      mediaQuery.width * 0.025),
            ]),
            Column(
              children: [
                for (int i = 0; i < 10; i++)
                  for (int i = 1; i < allImages.length; i += 2)
                    CardWidget(
                        allImages[i].name.substring(0, 10) +
                            "\n" +
                            allImages[i].result.split(" ").first +
                            "\n" +
                            allImages[i].result.split(" ").sublist(1).join(" "),
                        Image(
                          image: MemoryImage(
                            base64Decode(allImages[i].image),
                          ),
                          fit: BoxFit.fill,
                        ),
                        mediaQuery.width * 0.025)
              ],
            )
          ],
        )
      ],
    ));
  }
}
