import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/lexica/lexica_loader.dart';
import 'package:marquee/marquee.dart';
import 'package:olaf/lexica/lexica_page.dart';

//--------------------- LEXICA LIST ----------------------
class LexicaList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    var mediaQuery = MediaQuery.sizeOf(context);
    List<Widget> cards = [];

    switch (ref.read(choice)) {
      case 1: // if plants have been selected
        for (var i = 0; i < Lexica.getInstance().plants.length; i++) {
          // An image of the plant in a rounded container
          final Widget plantImage = Positioned(
            left: -mediaQuery.width * 0.2,
            top: -mediaQuery.height * 0.015,
            child: Container(
              width: mediaQuery.width * 0.2,
              height: mediaQuery.width * 0.2,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(Lexica.getInstance().plants[i].image),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 4.0,
                ),
              ),
            ),
          );

          cards.add(
            Card(
              // Position on the screen
              margin: EdgeInsets.only(
                top: mediaQuery.height * 0.08,
                left: mediaQuery.width * 0.25,
                right: mediaQuery.width * 0.15,
              ),
              color: theme.primaryColor,
              child: InkWell(
                onTap: () {
                  ref.read(tab.notifier).state = 2;
                  ref.read(PlantorDisease.notifier).state =
                      Lexica.getInstance().plants[i];
                },
                // Optional: custom splash color
                splashColor: Colors.white.withOpacity(0.5),
                // Constrain the splash effect within the card by using a clipping behavior
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: mediaQuery.height * 0.012,
                      horizontal: mediaQuery.width * 0.1),
                  child: LexiCard(
                    Lexica.getInstance().plants[i].name,
                    plantImage,
                  ),
                ),
              ),
            ),
          );
        }
      case 2: // if diseases have been selected
        for (var i = 0; i < Lexica.getInstance().diseases.length; i++) {
          // The icon of the disease displayed at the right of the name
          final Widget diseaseIcon = Positioned(
            left: -mediaQuery.width * 0.1,
            top: -mediaQuery.height * 0.02,
            child: Container(
              width: mediaQuery.width * 0.2,
              height: mediaQuery.width * 0.2,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(Lexica.getInstance().diseases[i].icon),
                ),
              ),
            ),
          );

          cards.add(
            Card(
              color: theme.primaryColor,
              margin: EdgeInsets.only(
                top: mediaQuery.height * 0.05,
                left: mediaQuery.width * 0.2,
                right: mediaQuery.width * 0.15,
              ),
              child: InkWell(
                onTap: () {
                  ref.read(tab.notifier).state = 2;
                  ref.read(PlantorDisease.notifier).state =
                      Lexica.getInstance().diseases[i];
                },
                splashColor: Colors.white.withOpacity(0.5),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: mediaQuery.height * 0.012),
                  child: LexiCard(
                      Lexica.getInstance().diseases[i].name, diseaseIcon),
                ),
              ),
            ),
          );
        }
      default:
        break;
    }
    if (cards.isNotEmpty) {
      cards.last = Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.height * 0.02),
        child: cards.last,
      );
    }
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Column(children: cards)]));
  }
}

//------------------------- CARD -------------------------
class LexiCard extends StatelessWidget {
  final String text;
  final Widget icon;
  LexiCard(this.text, this.icon);
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);

    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 25);

    // Create text painter
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // From text painter get the width of the text
    final textWidth = textPainter.width;

    Widget textWidget;
    if (textWidth > mediaQuery.width * 0.4) {
      textWidget = Align(
          alignment:
              Alignment.centerRight, // Aligns the Marquee widget to the right
          child: SizedBox(
              width: mediaQuery.width * 0.4,
              child:
                  // Use Marquee if text exceeds available width
                  Marquee(
                text: text,
                style: style,
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: mediaQuery.width * 0.3,
                velocity: 30.0,
                pauseAfterRound: Duration(seconds: 1),
                startPadding: 5.0,
                accelerationDuration: Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              )));
    } else {
      // Use AutoSizeText if text fits within available width
      textWidget = Positioned.fill(
          child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                textAlign: TextAlign.center,
                text,
                style: style,
                maxLines: 1,
                maxFontSize: 20,
                minFontSize: 10,
                overflow: TextOverflow.ellipsis,
              )));
    }

    return Center(
        child: SizedBox(
            height: mediaQuery.height * 0.06,
            width: mediaQuery.width * 0.5,
            child:
                Stack(clipBehavior: Clip.none, fit: StackFit.loose, children: [
              //---------- IMAGE ----------
              icon,
              //---------- NAME ----------
              textWidget
            ])));
  }
}
