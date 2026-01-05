import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Q: Why make this a StatefulWidget?
// A: This page needs to:
// 1. Manage form state (night count, options selections)
// 2. Fetch data asynchronously from API
// 3. Handle user interactions that update the UI
// 4. Calculate dynamic pricing based on user selections
class NewPage extends StatefulWidget {
  final int destinationId;
  final String title;

  const NewPage({super.key, required this.destinationId, required this.title});

  // Q: Why pass parameters via constructor instead of using routes/arguments?
  // A: Constructor parameters provide:
  // 1. Type safety (compiler ensures correct types)
  // 2. Better IDE support (autocomplete, refactoring)
  // 3. Clear dependencies at compile time
  // Named routes with arguments are better for deep linking and navigation tracking

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  // Q: Why initialize state with default values?
  // A: Provides sensible defaults that prevent null errors
  // and give users a starting point for interaction
  int nightCount = 1;
  bool breakfast = false;
  bool seaView = false;

  // Q: Why use nullable selectedHotel instead of requiring first item?
  // A: Defensive programming - the hotel list might be empty
  // Prevents crashes if API returns no hotels for a destination
  List<Map<String, dynamic>> hotels = [];
  Map<String, dynamic>? selectedHotel;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    try {
      // Q: Why not handle the base URL as a configurable constant?
      // A: Hardcoding localhost makes deployment difficult
      // Better: const String baseUrl = "https://api.example.com";
      // Or use dependency injection to provide API base URL
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/hotels/${widget.destinationId}"),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          hotels = data
              .map(
                (item) => {
                  "id": item["id"],
                  "name": item["name"],
                  "price": item["price_per_night"].toString(),
                },
              )
              .toList();
          // Q: Why auto-select first hotel? Should we let user decide?
          // A: Auto-selection provides better UX - user sees pricing immediately
          // But could be confusing if user doesn't realize a selection was made
          if (hotels.isNotEmpty) selectedHotel = hotels[0];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        // Q: Should we show this error to users?
        // A: Yes, but with a user-friendly message and retry option
        // Consider: showDialog with error details and retry button
        throw Exception("Failed to load hotels");
      }
    } catch (e) {
      setState(() => isLoading = false);
      // Q: Why print instead of proper error handling?
      // A: Printing is for debugging only. In production:
      // 1. Log to analytics/crash reporting
      // 2. Show user-friendly error UI
      // 3. Provide retry mechanism
      print("Error fetching hotels: $e");
    }
  }

  // Q: Why create a separate function for price calculation?
  // A: Separation of concerns - business logic separate from UI
  // Makes code more testable and maintainable
  // Could be extracted to a separate service/utility class
  double getTotalPrice() {
    if (selectedHotel == null) return 0;
    // Q: Why use tryParse instead of direct cast?
    // A: tryParse handles malformed or non-numeric strings gracefully
    // Returns null instead of throwing exception
    double basePrice = double.tryParse(selectedHotel!["price"]) ?? 0;
    double extras = 0;
    if (breakfast) extras += 20;
    if (seaView) extras += 30;
    // Q: Is this pricing logic appropriate for production?
    // A: Pricing should come from server, not hardcoded
    // Extras should be configurable and possibly vary by hotel
    return (basePrice + extras) * nightCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A4BAF), // Dark purple
              Color(0xFFB86AD9), // Medium purple
              Color(0xFFF59CC3), // Light pink
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                // Q: Why use SingleChildScrollView instead of ListView?
                // A: SingleChildScrollView is simpler for static content layouts
                // ListView is better for dynamic lists with many items
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 30),
                child: Column(
                  children: [
                    _hotelDropdown(),
                    const SizedBox(height: 25),
                    if (selectedHotel != null)
                      _infoCard(
                        child: Text(
                          "\$${getTotalPrice().toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    _infoCard(
                      child: _counter(
                        title: "Nights",
                        count: nightCount,
                        onMinus: () {
                          if (nightCount > 1) setState(() => nightCount--);
                        },
                        onPlus: () => setState(() => nightCount++),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _infoCard(
                      child: _toggle(
                        label: "Breakfast Included (+\$20)",
                        value: breakfast,
                        onChanged: (v) => setState(() => breakfast = v),
                        activeColor: Colors.pinkAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _infoCard(
                      child: _toggle(
                        label: "Ocean View (+\$30)",
                        value: seaView,
                        onChanged: (v) => setState(() => seaView = v),
                        activeColor: Colors.lightBlueAccent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _bookButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _hotelDropdown() {
    return _infoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Hotel",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<Map<String, dynamic>>(
            isExpanded: true, // Makes dropdown fill available width
            value: selectedHotel,
            dropdownColor: Colors.deepPurple.shade700,
            underline: const SizedBox(), // Removes default underline
            items: hotels.map((hotel) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: hotel,
                child: Text(
                  "${hotel["name"]} (\$${hotel["price"]})",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => selectedHotel = v),
            iconEnabledColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // Q: Why extract _infoCard as a separate widget?
  // A: Creates consistent styling across all cards
  // Reduces code duplication and makes styling changes easier
  // Could be made more flexible with additional parameters (padding, margin, etc.)
  Widget _infoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(1, 3),
            color: Colors.black.withOpacity(0.18),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _counter({
    required String title,
    required int count,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.redAccent,
              onPressed: onMinus,
              // Q: Should we disable button when count == 1?
              // A: Current implementation prevents going below 1
              // Visual feedback (disabled state) would improve UX
            ),
            Text(
              "$count",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.greenAccent,
              onPressed: onPlus,
              // Q: Should there be a maximum limit?
              // A: Consider business constraints (max 30 nights, etc.)
            ),
          ],
        ),
      ],
    );
  }

  Widget _toggle({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required Color activeColor,
  }) {
    return SwitchListTile(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      value: value,
      activeColor: activeColor,
      onChanged: onChanged,
    );
  }

  Widget _bookButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 12,
      ),
      onPressed: () {
        // Q: What validation is missing here?
        // A: Should validate:
        // 1. Hotel is selected (already checked)
        // 2. User is logged in (for real booking system)
        // 3. Payment method is available
        // 4. Dates are valid
        if (selectedHotel == null) return;

        // Q: Is a SnackBar sufficient for booking confirmation?
        // A: No - this should trigger a real booking flow:
        // 1. Show confirmation dialog with details
        // 2. Navigate to payment screen
        // 3. Send booking to backend API
        // 4. Show success/failure result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pinkAccent,
            content: Text(
              "Booked $nightCount night(s) at ${selectedHotel!["name"]} "
              "${breakfast ? " + breakfast" : ""}"
              "${seaView ? " + ocean view" : ""} 🌍✨\n"
              "Total: \$${getTotalPrice().toStringAsFixed(2)}",
            ),
          ),
        );
      },
      child: const Text(
        "Book Now",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // PRODUCTION IMPROVEMENTS:

  // 1. ERROR HANDLING:
  // - Add error state UI with retry option
  // - Implement proper exception handling
  // - Log errors to analytics

  // 2. VALIDATION:
  // - Add form validation
  // - Validate hotel selection
  // - Add date range validation

  // 3. STATE MANAGEMENT:
  // - Extract booking logic to a separate class/Bloc/Cubit
  // - Handle booking state (loading, success, error)

  // 4. UI/UX IMPROVEMENTS:
  // - Add hotel details (images, amenities, ratings)
  // - Implement date picker for check-in/check-out
  // - Add loading states for button
  // - Add confirmation dialog before booking

  // 5. PERFORMANCE:
  // - Cache hotel data
  // - Use const constructors where possible
  // - Implement proper dispose methods

  // 6. ACCESSIBILITY:
  // - Add semantic labels
  // - Ensure sufficient color contrast
  // - Support screen readers
}
