// Start: Imports
import 'package:flutter/material.dart'; // Flutter Material Design widgets
import 'dart:convert'; // JSON decoding for API responses
import 'package:http/http.dart' as http; // HTTP package for REST API requests
import 'package:animations/animations.dart'; // Provides OpenContainer for smooth transitions
// End: Imports

// Start: NewPage Widget (Stateful because it has dynamic state like selected hotel)
class NewPage extends StatefulWidget {
  final int destinationId; // ID of the destination to fetch hotels for
  final String title; // Title displayed on the page (e.g., country or city)

  const NewPage({super.key, required this.destinationId, required this.title});

  @override
  State<NewPage> createState() => _NewPageState(); // Create mutable state
}
// End: NewPage Widget

// Start: _NewPageState Class
class _NewPageState extends State<NewPage> {
  // State variables
  int nightCount = 1; // Number of nights selected
  bool breakfast = true; // Whether breakfast is added
  bool seaView = false; // Whether sea view is added
  bool spa = false; // Whether spa is added
  List<Map<String, dynamic>> hotels = []; // List of hotels fetched from API
  Map<String, dynamic>? selectedHotel; // Currently selected hotel
  bool isLoading = true; // Loading state for API call

  // initState runs when the page is first created
  @override
  void initState() {
    super.initState();
    fetchHotels(); // Fetch hotel data from API
  }

  // Start: Fetch hotels from backend API
  Future<void> fetchHotels() async {
    try {
      // Make GET request using the destination ID
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/hotels/${widget.destinationId}"),
      );

      if (response.statusCode == 200) {
        // Successful response
        final List data = json.decode(response.body); // Decode JSON array

        setState(() {
          hotels = data
              .map(
                (item) => {
                  "id": item["id"],
                  "name": item["name"],
                  "price": item["price_per_night"].toString(),
                  "rating": (item["rating"] ?? 4.0).toDouble(),
                  "image":
                      item["image"] ??
                      "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop",
                  "amenities": ["Pool", "Spa", "WiFi", "Breakfast"],
                },
              )
              .toList();
          if (hotels.isNotEmpty) selectedHotel = hotels[0]; // Default selection
          isLoading = false; // Stop loading spinner
        });
      } else {
        setState(() => isLoading = false); // Stop loading if error
      }
    } catch (e) {
      setState(() => isLoading = false); // Stop loading if exception
    }
  }
  // End: Fetch hotels

  // Start: Calculate total price including add-ons
  double getTotalPrice() {
    if (selectedHotel == null) return 0;
    double basePrice = double.tryParse(selectedHotel!["price"]) ?? 0;
    double extras = 0;
    if (breakfast) extras += 25;
    if (seaView) extras += 40;
    if (spa) extras += 35;
    return (basePrice + extras) * nightCount; // Total price
  }
  // End: Calculate total price

  // Start: Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              // Show spinner while loading
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : CustomScrollView(
              slivers: [
                // Start: Hero Image with AppBar
                SliverAppBar(
                  expandedHeight: 300, // Height when expanded
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true, // AppBar stays visible when scrolled
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      selectedHotel?["image"] ??
                          "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop",
                      fit: BoxFit.cover,
                    ),
                  ),
                  leading: Container(
                    // Back button styling
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context), // Go back
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  actions: [
                    // Favorite button
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                // End: Hero Image with AppBar

                // Start: Content Section
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30), // Rounded top corners
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel Name and Rating Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedHotel?["name"] ?? "Luxury Resort",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              // Rating badge
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber.shade700,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    selectedHotel?["rating"].toString() ??
                                        "4.5",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title, // Destination title
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Start: Room Selection Section
                        _buildSection(
                          'Select Your Room',
                          Column(
                            children: hotels.map((hotel) {
                              return OpenContainer(
                                // Smooth container animation
                                closedElevation: 0,
                                closedBuilder: (context, action) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: selectedHotel == hotel
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1)
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: selectedHotel == hotel
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: ListTile(
                                      // Hotel details
                                      onTap: () {
                                        setState(() => selectedHotel = hotel);
                                      },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          hotel["image"],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        hotel["name"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '\$${hotel["price"]} per night',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      trailing: selectedHotel == hotel
                                          ? Icon(
                                              Icons.check_circle_rounded,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            )
                                          : null,
                                    ),
                                  );
                                },
                                openBuilder: (context, action) =>
                                    const SizedBox(),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 25),
                        // End: Room Selection

                        // Start: Duration Section
                        _buildSection(
                          'Duration',
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$nightCount night${nightCount > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    // Decrease nights
                                    onPressed: nightCount > 1
                                        ? () => setState(() => nightCount--)
                                        : null,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      disabledBackgroundColor:
                                          Colors.grey.shade300,
                                    ),
                                    icon: Icon(
                                      Icons.remove_rounded,
                                      color: nightCount > 1
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    // Increase nights
                                    onPressed: () =>
                                        setState(() => nightCount++),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        // End: Duration Section

                        // Start: Add-ons Section
                        _buildSection(
                          'Add-ons',
                          Column(
                            children: [
                              _buildAddon(
                                'Breakfast Buffet',
                                '+ \$25/night',
                                'Start your day with a premium buffet',
                                breakfast,
                                Icons.coffee_rounded,
                                (value) => setState(() => breakfast = value),
                              ),
                              _buildAddon(
                                'Ocean View Room',
                                '+ \$40/night',
                                'Breathtaking sea views',
                                seaView,
                                Icons.visibility_rounded,
                                (value) => setState(() => seaView = value),
                              ),
                              _buildAddon(
                                'Spa Access',
                                '+ \$35/night',
                                'Unlimited spa and wellness access',
                                spa,
                                Icons.spa_rounded,
                                (value) => setState(() => spa = value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // End: Add-ons Section

                        // Start: Price Breakdown Section
                        _buildSection(
                          'Price Breakdown',
                          Column(
                            children: [
                              _buildPriceRow(
                                'Room',
                                '\$${selectedHotel != null ? (double.parse(selectedHotel!["price"]) * nightCount).toStringAsFixed(2) : "0"}',
                              ),
                              if (breakfast)
                                _buildPriceRow(
                                  'Breakfast',
                                  '\$${(25 * nightCount).toStringAsFixed(2)}',
                                ),
                              if (seaView)
                                _buildPriceRow(
                                  'Ocean View',
                                  '\$${(40 * nightCount).toStringAsFixed(2)}',
                                ),
                              if (spa)
                                _buildPriceRow(
                                  'Spa Access',
                                  '\$${(35 * nightCount).toStringAsFixed(2)}',
                                ),
                              const Divider(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '\$${getTotalPrice().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // End: Price Breakdown Section

                        // Start: Book Now Button
                        OpenContainer(
                          closedElevation: 0,
                          closedBuilder: (context, action) {
                            return Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _showBookingConfirmation(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.confirmation_number_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Book Now',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          openBuilder: (context, action) => const SizedBox(),
                        ),
                        // End: Book Now Button
                      ],
                    ),
                  ),
                ),
                // End: Content Section
              ],
            ),
    );
  }
  // End: Build UI

  // Start: Helper widget for section titles
  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
  // End: _buildSection

  // Start: Helper widget for add-ons
  Widget _buildAddon(
    String title,
    String price,
    String description,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: value
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: value
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: value
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: value ? Colors.white : Colors.grey),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
  // End: _buildAddon

  // Start: Helper for price row
  Widget _buildPriceRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          Text(
            price,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
  // End: _buildPriceRow

  // Start: Show booking confirmation modal
  void _showBookingConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Success Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Title
                    const Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Details
                    Text(
                      '${selectedHotel?["name"] ?? "Luxury Resort"} • $nightCount night${nightCount > 1 ? "s" : ""}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Price
                    Text(
                      '\$${getTotalPrice().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Buttons: Continue or Done
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Text(
                              'Continue Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Done',
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // End: _showBookingConfirmation
}

// End: _NewPageState Class
