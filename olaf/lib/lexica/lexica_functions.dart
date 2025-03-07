import 'package:flutter/material.dart';

class LexicaChoice extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<String> images;

  LexicaChoice(this.text, this.onPressed, this.images);
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: mediaQuery.width * 0.45,
        height: mediaQuery.height * 0.25,
        child: Padding(
          padding: EdgeInsets.only(top: mediaQuery.height * 0.02),
          child: DecoratedBox(
              decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: mediaQuery.width * 0.35,
                        width: mediaQuery.width * 0.35,
                        child: GridView.count(
                          padding: EdgeInsets.zero, // Remove extra padding
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            // Top-left image
                            buildImage(
                              images[0],
                              context,
                              BorderRadius.only(topLeft: Radius.circular(15)),
                            ),
                            // Top-right image
                            buildImage(
                              images[1],
                              context,
                              BorderRadius.only(topRight: Radius.circular(15)),
                            ),
                            // Bottom-left image
                            buildImage(
                              images[2],
                              context,
                              BorderRadius.only(
                                  bottomLeft: Radius.circular(15)),
                            ),
                            // Bottom-right image
                            buildImage(
                              images[3],
                              context,
                              BorderRadius.only(
                                  bottomRight: Radius.circular(15)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: mediaQuery.width * 0.35,
                    height: mediaQuery.height * 0.05,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.57),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Center(
                        child: Text(text),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

Widget buildImage(
    String imagePath, BuildContext context, BorderRadius borderRadius) {
  var mediaQuery = MediaQuery.sizeOf(context);

  return ClipRRect(
    borderRadius: borderRadius,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius, // Apply rounded corners to border
        border: Border.all(
          color:
              Theme.of(context).colorScheme.primary, // Keep your border color
          width: mediaQuery.width * 0.004, // Keep your border width
        ),
      ),
      child: ClipRRect(
        borderRadius:
            borderRadius, // Apply the same rounded corners to avoid clipping
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}
