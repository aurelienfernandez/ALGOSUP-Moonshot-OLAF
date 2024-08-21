//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf_admin/lexica/lexica_list.dart';
//------------------- FLUTTER IMPORTS -------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//---------------------- PROVIDERS ----------------------
final tab = StateProvider<int>((ref) => 0);

class LexicaPage extends ConsumerStatefulWidget {
  const LexicaPage({super.key});
  @override
  ConsumerState<LexicaPage> createState() => _LexicaPage();
}

class _LexicaPage extends ConsumerState<LexicaPage> {
  final tabs = [
    const LexicaChoice(),
    const LexicaListState(type: "plants"),
    const LexicaListState(type: "diseases")
  ];
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (ref.watch(tab) > 0) {
              // Reset tab to 0 if currentTab is greater than 0

              ref.read(tab.notifier).state = 0;
            } else {
              // Otherwise, pop the navigator
              Navigator.of(context).pop();
            }
          },
        ),
        bottom: PreferredSize(
            preferredSize: Size(mediaQuery.width, mediaQuery.height * 0.001),
            child: const Divider()),
      ),
      body: tabs[ref.watch(tab)],
    );
  }
}

class LexicaChoice extends ConsumerWidget {
  const LexicaChoice({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final mediaQuery = MediaQuery.sizeOf(context);

    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //------------ PLANTS ------------
        ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              minimumSize: MaterialStateProperty.all<Size>(
                Size(mediaQuery.width * 0.15, mediaQuery.height * 0.07),
              ),
            ),
            onPressed: () {
              ref.read(tab.notifier).state = 1;
            },
            child: Text(
              "Plants",
              style: TextStyle(fontSize: mediaQuery.width * 0.015),
            )),

        //------------ SPACE -------------
        SizedBox(width: mediaQuery.width * 0.05),

        //----------- DISEASES -----------
        ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              minimumSize: MaterialStateProperty.all<Size>(
                Size(mediaQuery.width * 0.15, mediaQuery.height * 0.07),
              ),
            ),
            onPressed: () {
              ref.read(tab.notifier).state = 2;
            },
            child: Text(
              "Diseases",
              style: TextStyle(fontSize: mediaQuery.width * 0.015),
            )),
      ],
    ));
  }
}
