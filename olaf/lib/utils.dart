import 'package:flutter/material.dart';

class SlideToSettings extends PageRouteBuilder {
  final Widget page;
  SlideToSettings({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}


//----------------------- CARD ----------------------
class CardWidget extends StatelessWidget {
  final String text;
  final Widget image;
  final double fontSize;
  CardWidget(this.text, this.image, this.fontSize);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);

    return SizedBox(
      width: mediaQuery.width * 0.4,
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
                Container(
                  width: mediaQuery.width * 0.3,
                  height: mediaQuery.width * 0.3,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 4), // Add border
                    borderRadius: BorderRadius.circular(10), // rounded corners
                  ),
                  child: ClipRRect(
                    // Ensures border-radius applies correctly
                    borderRadius: BorderRadius.circular(5),
                    child: image
                  ),
                ),
                SizedBox(
                  width: mediaQuery.width * 0.35,
                  height: mediaQuery.height * 0.05,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0.57),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(fontSize: fontSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}