//-------------------- FLUTTER IMPORT --------------------
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:olaf/lexica/lexica_loader.dart';
//--------------------- LEXICA LIST ----------------------
import './lexica_list.dart';
import './lexica_desc.dart';

//--------------------- LEXICA STATE ---------------------
class LexicaPage extends StatefulWidget {
  const LexicaPage({Key? key}) : super(key: key);

  @override
  _LexicaTabState createState() => _LexicaTabState();
}

//--------------------- LEXICA tab --------------------
class _LexicaTabState extends State<LexicaPage> {
  int currentTab = 0; // The current tab selected
  int choice = 0;
  dynamic selected;

  /// When a button is tapped it changes the page
  void changeState(int newIndex, dynamic plantOrDisease) {
    setState(() {
      currentTab = newIndex;
      selected = plantOrDisease;
    });
  }

  Disease shownDisease = Disease(
      name: "", image: "", icon: "", description: "", prevent: "", cure: "");
  String shownImage = "";

  ///  When one of the disease linked to a plant is tapped, show the disease's description with a corresponding image
  void plantToDisease(Disease disease, String image) {
    setState(() {
      currentTab = 3;
      shownDisease = disease;
      shownImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 20);

    /* Every states of the lexica:
   - The choice between plants and diseases
   - The list of plants/diseases
   - The description of a plant/disease
   - The description of a disease with the image of the plant selected in the third state
   */
    List<Widget> states = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // Plant & Disease buttons
          children: [
            LexicaChoice("Plants", () {
              setState(() {
                currentTab = 1;
                choice = 1;
              });
            }),

            // An empty space to separate the two buttons
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            LexicaChoice("Diseases", () {
              setState(() {
                currentTab = 1;
                choice = 2;
              });
            }),
          ],
        ),
      ),

      // Plants/Disease list
      LexicaList(choice, changeState: changeState),

      // Plant/Disease description
      LexicaDescription(selected, plantToDisease: plantToDisease),

      DescriptionWidget(
        shownDisease.name,
        shownImage,
        "What is this disease",
        shownDisease.description,
        "how to prevent it",
        [shownDisease.prevent],
        moreTitle: "How to cure it",
        moreWidget: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
            child: Text(
              shownDisease.cure,
              textAlign: TextAlign.center,
              style: style.copyWith(fontSize: 18),
            )),
      )
    ];

    return states[currentTab];
  }
}

class LexicaChoice extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  LexicaChoice(this.text, this.onPressed);
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
              child: AutoSizeText(
                text,
                style: style,
                maxFontSize: 25,
                minFontSize: 20,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
