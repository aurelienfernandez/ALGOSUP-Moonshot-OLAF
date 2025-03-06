//------------------------- PAGES -------------------------
import 'package:olaf/main.dart';
import 'package:olaf/camera/camera.dart';
import 'package:olaf/layout_manager.dart';
//------------------------ FLUTTER ------------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
//----------------------- FUNCTIONS -----------------------
import 'package:olaf/home/home_page_functions.dart';

//------------------------ HOMEPAGE -----------------------
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.invalidate(pageIndex);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);

  return Scaffold(
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Gardens(), 
          ),

          // Button at Bottom Center
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, -mediaQuery.height * 0.02),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: theme.colorScheme.primary,
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 7)],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          cameras: ref.read(CamerasProvider),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    size: mediaQuery.height * 0.05,
                  ),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}