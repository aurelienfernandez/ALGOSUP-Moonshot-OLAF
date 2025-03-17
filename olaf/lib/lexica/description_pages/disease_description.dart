import 'package:flutter/material.dart';
import 'package:olaf/lexica/description_pages/plant_description.dart';

/// This class creates the page displaying all information related to a plant
/// from the lexicon.
///
/// Parameters:
/// - `name`: the name of the plant.
/// - `image`: The picture of the plant.
/// - `description`: The description of how to take care of this plant.
/// - `prevent`: A text explaining how to prevent this disease from infecting plants.
/// - `cure`: A text explaining how to cure plant from this disease.
class DiseaseDescription extends StatelessWidget {
  final String name;
  final String image;
  final String description;
  final String prevent;
  final String cure;
  DiseaseDescription(
      this.name, this.image, this.description, this.prevent, this.cure);

  Widget buildTextWidget(String text, double width) {
    return Text(
      text,
      style: TextStyle(fontSize: width),
    );
  }

  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    //========== DESCRIPTION ===========
    final Widget descriptionWidget =
        buildTextWidget(description, mediaQuery.width * 0.05);

    //============ PREVENT =============
    final Widget preventWidget =
        buildTextWidget(prevent, mediaQuery.width * 0.05);

    //============== CURE ==============
    final Widget cureWidget = buildTextWidget(cure, mediaQuery.width * 0.05);

    return Center(
        child: SingleChildScrollView(
      child: Column(
        children: [
          //========== SPACE ===========
          SizedBox(
            height: mediaQuery.height * 0.03,
          ),
          //=========== NAME ===========
          Container(
            width: mediaQuery.width * 0.7,
            height: mediaQuery.height * 0.08,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: theme.colorScheme.secondary),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                    color: Colors.black, fontSize: mediaQuery.width * 0.07),
              ),
            ),
          ),
          //========== SPACE ===========
          SizedBox(
            height: mediaQuery.height * 0.03,
          ),
          //========== IMAGE ===========
          Container(
            width: mediaQuery.width * 0.5,
            height: mediaQuery.width * 0.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: theme.colorScheme.secondary),
            child: Center(
                child: Container(
              width: mediaQuery.width * 0.43,
              height: mediaQuery.width * 0.43,
              decoration: BoxDecoration(
                border: Border.all(
                    color: theme.colorScheme.primary,
                    width: mediaQuery.width * 0.015),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            )),
          ),
          //========== SPACE ===========
          SizedBox(
            height: mediaQuery.height * 0.03,
          ),
          //======= DESCRIPTION ========
          DescriptionAndTipsCard("Description", descriptionWidget),
          //========== SPACE ===========
          SizedBox(
            height: mediaQuery.height * 0.03,
          ),
          //======= DESCRIPTION ========
          DescriptionAndTipsCard("Prevent", preventWidget),
          //========== SPACE ===========
          SizedBox(
            height: mediaQuery.height * 0.03,
          ),
          //======= DESCRIPTION ========
          DescriptionAndTipsCard("Cure", cureWidget),
          //========== SPACE ===========
          SizedBox(
            height: mediaQuery.height * 0.03,
          ),
        ],
      ),
    ));
  }
}
