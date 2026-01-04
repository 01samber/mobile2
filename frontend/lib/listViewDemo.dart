import 'package:flutter/material.dart';
import 'newPage.dart';
import 'contact.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ListViewDemo extends StatefulWidget {
  const ListViewDemo({super.key});

  @override
  State<ListViewDemo> createState() => _ListViewDemoState();
}

class _ListViewDemoState extends State<ListViewDemo> {
  List<Map<String, dynamic>> places = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDestinations();
  }

  Future<void> fetchDestinations() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:5000/api/destinations"));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          places = data.map((item) => {
            "id": item["id"],
            "country": item["country"] ?? "Unknown",
            "price": item["price"]?.toString() ?? "0",
            "image": item["image_url"] ??
                "https://picsum.photos/seed/default/500/500.jpg",
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception("Failed to load destinations");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching destinations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          IconButton(
            icon: const Icon(Icons.airplanemode_active, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.contact_page, color: Colors.white),
            onPressed: () {
              // Navigate to contact page using MaterialPageRoute
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
            colors: [
              Color(0xFF5D54A4),
              Color(0xFF9A57BD),
              Color(0xFFF28EC4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 90),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

  Widget _buildPlaceTile(BuildContext context, Map<String, dynamic> place) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            place["image"],
            width: 58,
            height: 58,
            fit: BoxFit.cover,
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
            color: Colors.white70,
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
              builder: (_) => NewPage(
                destinationId: place["id"],
                title: place["country"],
              ),
            ),
          );
        },
      ),
    );
  }
}