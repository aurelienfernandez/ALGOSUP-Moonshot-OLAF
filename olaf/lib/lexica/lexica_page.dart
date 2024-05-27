//-------------------- FLUTTER IMPORT --------------------
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:olaf/lexica/lexica_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//--------------------- LEXICA LIST ----------------------
import './lexica_list.dart';
import './lexica_desc.dart';

//----------------------- PROVIDERS ----------------------
final tab = StateProvider<int>((ref) => 0);
final choice = StateProvider<int>((ref) => 0);
final PlantorDisease = StateProvider<dynamic>((ref) => null);
final infectedPlantImage = StateProvider<String>((ref) => "");

//--------------------- LEXICA STATE ---------------------
class LexicaPage extends ConsumerStatefulWidget {
  const LexicaPage({super.key});

  @override
  _LexicaTabState createState() => _LexicaTabState();
}

//--------------------- LEXICA TAB --------------------
class _LexicaTabState extends ConsumerState<LexicaPage> {
//----------------------- PROVIDERS ----------------------

  @override
  Widget build(BuildContext context) {
    int currentTab = ref.watch(tab);

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
                ref.read(tab.notifier).state = 1;
                ref.read(choice.notifier).state = 1;
              });
            }),

            // An empty space to separate the two buttons
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            LexicaChoice("Diseases", () {
              setState(() {
                ref.read(tab.notifier).state = 1;
                ref.read(choice.notifier).state = 2;
              });
            }),
          ],
        ),
      ),
      // Plants/Disease list
      LexicaList(),

      // Plant/Disease description
      LexicaDescription(),

      DescriptionWidget(
        ref.read(PlantorDisease)?.name ?? "",
        ref.read(infectedPlantImage),
        "What is this disease",
        ref.read(PlantorDisease).runtimeType==Disease? ref.read(PlantorDisease).description : "",
        "how to prevent it",
        [
        ref.read(PlantorDisease).runtimeType==Disease? ref.read(PlantorDisease).prevent : "",
        ],
        moreTitle: "How to cure it",
        moreWidget: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
            child: Text(
        ref.read(PlantorDisease).runtimeType==Disease? ref.read(PlantorDisease).cure : "",
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
