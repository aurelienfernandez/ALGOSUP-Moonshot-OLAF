import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:olaf/lexica/lexica_loader.dart';
import 'package:marquee/marquee.dart';

//--------------------- LEXICA LIST ----------------------
class LexicaList extends StatelessWidget {
  final int choice;
  LexicaList(this.choice);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> Cards = [];

    switch (choice) {
      case 1: // if plants have been selected
        for (var i = 0; i < Lexica.getInstance().plants.length; i++) {
          Cards.add(
            Card(
              // the position on the screen
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.08,
                left: MediaQuery.of(context).size.height * 0.15,
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
      case 2: // if diseases have been selected
        for (var i = 0; i < Lexica.getInstance().diseases.length; i++) {
          Cards.add(
            Card(
              color: theme.primaryColor,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
              ),
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.012,
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: LexiCard(Lexica.getInstance().diseases[i].name,
                      "assets/icon.png")),
            ),
          );
          // Perform actions for diseases data
        }
      default:
        break;
    }
    if (Cards.isNotEmpty) {
      Cards.last = Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
        child: Cards.last,
      );
    }
    return Scaffold(
        body: SingleChildScrollView(child: Column(children: Cards)));
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
    if (textWidth > MediaQuery.of(context).size.width * 0.6) {
      // Use Marquee if text exceeds available width
      textWidget = Marquee(
        text: text,
        style: style,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: MediaQuery.of(context).size.width * 0.3,
        velocity: 30.0,
        pauseAfterRound: Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      );
    } else {
      // Use AutoSizeText if text fits within available width
      textWidget = AutoSizeText(
        textAlign: TextAlign.start,
        text,
        style: style,
        maxLines: 1,
        maxFontSize: 30.0,
        minFontSize: 25,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Center(
        child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Stack(clipBehavior: Clip.none, fit: StackFit.loose, children: [
        //---------- IMAGE ----------
        Positioned(
          left: -MediaQuery.of(context).size.width * 0.2,
          top: -MediaQuery.of(context).size.height * 0.02,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
              ),
            ),
          ),
        ),
        //---------- NAME ----------
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: textWidget,
          ),
        )
      ]),
    ));
  }
}
