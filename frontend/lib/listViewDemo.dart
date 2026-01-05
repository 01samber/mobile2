import 'package:flutter/material.dart';
import 'newPage.dart';
import 'contact.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Q: Why create a StatefulWidget instead of StatelessWidget?
// A: This widget needs to:
// 1. Fetch data asynchronously from an API
// 2. Manage loading state
// 3. Maintain a list of places in state
// 4. Rebuild UI when data changes
class ListViewDemo extends StatefulWidget {
  const ListViewDemo({super.key});

  @override
  State<ListViewDemo> createState() => _ListViewDemoState();
}

class _ListViewDemoState extends State<ListViewDemo> {
  // Q: Why use List<Map<String, dynamic>> instead of a typed model class?
  // A: Using a typed model (class Destination) would be better for:
  // 1. Type safety and compile-time checks
  // 2. Better IDE support (autocomplete, refactoring)
  // 3. Cleaner code with named constructors fromJson/toJson
  // 4. Easier maintenance as the data structure evolves
  List<Map<String, dynamic>> places = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDestinations();
  }

  // Q: Why call API in initState instead of using FutureBuilder?
  // A: initState approach is good when:
  // 1. You need to control the loading state precisely
  // 2. You want to cache the data for the widget's lifetime
  // 3. You need to handle errors with custom UI
  // FutureBuilder is simpler but offers less control
  Future<void> fetchDestinations() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/destinations"),
      );

      // Q: Why check status code 200? What about other success codes?
      // A: REST APIs typically use 200 for GET success. However, best practice is to check:
      // if (response.statusCode >= 200 && response.statusCode < 300)
      // This handles 200, 201, 204, etc.
      if (response.statusCode == 200) {
        // Q: Why parse as List<dynamic> first?
        // A: json.decode returns dynamic, and we need to cast it to List
        // This approach assumes the API always returns a list
        final List data = json.decode(response.body);

        setState(() {
          // Q: Why use map with fallback values?
          // A: This provides resilience against missing/null data from the API
          // Prevents app crashes if the API response structure changes
          places = data
              .map(
                (item) => {
                  "id": item["id"],
                  "country":
                      item["country"] ?? "Unknown", // Null-aware operator
                  "price":
                      item["price"]?.toString() ?? "0", // Convert to string
                  "image":
                      item["image_url"] ??
                      "https://picsum.photos/seed/default/500/500.jpg", // Fallback image
                },
              )
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        // Q: Should we show this error to the user?
        // A: Yes, but not as a raw exception. Better to show a user-friendly message
        // and log the technical details for debugging
        throw Exception("Failed to load destinations");
      }
    } catch (e) {
      setState(() => isLoading = false);
      // Q: Why print instead of showing to user?
      // A: Printing is for debugging. In production, consider:
      // 1. Logging to analytics/crash reporting service
      // 2. Showing a user-friendly error message with retry option
      print("Error fetching destinations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Q: What's the purpose of extendBodyBehindAppBar?
      // A: Makes the AppBar transparent so the gradient background shows through
      // Creates a modern, immersive design
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow for clean look
        title: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Travel Destinations',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          // Q: Why use IconButton with empty onPressed?
          // A: This creates a placeholder for future functionality
          // Better: Remove or disable if not functional yet
          IconButton(
            icon: const Icon(Icons.airplanemode_active, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.contact_page, color: Colors.white),
            onPressed: () {
              // Q: Why use MaterialPageRoute instead of named routes?
              // A: MaterialPageRoute is fine for simple navigation
              // Named routes are better for:
              // 1. Centralized route management
              // 2. Deep linking support
              // 3. Type-safe navigation with arguments
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5D54A4), Color(0xFF9A57BD), Color(0xFFF28EC4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 90),
          // Q: Why use top: 90 padding?
          // A: Creates space below the AppBar so content doesn't get hidden
          // Should be responsive: MediaQuery.of(context).padding.top + kToolbarHeight
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : ListView.separated(
                  // Q: Why ListView.separated instead of ListView.builder?
                  // A: ListView.separated automatically adds separators between items
                  // More efficient than adding SizedBox widgets manually in itemBuilder
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  itemCount: places.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    return _buildPlaceTile(context, places[index]);
                  },
                ),
        ),
      ),
    );
  }

  // Q: Why extract tile building to a separate method?
  // A: Improves code readability, reduces build method complexity, and makes tile reusable
  Widget _buildPlaceTile(BuildContext context, Map<String, dynamic> place) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20), // Semi-transparent white
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
        ), // Subtle border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(1, 2), // Creates depth
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            place["image"],
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            // Q: What about error handling for failed image loads?
            // A: Should add errorBuilder parameter:
            // errorBuilder: (context, error, stackTrace) => Icon(Icons.error)
            // Or use CachedNetworkImage package for better performance
          ),
        ),
        title: Text(
          place["country"],
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "Price: \$${place["price"]}",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70, // 70% opacity for subtlety
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.white70,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  NewPage(destinationId: place["id"], title: place["country"]),
            ),
          );
        },
      ),
    );
  }

  // Q: What about pull-to-refresh functionality?
  // A: Consider adding RefreshIndicator for better UX:
  // Wrap ListView.separated with RefreshIndicator(onRefresh: fetchDestinations)

  // Q: What about empty state handling?
  // A: Add condition: if (places.isEmpty && !isLoading) show "No destinations available"

  // Q: Should we add dispose method?
  // A: Not needed here since we don't have controllers or streams
  // But good practice to cancel any pending async operations if needed

  // PRODUCTION IMPROVEMENTS:
  // 1. Implement error state UI with retry button
  // 2. Add pull-to-refresh with RefreshIndicator
  // 3. Use Image.network with errorBuilder and loadingBuilder
  // 4. Implement pagination for large datasets
  // 5. Add search/filter functionality
  // 6. Cache API responses for offline support
  // 7. Use a state management solution for shared data
  // 8. Add analytics for item taps
  // 9. Implement proper null safety throughout
  // 10. Use responsive design for different screen sizes
}
