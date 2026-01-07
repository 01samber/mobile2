import 'package:flutter/material.dart'; // Start: Flutter UI components (widgets like Scaffold, Text, Icon, etc.)
import 'contact.dart'; // ContactPage navigation (opens a separate page)
import 'newPage.dart'; // NewPage for detailed destination view
import 'dart:convert'; // JSON decoding for API response
import 'package:http/http.dart' as http; // HTTP requests to fetch data
// End Imports

// Start: Main Stateful Widget
class ListViewDemo extends StatefulWidget {
  const ListViewDemo({super.key});

  @override
  State<ListViewDemo> createState() => _ListViewDemoState();
}
// End: Main Stateful Widget

// Start: State class
class _ListViewDemoState extends State<ListViewDemo> {
  // Start: State Variables
  List<Map<String, dynamic>> places =
      []; // Stores the list of destinations from API
  bool isLoading = true; // Shows loading spinner while fetching data
  int selectedCategory = 0; // Tracks which category filter is selected
  final List<String> categories = [
    // Quick filter names
    'Hotels', 'Flights', 'Vacation', 'Car', 'Activities',
  ];
  final List<IconData> categoryIcons = [
    // Icons for quick filter buttons
    Icons.hotel, Icons.flight, Icons.beach_access,
    Icons.directions_car, Icons.local_activity,
  ];
  // End: State Variables

  // Start: Initialize and fetch data
  @override
  void initState() {
    super.initState();
    fetchDestinations(); // Fetch API data as soon as the page loads
  }

  // Start: Fetch destinations from backend
  Future<void> fetchDestinations() async {
    try {
      // HTTP GET request to fetch destinations from backend API
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/destinations"),
      );

      if (response.statusCode == 200) {
        // Success
        final List data = json.decode(response.body); // Decode JSON response

        setState(() {
          // Map API data into a usable list of maps
          places = data
              .map(
                (item) => {
                  "id": item["id"],
                  "country": item["country"] ?? "Unknown",
                  "price": item["price"]?.toString() ?? "0",
                  "image":
                      item["image_url"] ??
                      "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&auto=format&fit=crop", // Default image
                  "rating": (item["rating"] ?? 4.5).toDouble(),
                  "reviews": item["reviews"] ?? 120,
                  "category": item["category"] ?? "Beach",
                  "distance": item["distance"] ?? "2.3 km from center",
                  "amenities": ["WiFi", "Pool", "Breakfast", "Parking"],
                },
              )
              .toList();
          isLoading = false; // Stop showing spinner
        });
      } else {
        setState(() => isLoading = false); // Stop spinner on error
      }
    } catch (e) {
      setState(() => isLoading = false); // Stop spinner on network failure
    }
  }
  // End: Fetch destinations

  // Start: Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(), // iOS-style scroll physics
          slivers: [
            // Start: App Bar
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              floating: false,
              pinned: true, // App bar sticks at the top
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                titlePadding: const EdgeInsets.only(left: 16, bottom: 10),
                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF003B95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.explore,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Travel.com',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003B95),
                          ),
                        ),
                        Text(
                          'Find your perfect stay',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // Navigate to Contact Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactPage()),
                    );
                  },
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            // End: App Bar

            // Start: Search & Quick Filters Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search Bar (user can type destination)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Icon(
                                Icons.search,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Where are you going?',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF003B95),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 18,
                                ), // Filter options icon
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Quick Filters (horizontal list of categories)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: selectedCategory == index
                                          ? const Color(
                                              0xFF003B95,
                                            ).withOpacity(0.1)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: selectedCategory == index
                                            ? const Color(0xFF003B95)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      categoryIcons[index],
                                      color: selectedCategory == index
                                          ? const Color(0xFF003B95)
                                          : Colors.grey.shade700,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    categories[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: selectedCategory == index
                                          ? const Color(0xFF003B95)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // End: Search & Quick Filters

            // Start: Trending Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trending Destinations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {}, // Could navigate to full list
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF003B95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // End: Trending Section Header

            // Start: Loading State
            if (isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: const Color(0xFF003B95),
                        strokeWidth: 1.5,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Finding best stays...', // Feedback while fetching data
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Start: Destinations Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, // Single column
                    mainAxisSpacing: 16, // Vertical spacing
                    crossAxisSpacing: 0, // No horizontal spacing
                    childAspectRatio: 1.2, // Card height ratio
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final place = places[index]; // Each destination
                    return _buildDestinationCard(context, place); // Build card
                  }, childCount: places.length),
                ),
              ),
            // End: Destinations Grid

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // Start: Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.search, 'Explore', true),
                _buildNavItem(Icons.favorite_border, 'Saved', false),
                _buildNavItem(Icons.receipt, 'Bookings', false),
                _buildNavItem(Icons.notifications_none, 'Alerts', false),
                _buildNavItem(Icons.person_outline, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
      // End: Bottom Navigation Bar
    );
  }
  // End: Build UI

  // Start: Bottom Nav Item Builder
  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF003B95) : Colors.grey.shade600,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF003B95) : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  // End: Bottom Nav Item Builder

  // Start: Destination Card Builder
  Widget _buildDestinationCard(
    BuildContext context,
    Map<String, dynamic> place,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to destination detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                NewPage(destinationId: place["id"], title: place["country"]),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start: Image with badges
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    place["image"],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                  // Top Badge ("Genius Deal")
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003B95),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Genius Deal',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFF003B95),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place["rating"].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${place["reviews"]})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Distance Badge
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place["distance"],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // End: Image with badges

            // Start: Card Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place["country"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${place["price"]}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003B95),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${place["category"]} Hotel • Central location',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.wifi, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Free WiFi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.pool, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Pool',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.free_breakfast,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Breakfast',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF003B95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'View Deal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // End: Card Content
          ],
        ),
      ),
    );
  }

  // End: Destination Card Builder
}

// End: State Class
