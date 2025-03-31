//------------------- FLUTTER IMPORTS -------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

//-------------------- CUSTOM IMPORTS -------------------
import 'package:olaf/classes.dart';
import 'package:olaf/plants/plant_data.dart';

//--------------------- PROVIDERS ----------------------
final plantsIndex = StateProvider<int>((ref) => 0);
final GraphChoice = StateProvider<int>((ref) => 0);

//--------------------- PLANT STATE ---------------------
class PlantPage extends ConsumerStatefulWidget {
  const PlantPage({super.key});

  @override
  _PlantTabState createState() => _PlantTabState();
}

//---------------------- PLANT TAB ----------------------
class _PlantTabState extends ConsumerState<PlantPage> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);

    Widget body;

    if (ref.watch(plantsIndex) != 0) {
      body = PlantStatus(
          cacheData.getInstance().savedPlants[ref.read(plantsIndex) - 1]);
    } else {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //========== SPACE ===========
          SizedBox(
            height: mediaQuery.height * 0.03,
          ),
          ListView.builder(
            itemCount: cacheData.getInstance().savedPlants.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var plant = cacheData.getInstance().savedPlants[index];
              return Container(
                margin: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: MediaQuery.of(context).size.width * 0.15,
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade500,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () {
                    ref.read(plantsIndex.notifier).state = index+1;
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                13), 
                            child: Image.network(
                              plant.image,
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.width * 0.2,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return const Icon(Icons.error);
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      Expanded(
                        child: Text(
                          plant.name,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surface),
            ),
            onPressed: () {
              setState(() {
                String name = "new plant";
                String image =
                    "https://www.southernliving.com/thmb/8sJLpOMVrdM3RO6GeyuSVAJa9G8=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-1365178498-81dd069cd1514e288e68516bc96df8d4.jpg";
                cacheData.getInstance().savedPlants.add(Plant(
                      name: name,
                      type: "tomato",
                      image: image, // Updated property name for clarity
                      disease: "none",
                      soilHumidity:
                          List.generate(10, (_) => Random().nextInt(26) + 70),
                      airHumidity: [68, 75, 76, 80, 78, 74, 73, 72, 69, 65],
                      temperature: List.generate(
                          10,
                          (_) =>
                              ((Random().nextDouble() * 20 + 15) * 10)
                                  .truncateToDouble() /
                              10),
                    ));
              });
            },
            icon: Icon(Icons.add),
            label: Text("Add a plant"),
          ),
        ],
      );
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(child: body),
      ),
    );
  }
}
