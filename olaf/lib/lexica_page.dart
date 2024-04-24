import 'package:flutter/material.dart';

//--------------------- LEXICA STATE ---------------------
class LexicaScreen extends StatefulWidget {
  @override
  _LexicaChoiceState createState() => _LexicaChoiceState();
}

//--------------------- LEXICA CHOICE --------------------
class _LexicaChoiceState extends State<LexicaScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> states = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LexicaChoice("Plants", 1, () {
              setState(() {
                currentIndex = 1;
              });
            }),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ), // Create a space between the two buttons
            LexicaChoice("Diseases", 1, () {
              setState(() {
                currentIndex = 1;
              });
            }),
          ],
        ),
      ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LexicaChoice("test2", 0, () {
              setState(() {
                currentIndex = 0;
              });
            }),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ), // Create a space between the two buttons
            LexicaChoice("test3", 0, () {
              setState(() {
                currentIndex = 0;
              });
            }),
          ],
        ),
      ),
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

//--------------------- LEXICA LIST ----------------------
class _LexicaListState extends State<LexicaScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("List"));
  }
}

//--------------------- LEXICA PLANT ---------------------
class _LexicaPlantState extends State<LexicaScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Plant"));
  }
}

//-------------------- LEXICA DISEASE --------------------
class _LexicaDiseaseState extends State<LexicaScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Disease"));
  }
}
