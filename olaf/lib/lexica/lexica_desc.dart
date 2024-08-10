import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:olaf/app_localization.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/lexica/lexica_page.dart';

//------------------ LEXICA DESCRIPTION ------------------
class LexicaDescription extends ConsumerWidget {
  LexicaDescription();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 20);

    Widget description;
    switch (ref.read(PlantorDisease).runtimeType) {
      case const (LexPlant): // If the current element is a plant

        Widget relatedDiseases = SizedBox(
          height: mediaQuery.height *
              0.14 *
              ref
                  .read(PlantorDisease)
                  .diseases
                  .length, // Set a fixed height to avoid crash
          child: ListView.builder(
            itemCount: ref.read(PlantorDisease).diseases.length,
            itemBuilder: (BuildContext context, int index) {
              var diseaseName = ref.read(PlantorDisease).diseases[index].name;
              var disease =
                  (cacheData.getInstance().lexica.findDiseaseByName(diseaseName));

              return DiseaseButton(
                diseaseName,
                disease,
              );
            },
          ),
        );

        description = DescriptionWidget(
            ref.read(PlantorDisease).name,
            ref.read(PlantorDisease).image,
            AppLocalizations.of(context).translate('how_to'),
            ref.read(PlantorDisease).howTo,
            AppLocalizations.of(context).translate("tips"),
            ref.read(PlantorDisease).tips,
            moreTitle: AppLocalizations.of(context).translate('related'),
            moreWidget: relatedDiseases);

      case const (Disease): // If the current element is a disease

        Widget cure = Padding(
            padding: EdgeInsets.all(mediaQuery.height * 0.02),
            child: Text(
              ref.read(PlantorDisease).cure,
              textAlign: TextAlign.center,
              style: style.copyWith(fontSize: 18),
            ));
        description = DescriptionWidget(
          ref.read(PlantorDisease).name,
          ref.read(PlantorDisease).image,
          AppLocalizations.of(context).translate('what_is_it'),
          ref.read(PlantorDisease).description,
          AppLocalizations.of(context).translate('prevent'),
          [ref.read(PlantorDisease).prevent],
          moreTitle: AppLocalizations.of(context).translate('cure'),
          moreWidget: cure,
        );

      default:
        throw ("Error: invalid type");
    }

    return description;
  }
}

//------------------- PLANT DESCRIPTION ------------------
class DescriptionWidget extends StatelessWidget {
  final String name;
  final String image;
  final String? icon;
  final String title;
  final String text;
  final String title2;
  final List<String> text2;
  final String? moreTitle;
  final Widget? moreWidget;

  DescriptionWidget(
      this.name, this.image, this.title, this.text, this.title2, this.text2,
      {this.moreTitle, this.moreWidget, this.icon});
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 20);

    return Center(
      child: SizedBox(
        // Size of the card
        width: mediaQuery.width * 0.8,
        height: mediaQuery.height * 1,
        child: Card(
          margin: EdgeInsets.only(
            // Position of the card
            top: mediaQuery.height * 0.05,
            bottom: mediaQuery.height * 0.05,
          ),
          color: theme.colorScheme.primary, // Background color
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Plant's name
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary, fontSize: 30),
                      ),
                    )),

                // Plant's image
                Image(
                  image: NetworkImage(image),
                  width: mediaQuery.width * 0.6,
                  height: mediaQuery.width * 0.5,
                ),

                // How to take care of the plant (title)
                Container(
                  padding: EdgeInsets.only(
                    bottom: mediaQuery.height * 0.02,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: mediaQuery.width * 0.05),
                            child: Text(
                                textAlign: TextAlign.center,
                                title,
                                style: style),
                          ),
                        ),

                        // Separation line
                        Container(
                          height: mediaQuery.height * 0.02,
                          width: mediaQuery.width * 0.5,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white,
                                width: 2, // the line's size
                              ),
                            ),
                          ),
                        ),

                        // How to take care of the plant (text)
                        Padding(
                            padding: EdgeInsets.all(mediaQuery.height * 0.02),
                            child: AutoSizeText(
                              text,
                              textAlign: TextAlign.center,
                              maxFontSize: 20,
                              minFontSize: 18,
                              style: style,
                            )),

                        // Related diseases (title)
                        Text(
                          title2,
                          style: style,
                        ),

                        // Separation line
                        Container(
                          height: mediaQuery.height * 0.02,
                          width: mediaQuery.width * 0.5,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white,
                                width: 2, // the line's size
                              ),
                            ),
                          ),
                        ),

                        // if there is only 1 text in the list, only add the text, else add each text and create a space between them
                        if (text2.length == 1)
                          Padding(
                              padding: EdgeInsets.all(mediaQuery.height * 0.02),
                              child: AutoSizeText(
                                text2[0],
                                textAlign: TextAlign.center,
                                maxFontSize: 20,
                                minFontSize: 18,
                                style: style,
                              )),
                        if (text2.length > 1)
                          for (int i = 0; i < text2.length; i++)
                            Padding(
                                padding: EdgeInsets.only(
                                  top: mediaQuery.height * 0.01,
                                  left: mediaQuery.height * 0.02,
                                  right: mediaQuery.height * 0.02,
                                ),
                                child: Text(
                                  "- ${text2[i]}",
                                  textAlign: TextAlign.center,
                                  style: style.copyWith(
                                    fontSize: 18,
                                  ),
                                )),

                        // If moreTitle is initialized, use it
                        if (moreTitle != null)
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: mediaQuery.height * 0.02,
                                  right: mediaQuery.height * 0.02,
                                ),
                                child: Text(
                                  moreTitle!,
                                  textAlign: TextAlign.center,
                                  style: style,
                                ),
                              ),
                              // Separation line
                              Container(
                                height: mediaQuery.height * 0.02,
                                width: mediaQuery.width * 0.5,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white,
                                      width: 2, // the line's size
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // If moreWidget is initialized, use it
                        if (moreWidget != null) moreWidget!,
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//------------------------ BUTTON ------------------------
class DiseaseButton extends ConsumerWidget {
  final String name;
  final Disease disease;

  DiseaseButton(this.name, this.disease);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 20);

    // Create text painter
    final textPainter = TextPainter(
      text: TextSpan(text: name, style: style),
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
            text: name,
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
          ),
        ),
      );
    } else {
      // Use AutoSizeText if text fits within available width
      textWidget = Positioned.fill(
          child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                textAlign: TextAlign.center,
                name,
                style: style,
                maxLines: 1,
                maxFontSize: 20,
                minFontSize: 20,
                overflow: TextOverflow.ellipsis,
              )));
    }

    return Card(
      color: theme.colorScheme.secondary,
      margin: EdgeInsets.only(
        top: mediaQuery.height * 0.05,
        left: mediaQuery.width * 0.15,
        right: mediaQuery.width * 0.1,
      ),
      child: InkWell(
        onTap: () {
          ref.read(tab.notifier).state = 3;
          ref.read(DiseaseDescription.notifier).state = disease;
          ref.read(infectedPlantImage.notifier).state =
              ref.read(PlantorDisease).image;
        },
        splashColor: Colors.white.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: mediaQuery.height * 0.012),
          child: Center(
            child: SizedBox(
              height: mediaQuery.height * 0.06,
              width: mediaQuery.width * 0.5,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.loose,
                children: [
                  //---------- IMAGE ----------
                  Positioned(
                    left: -mediaQuery.width * 0.07,
                    top: -mediaQuery.height * 0.02,
                    child: Container(
                      width: mediaQuery.width * 0.2,
                      height: mediaQuery.width * 0.2,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(disease.icon),
                        ),
                      ),
                    ),
                  ),
                  //---------- NAME ----------
                  textWidget
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
