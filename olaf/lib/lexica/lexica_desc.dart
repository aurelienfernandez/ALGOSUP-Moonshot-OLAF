import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:marquee/marquee.dart';
import 'package:olaf/lexica/lexica_loader.dart';

//------------------ LEXICA DESCRIPTION ------------------
class LexicaDescription extends StatelessWidget {
  final dynamic element;
  final void Function(Disease, String) plantToDisease;

  LexicaDescription(this.element, {required this.plantToDisease});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 20);

    Widget description;

    switch (element.runtimeType) {
      case const (LexPlant): // If the current element is a plant

        Widget relatedDiseases = SizedBox(
          height: MediaQuery.of(context).size.height *
              0.14 *
              element.diseases.length, // Set a fixed height to avoid crash
          child: ListView.builder(
            itemCount: element.diseases.length,
            itemBuilder: (BuildContext context, int index) {
              var diseaseName = element.diseases[index].name;
              var diseaseIcon =
                  (Lexica.getInstance().findDiseaseByName(diseaseName)).icon;

              return DiseaseButton(diseaseName, diseaseIcon,element.diseases[index].image, plantToDisease: plantToDisease,);
            },
          ),
        );

        description = DescriptionWidget(
            element.name,
            element.image,
            "How to take care\nof this plant",
            element.howTo,
            "Tips",
            element.tips,
            moreTitle: "Related diseases",
            moreWidget: relatedDiseases);

      case const (Disease): // If the current element is a disease

        Widget cure = Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
            child: Text(
              element.cure,
              textAlign: TextAlign.center,
              style: style.copyWith(fontSize: 18),
            ));
        description = DescriptionWidget(
          element.name,
          element.image,
          "What is this disease",
          element.description,
          "how to prevent it",
          [element.prevent],
          moreTitle: "How to cure it",
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
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 20);

    return Center(
      child: SizedBox(
        // Size of the card
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 1,
        child: Card(
          margin: EdgeInsets.only(
            // Position of the card
            top: MediaQuery.of(context).size.height * 0.05,
            bottom: MediaQuery.of(context).size.height * 0.05,
          ),
          color: theme.colorScheme.secondary, // Background color
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Plant's name
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    name,
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary, fontSize: 30),
                  ),
                ),

                // Plant's image
                Image(
                  image: NetworkImage(image),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.5,
                ),

                // How to take care of the plant (title)
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05),
                            child: Text(
                                textAlign: TextAlign.center,
                                title,
                                style: style),
                          ),
                        ),

                        // Separation line
                        Container(
                          height: MediaQuery.of(context).size.height * 0.02,
                          width: MediaQuery.of(context).size.width * 0.5,
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
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.height * 0.02),
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
                          height: MediaQuery.of(context).size.height * 0.02,
                          width: MediaQuery.of(context).size.width * 0.5,
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
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.height * 0.02),
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
                                  top:
                                      MediaQuery.of(context).size.height * 0.01,
                                  left:
                                      MediaQuery.of(context).size.height * 0.02,
                                  right:
                                      MediaQuery.of(context).size.height * 0.02,
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
                                  left:MediaQuery.of(context).size.height * 0.02,
                                  right:MediaQuery.of(context).size.height * 0.02,
                                ),
                                child: Text(
                                  moreTitle!,
                                  textAlign: TextAlign.center,
                                  style: style,
                                ),
                              ),
                              // Separation line
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                                width: MediaQuery.of(context).size.width * 0.5,
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
class DiseaseButton extends StatelessWidget {
  final String name;
  final String icon;
  final String plantImage;
  final void Function(Disease, String) plantToDisease;

  DiseaseButton(this.name, this.icon, this.plantImage,
      {required this.plantToDisease});

  @override
  Widget build(BuildContext context) {
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
    if (textWidth > MediaQuery.of(context).size.width * 0.4) {
      textWidget = Align(
          alignment:
              Alignment.centerRight, // Aligns the Marquee widget to the right
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child:
                  // Use Marquee if text exceeds available width
                  Marquee(
                text: name,
                style: style,
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: MediaQuery.of(context).size.width * 0.3,
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
                name,
                style: style,
                maxLines: 1,
                maxFontSize: 20,
                minFontSize: 20,
                overflow: TextOverflow.ellipsis,
              )));
    }

    return Card(
        color: theme.primaryColor,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.05,
          left: MediaQuery.of(context).size.width * 0.15,
          right: MediaQuery.of(context).size.width * 0.1,
        ),
        child: InkWell(
            onTap: () {
              plantToDisease(
                  Lexica.getInstance().findDiseaseByName(name), plantImage);
            },
            splashColor: Colors.white.withOpacity(0.5),
            child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.012),
                child: Center(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Stack(
                            clipBehavior: Clip.none,
                            fit: StackFit.loose,
                            children: [
                              //---------- IMAGE ----------
                              Positioned(
                                left: -MediaQuery.of(context).size.width * 0.07,
                                top: -MediaQuery.of(context).size.height * 0.02,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  height:
                                      MediaQuery.of(context).size.width * 0.2,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(icon),
                                    ),
                                  ),
                                ),
                              ),
                              //---------- NAME ----------

                              textWidget
                            ]))))));
  }
}
