//------------------------- PAGES -------------------------
import 'package:olaf/classes.dart';
import 'package:olaf/main.dart';
import 'package:olaf/camera/camera.dart';
import 'package:olaf/layout_manager.dart';
import 'package:olaf/app_localization.dart';
import 'package:olaf/cache/loader.dart'; // Added import for loadAllData
//------------------------ FLUTTER ------------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
//----------------------- FUNCTIONS -----------------------
import 'package:olaf/home/home_page_widgets.dart';

//------------------------ HOMEPAGE -----------------------
class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = false;

  // Function to show the info dialog
  void _showInfoDialog(BuildContext context) {
    String title = AppLocalizations.of(context).translate('supported_plants');
    String content =
        AppLocalizations.of(context).translate('currently_supported');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Function to reload user data
  Future<void> _reloadUserData(BuildContext context) async {
    if (_isLoading) return; // Prevent multiple calls while loading

    setState(() {
      _isLoading = true;
    });
    
    // Reload data
    await loadAllData();
    
    // Reset loading state
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.invalidate(pageIndex);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // Check if images are empty
          cacheData.getInstance().images.isEmpty
              ? Center(
                  child: Gardens(),
                )
              : SingleChildScrollView(
                  child: Gardens(),
                ),

          // Reload Button at Top Right
          Positioned(
            top: mediaQuery.height * 0.05,
            right: mediaQuery.width * 0.05,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isLoading 
                  ? theme.colorScheme.primary.withOpacity(0.5) // Greyed out color
                  : theme.colorScheme.primary,
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 5)],
              ),
              child: IconButton(
                onPressed: _isLoading ? null : () async {
                  await _reloadUserData(context);
                  ref.refresh(pageIndex);
                }, // Disable when loading
                icon: _isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      size: 20,
                    ),
                color: Colors.white,
                padding: EdgeInsets.zero,
              ),
            ),
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
                          cameras: ref.read(camerasProvider),
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

          // Help Button at Bottom Right
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.translate(
              offset:
                  Offset(-mediaQuery.width * 0.05, -mediaQuery.height * 0.02),
              child: Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: theme.colorScheme.primary,
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 7)],
                ),
                child: IconButton(
                  onPressed: () => _showInfoDialog(context),
                  icon: Icon(
                    Icons.help_outline,
                    size: mediaQuery.height * 0.025,
                  ),
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  iconSize: mediaQuery.height * 0.025,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
