import 'package:flutter/material.dart';

class EncyclopediaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        BigCard("Plants Encyclopedia"),
        BigCard("Diseases Encyclopedia"),
      ]),
    );
  }
}

class BigCard extends StatelessWidget {
  final String text;
  BigCard(this.text);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 30.0);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(text, style: style),
              Icon(Icons.arrow_right_alt_outlined, color: Colors.white)
            ],
          )
          // child: Text(text, style: style),
          ),
    );
  }
}
