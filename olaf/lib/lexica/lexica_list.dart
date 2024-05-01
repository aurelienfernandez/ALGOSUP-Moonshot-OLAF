import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:olaf/lexica/lexica_loader.dart';

//--------------------- LEXICA LIST ----------------------
class LexicaList extends StatelessWidget {
  final int choice;
  LexicaList(this.choice);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> Cards = [];

    switch (choice) {
      case 1:
        for (var i = 0; i < Lexica.getInstance().plants.length; i++) {
          Cards.add(
            Card(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.height * 0.05,
              ),
              color: theme.primaryColor,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.012,
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: LexiCard(Lexica.getInstance().plants[i].name,
                      Lexica.getInstance().plants[i].image)),
            ),
          );
        }
      case 2:
        for (var i = 0; i < Lexica.getInstance().diseases.length; i++) {
          Cards.add(
            Card(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.height * 0.05,
              ),
              color: theme.primaryColor,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.012,
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: LexiCard(Lexica.getInstance().diseases[i].name,
                      Lexica.getInstance().diseases[i].icon)),
            ),
          );
          // Perform actions for diseases data
        }
      default:
        break;
    }
    return Column(
      children: Cards,
    );
  }
}

//-------------------------  CARD -------------------------
class LexiCard extends StatelessWidget {
  final String text;
  final String imagePath;
  LexiCard(this.text, this.imagePath);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontSize: 25.0,
        backgroundColor: theme.colorScheme.primary);

    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Stack(clipBehavior: Clip.none, fit: StackFit.loose, children: [
          //---------- IMAGE ----------
          Positioned(
            left: -MediaQuery.of(context).size.width * 0.24,
            top: -MediaQuery.of(context).size.height * 0.018,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                color: const Color(0xff7c94b6),
                image: DecorationImage(
                  image: NetworkImage(
                    imagePath,
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 4.0,
                ),
              ),
            ),
          ),
          //---------- NAME ----------
          Positioned(
            top: 8,
            left: -15,
            width: 150,
            child: AutoSizeText(
              text, style: style, maxLines: 1, maxFontSize: 25.0,
              minFontSize: 20,
              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
            ),
          ),
        ]));
  }
}
