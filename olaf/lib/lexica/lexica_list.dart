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
          firstColumn.add(LexiCard(currentPlant, mediaQuery.width * 0.05, ref));
        }
        for (var i = 1;
            i < cacheData.getInstance().lexica.plants.length;
            i += 2) {
          final currentPlant = cacheData.getInstance().lexica.plants[i];
          secondColumn
              .add(LexiCard(currentPlant, mediaQuery.width * 0.05, ref));
        }
        break;
      case 2: // if diseases have been selected
        for (var i = 0;
            i < cacheData.getInstance().lexica.diseases.length;
            i += 2) {
          final currentDisease = cacheData.getInstance().lexica.diseases[i];
          firstColumn
              .add(LexiCard(currentDisease, mediaQuery.width * 0.04, ref));
        }
        for (var i = 1;
            i < cacheData.getInstance().lexica.diseases.length;
            i += 2) {
          final currentDisease = cacheData.getInstance().lexica.diseases[i];
          secondColumn
              .add(LexiCard(currentDisease, mediaQuery.width * 0.04, ref));
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
  final dynamic element; // either a plant or a disease
  final double fontSize;
  final WidgetRef ref;
  LexiCard(this.element, this.fontSize, this.ref);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        ref.read(tab.notifier).state = 2,
        ref.read(PlantorDisease.notifier).state = element
      },
      child: CardWidget(
          element.name,
          Image.network(
            element.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                ),
              );
            },
          ),
          fontSize),
    );
  }
}
