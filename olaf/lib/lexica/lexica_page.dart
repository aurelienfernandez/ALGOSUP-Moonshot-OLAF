//-------------------- FLUTTER IMPORT --------------------
import 'package:flutter/material.dart';
//--------------------- LEXICA LIST ----------------------
import './lexica_list.dart';
import './lexica_desc.dart';

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

            // Create a space between the two buttons
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),

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
