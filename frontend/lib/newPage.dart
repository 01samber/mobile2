import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewPage extends StatefulWidget {
  final int destinationId;
  final String title;

  const NewPage({
    super.key,
    required this.destinationId,
    required this.title,
  });

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  int nightCount = 1;
  bool breakfast = false;
  bool seaView = false;

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
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/hotels/${widget.destinationId}"),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          hotels = data
              .map((item) => {
                    "id": item["id"],
                    "name": item["name"],
                    "price": item["price_per_night"].toString(),
                  })
              .toList();
          if (hotels.isNotEmpty) selectedHotel = hotels[0];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception("Failed to load hotels");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching hotels: $e");
    }
  }

  double getTotalPrice() {
    if (selectedHotel == null) return 0;
    double basePrice = double.tryParse(selectedHotel!["price"]) ?? 0;
    double extras = 0;
    if (breakfast) extras += 20;
    if (seaView) extras += 30;
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
              Color(0xFF6A4BAF),
              Color(0xFFB86AD9),
              Color(0xFFF59CC3),
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
            isExpanded: true,
            value: selectedHotel,
            dropdownColor: Colors.deepPurple.shade700,
            underline: const SizedBox(),
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
        if (selectedHotel == null) return;
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
}