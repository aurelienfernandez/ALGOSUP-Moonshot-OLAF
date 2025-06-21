//------------------------ FLUTTER ------------------------
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
//------------------------- UTILS -------------------------
import 'package:olaf/classes.dart';
import 'package:olaf/camera/lambda.dart'; // Import lambda for deleteAnalyzedPicture function
import 'package:olaf/app_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';

//------------------------ GARDENS ------------------------
class Gardens extends ConsumerStatefulWidget {
  const Gardens({super.key});

  @override
  _GardensState createState() => _GardensState();
}

//--------------------- GARDENS STATE ---------------------
class _GardensState extends ConsumerState<Gardens>
    with AutomaticKeepAliveClientMixin {
  List<SavedPlant> plantsList = cacheData.getInstance().savedPlants;
  late User user;
  final allImages = cacheData.getInstance().images;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediaQuery = MediaQuery.sizeOf(context);
    
    if (allImages.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_analyzed_pictures'),
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return Stack(
      children: [
        
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start, // Align columns at the top
            children: [
              Column(children: [
          for (int i = 0; i < allImages.length; i += 2)
            PictureCards(
                allImages[i].name.substring(0, 10) +
              "\n" +
              allImages[i].result.split(" ").first +
              "\n" +
              allImages[i].result.split(" ").sublist(1).join(" "),
                Image(
            image: MemoryImage(
              base64Decode(allImages[i].image),
            ),
            fit: BoxFit.fill,
                ),
                mediaQuery.width * 0.025,
                allImages[i].name), 
              ]),
              if (allImages.length > 1)
          Column(
            children: [
              for (int i = 1; i < allImages.length; i += 2)
                PictureCards(
              allImages[i].name.substring(0, 10) +
                  "\n" +
                  allImages[i].result.split(" ").first +
                  "\n" +
                  allImages[i].result.split(" ").sublist(1).join(" "),
              Image(
                image: MemoryImage(
                  base64Decode(allImages[i].image),
                ),
                fit: BoxFit.fill,
              ),
              mediaQuery.width * 0.025,
              allImages[i].name) 
            ],
          )
            ],
          )
        ),
       
      ],
    );
  }
}

//----------------------- CARD ----------------------
class PictureCards extends StatelessWidget {
  final String text;
  final Widget image;
  final double fontSize;
  final String imageName;

  PictureCards(this.text, this.image, this.fontSize, this.imageName);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);

    return SizedBox(
      width: mediaQuery.width * 0.4,
      height: mediaQuery.height * 0.25,
      child: Padding(
        padding: EdgeInsets.only(top: mediaQuery.height * 0.02),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(15),
                
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                    child: SizedBox(
                      width: mediaQuery.width * 0.4,
                      height: mediaQuery.height * 0.18,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: mediaQuery.width * 0.4,
                          child: image,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: mediaQuery.height * 0.05,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: AutoSizeText(
                          text,
                          style: TextStyle(fontSize: fontSize),
                          textAlign: TextAlign.center,
                          minFontSize: 8,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Delete button positioned at the top right
            Positioned(
              top: -mediaQuery.height * 0.015,
              right: -mediaQuery.width * 0.04,
              child: IconButton(
                  onPressed: () {
                    // Call the delete function from lambda.dart
                    deleteAnalyzedPicture(imageName);
                    // Remove the image from cache
                    final cache = cacheData.getInstance();
                    cache.images
                        .removeWhere((img) => img.name == imageName);
                    // Force UI refresh if this widget is used in a list
                    if (context.findAncestorStateOfType<_GardensState>() !=
                        null) {
                      // Refresh the parent Gardens widget state
                      context
                          .findAncestorStateOfType<_GardensState>()!
                          .setState(() {});
                    }
                  },
                  icon: Tooltip(
                    message: AppLocalizations.of(context).translate('delete_image'),
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: mediaQuery.width * 0.06,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
