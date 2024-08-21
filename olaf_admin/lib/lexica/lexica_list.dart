//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf_admin/classes.dart';
import 'package:olaf_admin/lexica/lexica_utils.dart';

//------------------- FLUTTER IMPORTS -------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//------------------ GENERAL PROVIDERS ------------------
//----------------- ID -----------------
final targetID = StateProvider<int>((ref) => 0);

//---------------- NAME ----------------
final nameController = StateProvider<TextEditingController>(
    (ref) => TextEditingController(text: null));

//---------- HOWTO/DESCRIPTION ---------
final bigTextController = StateProvider<TextEditingController>(
    (ref) => TextEditingController(text: null));

//-------------- REBUILD ---------------
final rebuildTriggerProvider = ChangeNotifierProvider<Notifier>((ref) {
  return Notifier();
});

class Notifier extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

//------------- USER INPUT -------------
final checkUserInputProvider = StateProvider<bool>((ref) => false);

//------------------- PLANT PROVIDERS -------------------
//---------------- TIPS ----------------
final tipsController = StateProvider<List<TextEditingController>>((ref) => []);

//-------------- DISEASES --------------
final diseasesController =
    StateProvider<List<TextEditingController>>((ref) => []);

//------------------ DISEASE PROVIDERS ------------------
//--------------- PREVENT --------------
final preventController =
    StateProvider<TextEditingController>((ref) => TextEditingController());
//---------------- CURE ----------------
final cureController =
    StateProvider<TextEditingController>((ref) => TextEditingController());

class LexicaListState extends ConsumerStatefulWidget {
  final String type;

  const LexicaListState({super.key, required this.type});

  @override
  ConsumerState<LexicaListState> createState() => LexicaList();
}

class LexicaList extends ConsumerState<LexicaListState> {
  late Widget finalWidget;
  final lexica = CacheData.getInstance().lexica;
  late dynamic plantOrDisease;

  List<VoidCallback> listeners = [];

  @override
  void initState() {
    super.initState();
    createListeners();
  }

  void createListeners() {
    ref.read(tipsController.notifier).state.clear();
    ref.read(diseasesController.notifier).state.clear();

    if (widget.type == "plants") {
      plantOrDisease =
          CacheData.getInstance().lexica.plants[ref.read(targetID)];
    } else {
      plantOrDisease =
          CacheData.getInstance().lexica.diseases[ref.read(targetID)];
    }

    // Create a listener for the name of the plant/disease
    createListener(() {
      _onChange(
          ref.read(nameController).text, plantOrDisease.name, plantOrDisease);
    }, ref.read(nameController));

    // If it is a plant, create listeners for: how to, tips, and diseases
    if (plantOrDisease is Plant) {
      plantOrDisease =
          CacheData.getInstance().lexica.plants[ref.read(targetID)];

      // Create how to listener
      createListener(() {
        _onChange(ref.read(bigTextController).text, plantOrDisease.howTo,
            plantOrDisease);
      }, ref.read(bigTextController));

      // Create tips listeners
      int tipsLength = plantOrDisease.tips.length;
      for (int index = 0; index < tipsLength; index++) {
        ref
            .read(tipsController.notifier)
            .state
            .add(TextEditingController(text: plantOrDisease.tips[index]));
        createListener(() {
          _onChange(ref.read(tipsController)[index].text,
              plantOrDisease.tips[index], plantOrDisease);
        }, ref.read(tipsController)[index]);
      }

      // Create listeners for diseases
      int diseasesLength = plantOrDisease.diseases.length;
      for (int index = 0; index < diseasesLength; index++) {
        ref
            .read(diseasesController.notifier)
            .state
            .add(TextEditingController());
        createListener(() {
          _onChange(ref.read(diseasesController)[index].text,
              plantOrDisease.diseases[index].name, plantOrDisease);
        }, ref.read(diseasesController)[index]);
      }

      // If it is a disease, create a listener for: description, prevent, and cure
    } else {
      plantOrDisease =
          CacheData.getInstance().lexica.diseases[ref.read(targetID)];

      // Create listener for description
      createListener(() {
        _onChange(ref.read(bigTextController).text, plantOrDisease.description,
            plantOrDisease);
      }, ref.read(bigTextController));

      // Create listener for prevent
      createListener(() {
        _onChange(ref.read(preventController).text, plantOrDisease.prevent,
            plantOrDisease);
      }, ref.read(preventController));

      // Create listener for cure
      createListener(() {
        _onChange(
            ref.read(cureController).text, plantOrDisease.cure, plantOrDisease);
      }, ref.read(cureController));
    }
  }

  void createListener(VoidCallback listener, TextEditingController controller) {
    listeners.add(listener);
    controller.addListener(listener);
  }

  void deleteListeners() {
    if (plantOrDisease is Plant) {
      for (TextEditingController controller in ref.read(diseasesController)) {
        deleteListener(controller);
      }

      for (TextEditingController controller in ref.read(tipsController)) {
        deleteListener(controller);
      }
    } else if (plantOrDisease is Disease) {
      deleteListener(ref.read(cureController));
      deleteListener(ref.read(preventController));
    }
    deleteListener(ref.read(bigTextController));
    deleteListener(ref.read(nameController));
  }

  void deleteListener(TextEditingController controller) {
    controller.removeListener(listeners.last);
    listeners.removeLast();
  }

  void _onChange(
      String changeString, String originalString, dynamic plantOrDisease) {
    // If the action has not been performed by the user, cancel the changes
    if (ref.read(checkUserInputProvider) == false) {
      return;
    }
    if (plantOrDisease is Plant) {
      if (plantOrDisease.name == originalString) {
        plantOrDisease.name = changeString;
      } else if (plantOrDisease.howTo == originalString) {
        plantOrDisease.howTo = changeString;
      } else if (plantOrDisease.tips.contains(originalString)) {
        final int index = plantOrDisease.tips.indexOf(originalString);
        plantOrDisease.tips[index] = changeString;
      } else if (plantOrDisease.diseases
          .any((element) => element.name == originalString)) {
        final int index = plantOrDisease.diseases
            .indexWhere((element) => element.name == originalString);
        plantOrDisease.diseases[index].name = changeString;
      }
      return;
    } else if (plantOrDisease is Disease) {
      if (plantOrDisease.name == originalString) {
        plantOrDisease.name = changeString;
      } else if (plantOrDisease.description == originalString) {
        plantOrDisease.description = changeString;
      } else if (plantOrDisease.prevent == originalString) {
        plantOrDisease.prevent = changeString;
      } else if (plantOrDisease.cure == originalString) {
        plantOrDisease.cure = changeString;
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(targetID, (previous, next) {
      deleteListeners();
      createListeners();
    });
    //----------- NOTIFIER -----------
    ref.watch(rebuildTriggerProvider);

    final type = widget.type;
    final mediaQuery = MediaQuery.sizeOf(context);
    final titleStyle = TextStyle(fontSize: mediaQuery.width * 0.03);
    final textStyle = TextStyle(fontSize: mediaQuery.width * 0.015);

    //------------ PLANTS ------------
    if (type == "plants") {
      final plants = lexica.plants;
      final plant = plants[ref.watch(targetID)];
      // Reset how to controller
      ref.read(bigTextController.notifier).state.text = plant.howTo;

      finalWidget = Row(children: [
        //---------- PLANT LIST ----------
        NameList(plantOrDisease: plants),
        //------------ DIVIDER -----------
        const VerticalDivider(),

        //---------- PLANT INFO ----------
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //------------- NAME -------------
                Name(plantOrDisease: plants),
                //------------- IMAGE -------------
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        "Image:",
                        style: titleStyle,
                      ),
                      ImageChanger(
                        image: plant.image,
                        type: const [0, 0],
                      ),
                      const Divider()
                    ],
                  ),
                ),

                //------------- HOW TO ------------
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        "How to take care of it:",
                        style: titleStyle,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                        controller: ref.watch(bigTextController),
                        textAlign: TextAlign.start,
                        maxLines: null,
                        style: textStyle,
                      ),
                      const Divider()
                    ],
                  ),
                ),

                //------------- TIPS ------------
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Tips:", style: titleStyle),
                          ]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int tipsIndex = 0;
                              tipsIndex < ref.watch(tipsController).length;
                              tipsIndex++)
                            Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: mediaQuery.width * 0.6,
                                  ),
                                  child: TextFormField(
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none),
                                    controller:
                                        ref.watch(tipsController)[tipsIndex],
                                    textAlign: TextAlign.start,
                                    style: textStyle,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    ref
                                        .read(tipsController.notifier)
                                        .state
                                        .removeAt(tipsIndex);
                                    plant.tips.removeAt(tipsIndex);
                                    ref.watch(rebuildTriggerProvider).update();
                                  },
                                  icon: const Icon(
                                      Icons.remove_circle_outline_outlined),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(tipsController.notifier)
                                      .state
                                      .add(TextEditingController());
                                  plant.tips.add("new tip");
                                  ref.watch(rebuildTriggerProvider).update();
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                iconSize: mediaQuery.width * 0.02,
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(),

                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Diseases:", style: titleStyle),
                      for (int diseaseIndex = 0;
                          diseaseIndex < plant.diseases.length;
                          diseaseIndex++)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: mediaQuery.width * 0.1,
                                ),
                                IconButton(
                                  padding: EdgeInsets.only(
                                      top: mediaQuery.width * 0.005),
                                  onPressed: () {
                                    ref
                                        .read(diseasesController.notifier)
                                        .state
                                        .removeAt(diseaseIndex);
                                    plant.diseases.removeAt(diseaseIndex);
                                    ref.watch(rebuildTriggerProvider).update();
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: mediaQuery.width * 0.2),
                                  child: TextFormField(
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    controller: ref.watch(
                                        diseasesController)[diseaseIndex],
                                    textAlign: TextAlign.start,
                                    style: textStyle,
                                  ),
                                ),
                              ],
                            ),
                            ImageChanger(
                                image: plant.diseases[diseaseIndex].image,
                                type: [3, diseaseIndex]),
                            if (diseaseIndex < plant.diseases.length - 1)
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: mediaQuery.height * 0.03)),
                            if (diseaseIndex < plant.diseases.length - 1)
                              Divider(
                                indent: mediaQuery.width * 0.2,
                                endIndent: mediaQuery.width * 0.2,
                                thickness: 3,
                              ),
                          ],
                        ),
                      IconButton(
                        onPressed: () {
                          ref
                              .read(diseasesController.notifier)
                              .state
                              .add(TextEditingController());
                          plant.diseases.add(PlantDisease(
                              name: "NewDisease", image: "placeholder"));
                          ref.watch(rebuildTriggerProvider).update();
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        iconSize: mediaQuery.width * 0.05,
                      )
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(bottom: mediaQuery.height * 0.1))
              ],
            ),
          ),
        ),
      ]);
    } else if (type == "diseases") {
      final diseases = lexica.diseases;
      final disease = diseases[ref.watch(targetID)];

      // Reset description controller
      ref.read(bigTextController.notifier).state.text = disease.description;

      // Reset prevent controller
      ref.read(preventController.notifier).state.text = disease.prevent;

      // Reset cure controller
      ref.read(cureController.notifier).state.text = disease.cure;

      finalWidget = Row(children: [
        //---------- PLANT LIST ----------
        NameList(plantOrDisease: diseases),
        //------------ DIVIDER -----------
        const VerticalDivider(),

        //---------- PLANT INFO ----------
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              //------------- NAME -------------
              Name(plantOrDisease: diseases),

              //------------- IMAGE -------------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Image:",
                      style: titleStyle,
                    ),
                    ImageChanger(
                      image: disease.image,
                      type: const [1, 0],
                    ),
                    const Divider()
                  ],
                ),
              ),

              //------------- ICON -------------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Icon:",
                      style: titleStyle,
                    ),
                    ImageChanger(
                      image: disease.icon,
                      type: const [2, 0],
                    ),
                    const Divider()
                  ],
                ),
              ),
              //---------- DESCRIPTION ----------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Description:",
                      style: titleStyle,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: ref.watch(bigTextController),
                      textAlign: TextAlign.start,
                      style: textStyle,
                      maxLines: null,
                    ),
                    const Divider()
                  ],
                ),
              ),
              //---------- PREVENT ----------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Prevent:",
                      style: titleStyle,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: ref.watch(preventController),
                      textAlign: TextAlign.start,
                      style: textStyle,
                      maxLines: null,
                    ),
                    const Divider()
                  ],
                ),
              ),
              //----------- CURE ------------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Cure:",
                      style: titleStyle,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: ref.watch(cureController),
                      textAlign: TextAlign.start,
                      style: textStyle,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ]);
    } else {
      throw "Unkown type in lexica";
    }
    return finalWidget;
  }
}
