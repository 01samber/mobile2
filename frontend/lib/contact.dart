import 'package:flutter/material.dart';
// Material UI components (Scaffold, AppBar, Buttons, TextFields)

import 'dart:convert';
// Used to convert Dart Map -> JSON when sending data to backend

import 'package:http/http.dart' as http;
// Used to send HTTP requests (POST request to server)

import 'package:animations/animations.dart';
// Provides smooth Material animations (OpenContainer)

/// ==============================
/// CONTACT PAGE WIDGET
/// ==============================
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

/// ==============================
/// PAGE STATE (LOGIC + UI)
/// ==============================
class _ContactPageState extends State<ContactPage> {
  // Controllers hold what the user types in the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Controls loading state (spinner + disabled button)
  bool isLoading = false;

  // Used to validate the form
  final _formKey = GlobalKey<FormState>();

  /// ==============================
  /// SEND MESSAGE FUNCTION
  /// ==============================
  Future<void> sendMessage() async {
    // If validation fails, stop here
    if (!_formKey.currentState!.validate()) return;

    // Show loading spinner
    setState(() => isLoading = true);

    try {
      // Send POST request to backend
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/contact"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "message": _messageController.text.trim(),
        }),
      );

      // Stop loading spinner
      setState(() => isLoading = false);

      // Success response
      if (response.statusCode == 200) {
        _showSuccessDialog();

        // Clear form fields
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } else {
        _showErrorDialog('Failed to send message');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('Network error occurred');
    }
  }

  /// ==============================
  /// SUCCESS BOTTOM SHEET
  /// ==============================
  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green circle with check icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 24),

              // Title text
              const Text(
                'Message Sent!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 12),

              // Subtitle text
              Text(
                'Our team will get back to you within 24 hours',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 30),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Continue Exploring'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ==============================
  /// ERROR DIALOG
  /// ==============================
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Oops!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// MAIN UI
  /// ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// -------- APP BAR --------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey.shade800,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contact Us',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ),

      /// -------- FORM BODY --------
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// HERO CARD
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: const [
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Text(
                        '24/7 Support\nWe\'re always here to help you',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: Icon(
                        Icons.support_agent_rounded,
                        size: 80,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              /// INPUT FIELDS
              _buildTextField(
                _nameController,
                'Full Name',
                Icons.person,
                (v) => v!.isEmpty ? 'Please enter your name' : null,
              ),

              const SizedBox(height: 20),

              _buildTextField(_emailController, 'Email Address', Icons.email, (
                v,
              ) {
                if (v!.isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              }),

              const SizedBox(height: 20),

              _buildTextField(
                _messageController,
                'Your Message',
                Icons.message,
                (v) => v!.length < 10
                    ? 'Message must be at least 10 characters'
                    : null,
                maxLines: 5,
              ),

              const SizedBox(height: 40),

              /// SUBMIT BUTTON WITH ANIMATION
              OpenContainer(
                closedElevation: 0,
                closedColor: Colors.transparent,
                closedBuilder: (context, action) {
                  return ElevatedButton(
                    onPressed: isLoading ? null : sendMessage,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Send Message'),
                  );
                },
                openBuilder: (context, action) {
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ==============================
  /// REUSABLE TEXT FIELD
  /// ==============================
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    FormFieldValidator<String>? validator, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
