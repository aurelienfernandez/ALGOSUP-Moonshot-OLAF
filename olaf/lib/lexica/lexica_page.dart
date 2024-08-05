//-------------------- FLUTTER IMPORT --------------------
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:olaf/app_localization.dart';
import 'package:olaf/lexica/lexica_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//--------------------- LEXICA LIST ----------------------
import './lexica_list.dart';
import './lexica_desc.dart';

//----------------------- PROVIDERS ----------------------
final tab = StateProvider<int>((ref) => 0);
final choice = StateProvider<int>((ref) => 0);
final PlantorDisease = StateProvider<dynamic>((ref) => null);
final DiseaseDescription = StateProvider<dynamic>((ref) => null);
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
            LexicaChoice(AppLocalizations.of(context).translate('plants'), () {
              setState(() {
                ref.read(tab.notifier).state = 1;
                ref.read(choice.notifier).state = 1;
              });
            }),

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
            }),
          ],
        ),
      ),
      // Plants/Disease list
      LexicaList(),

      // Plant/Disease description
      LexicaDescription(),

      DescriptionWidget(
        ref.read(DiseaseDescription)?.name ?? "",
        ref.read(infectedPlantImage),
        AppLocalizations.of(context).translate('what_is_it'),
        ref.read(DiseaseDescription).runtimeType == Disease
            ? ref.read(DiseaseDescription).description
            : "",
        AppLocalizations.of(context).translate('prevent'),
        [
          ref.read(DiseaseDescription).runtimeType == Disease
              ? ref.read(DiseaseDescription).prevent
              : "",
        ],
        moreTitle: AppLocalizations.of(context).translate('cure'),
        moreWidget: Padding(
            padding: EdgeInsets.all(mediaQuery.height * 0.02),
            child: Text(
              ref.read(DiseaseDescription).runtimeType == Disease
                  ? ref.read(DiseaseDescription).cure
                  : "",
              textAlign: TextAlign.center,
              style: style.copyWith(fontSize: 18),
            )),
      )
    ];

    return Scaffold(
        appBar: ref.watch(tab) != 0
            ? AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: mediaQuery.width * 0.1,
                  ), // Icon for the back arrow
                  onPressed: () {
                    ref.read(tab.notifier).state--;
                  },
                ))
            : null,
        body: states[currentTab]);
  }
}

class LexicaChoice extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  LexicaChoice(this.text, this.onPressed);
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);
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
          height: mediaQuery.height * 0.1,
          width: mediaQuery.width * 0.8,
          child: Padding(
            padding: EdgeInsets.all(2),
            child: TextButton(
              onPressed: onPressed,
              child: AutoSizeText(
                text,
                style: style,
                maxFontSize: 20,
                minFontSize: 15,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
