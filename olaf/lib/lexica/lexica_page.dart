//-------------------- FLUTTER IMPORT --------------------
import 'package:flutter/material.dart';
import 'package:olaf/app_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/lexica/lexica_functions.dart';
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
    var mediaQuery = MediaQuery.sizeOf(context);
    /* Every states of the lexica:
   - The choice between plants and diseases
   - The list of plants/diseases
   - The description of a plant/disease
   - The description of a disease with the image of the plant selected in the third state
   */
    List<Widget> states = [
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          // Plant & Disease buttons
          children: [
            LexicaChoice(AppLocalizations.of(context).translate('plants'), () {
              setState(() {
                ref.read(tab.notifier).state = 1;
                ref.read(choice.notifier).state = 1;
              });
            }, [
              "./assets/images/lexicon/tomato.jpg",
              "./assets/images/lexicon/strawberry.jpg",
              "./assets/images/lexicon/squash.jpg",
              "./assets/images/lexicon/basil.png"
            ]),

            // An empty space to separate the two buttons
            SizedBox(
              height: mediaQuery.height * 0.1,
            ),
            LexicaChoice(AppLocalizations.of(context).translate('diseases'),
                () {
              setState(() {
                ref.read(tab.notifier).state = 1;
                ref.read(choice.notifier).state = 2;
              });
            }, [
              "./assets/images/lexicon/tomato_late_blight.png",
              "./assets/images/lexicon/strawberry_mildew.jpg",
              "./assets/images/lexicon/squash_infected.jpg",
              "./assets/images/lexicon/basil_infected.jpg"
            ]),
          ],
        ),
      ),
      // Plants/Disease list
      LexicaList(),

      // Plant/Disease description
      LexicaDescription(),

      
    ];

    return Scaffold(body: states[currentTab]);
  }
}
