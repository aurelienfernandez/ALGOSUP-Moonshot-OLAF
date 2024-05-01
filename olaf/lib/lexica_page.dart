import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:olaf/lexica_loader.dart';

//--------------------- LEXICA STATE ---------------------
class LexicaPage extends StatefulWidget {
  const LexicaPage({Key? key}) : super(key: key);

  @override
  _LexicaChoiceState createState() => _LexicaChoiceState();
}

//--------------------- LEXICA CHOICE --------------------
class _LexicaChoiceState extends State<LexicaPage> {
  int currentIndex = 0;
  int choice = 0;

  void reset() {
    setState(() {
      print("object");
      currentIndex = 0;
      choice = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> states = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Plant & Disease buttons
            LexicaChoice("Plants", 1, () {
              setState(() {
                currentIndex = 1;
                choice = 1;
              });
            }),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ), // Create a space between the two buttons
            LexicaChoice("Diseases", 1, () {
              setState(() {
                currentIndex = 1;
                choice = 2;
              });
            }),
          ],
        ),
      ),

      // Plants/Disease list
      LexicaList(choice),
    ];

    return states[currentIndex];
  }
}

/*
Class which contains
*/

class LexicaChoice extends StatelessWidget {
  final String text;
  final int result;
  final VoidCallback onPressed;

  LexicaChoice(this.text, this.result, this.onPressed);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 30.0,
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: TextButton(
              onPressed: onPressed,
              child: Text(
                text,
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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

//----------------------- PLANT CARD ----------------------
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

//--------------------- LEXICA PLANT ---------------------
class _LexicaPlantState extends State<LexicaPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Plant"));
  }
}

//-------------------- LEXICA DISEASE --------------------
class _LexicaDiseaseState extends State<LexicaPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Disease"));
  }
}
