// Import the Flutter Material package (provides Material Design widgets and themes)
import 'package:flutter/material.dart';

// Import your custom ListViewDemo page to navigate to after splash screen
import 'listViewDemo.dart';

// Entry point of the app
void main() {
  // runApp starts the Flutter app and attaches it to the screen
  runApp(const TravelyApp());
}

// Start: Main App Widget (Stateless because it doesn’t manage state itself)
class TravelyApp extends StatelessWidget {
  const TravelyApp({super.key}); // Constructor with optional key

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root widget of the app
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Remove the debug banner in top-right corner
      title: 'Travely', // Title used by the OS for the app
      theme: ThemeData(
        useMaterial3: true, // Enable Material Design 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Primary seed color for theme
          brightness: Brightness.light, // Light mode theme
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0, // Remove AppBar shadow
          backgroundColor: Colors.transparent, // Transparent AppBar
        ),
      ),
      home: const SplashScreen(), // First screen shown when app starts
    );
  }
}

// Start: SplashScreen Widget (Stateful because it has a timer and animation)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Constructor

  @override
  State<SplashScreen> createState() => _SplashScreenState(); // Create mutable state
}

// Start: SplashScreen State Class
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState(); // Always call super.initState() first

    // Wait for 2 seconds, then navigate to ListViewDemo
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ListViewDemo(),
        ), // Navigate to main page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF6366F1,
      ), // Splash screen background color
      body: Center(
        // Center all content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            // Animated logo container
            AnimatedContainer(
              duration: const Duration(seconds: 1), // Animation duration
              curve: Curves.elasticOut, // Elastic animation curve
              width: 100, // Width of container
              height: 100, // Height of container
              decoration: BoxDecoration(
                // Gradient background from purple to pink
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25), // Rounded corners
                boxShadow: [
                  // Shadow for 3D effect
                  BoxShadow(
                    color: const Color(
                      0xFF8B5CF6,
                    ).withOpacity(0.4), // Shadow color with transparency
                    blurRadius: 30, // How blurry the shadow is
                    spreadRadius: 5, // How far the shadow spreads
                  ),
                ],
              ),
              // Logo icon inside the animated container
              child: const Icon(
                Icons.airplanemode_active_rounded, // Airplane icon
                color: Colors.white, // Icon color
                size: 50, // Icon size
              ),
            ),
            const SizedBox(height: 30), // Spacer below logo
            // App name text
            const Text(
              'Travely', // App title
              style: TextStyle(
                fontSize: 42, // Large font size
                fontWeight: FontWeight.w800, // Extra bold
                color: Colors.white, // White text
                letterSpacing: -0.5, // Slight negative spacing
              ),
            ),
            const SizedBox(height: 10), // Spacer below title
            // Subtitle text
            const Text(
              'Find your perfect escape', // Subtitle
              style: TextStyle(
                fontSize: 16, // Smaller font
                color: Colors.white70, // Semi-transparent white
                fontWeight: FontWeight.w500, // Medium weight
              ),
            ),
          ],
        ),
      ),
    );
  }
}
