import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/lexica/lexica_page.dart';
import 'package:olaf/utils.dart';

//--------------------- LEXICA LIST ----------------------
class LexicaList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> firstColumn = [];
    List<Widget> secondColumn = [];
    final mediaQuery = MediaQuery.sizeOf(context);

    switch (ref.read(choice)) {
      case 1: // if plants have been selected
        for (var i = 0;
            i < cacheData.getInstance().lexica.plants.length;
            i += 2) {
          final currentPlant = cacheData.getInstance().lexica.plants[i];
          firstColumn.add(LexiCard(
              currentPlant.name, currentPlant.image, mediaQuery.width * 0.05));
        }
        for (var i = 1;
            i < cacheData.getInstance().lexica.plants.length;
            i += 2) {
          final currentPlant = cacheData.getInstance().lexica.plants[i];
          secondColumn.add(LexiCard(
              currentPlant.name, currentPlant.image, mediaQuery.width * 0.05));
        }
        break;
      case 2: // if diseases have been selected
        for (var i = 0;
            i < cacheData.getInstance().lexica.diseases.length;
            i += 2) {
          final currentDisease = cacheData.getInstance().lexica.diseases[i];
          firstColumn.add(LexiCard(currentDisease.name, currentDisease.image,
              mediaQuery.width * 0.04));
        }
        for (var i = 1;
            i < cacheData.getInstance().lexica.diseases.length;
            i += 2) {
          final currentDisease = cacheData.getInstance().lexica.diseases[i];
          secondColumn.add(LexiCard(currentDisease.name, currentDisease.image,
              mediaQuery.width * 0.04));
        }

        break;
      default:
        break;
    }
    Widget row =
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: firstColumn,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: secondColumn,
      )
    ]);
    return Center(
        child: SingleChildScrollView(
      child: IntrinsicHeight(
        child: row,
      ),
    ));
  }
}

//------------------------- CARD -------------------------
class LexiCard extends StatelessWidget {
  final String text;
  final String image;
  final double fontSize;
  LexiCard(this.text, this.image, this.fontSize);
  @override
  Widget build(BuildContext context) {
    return CardWidget(
        text,
        Image.network(
          image,
          fit: BoxFit.cover,
        ),
        fontSize);
  }
}
