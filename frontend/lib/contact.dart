import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Q: Why separate into StatefulWidget vs StatelessWidget?
// A: ContactPage needs to maintain form state (text controllers, loading state, validation).
// StatefulWidget is necessary when the widget needs to:
// 1. Manage form input state
// 2. Track loading/error states
// 3. Handle asynchronous operations (API calls)
// 4. Respond to user interactions with state changes
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // Q: Why use GlobalKey for the form?
  // A: GlobalKey allows us to access FormState from anywhere in the widget tree.
  // This enables programmatic validation (.validate()) and state management.
  // Alternative: Using Form.of(context) with Builder widget, but GlobalKey is more direct.
  final _formKey = GlobalKey<FormState>();

  // Q: Why use TextEditingController instead of onChanged callbacks?
  // A: TextEditingController provides more control:
  // 1. Programmatic text manipulation (clear, set text)
  // 2. Listen to text changes without rebuilding entire widget
  // 3. Better separation of concerns (business logic from UI)
  // Important: Always dispose controllers to prevent memory leaks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool isLoading = false;

  // Q: Why make this function async instead of using callbacks?
  // A: async/await provides cleaner, more readable code for sequential operations.
  // It avoids "callback hell" and makes error handling more straightforward with try/catch.
  Future<void> sendMessage() async {
    // Q: Why validate before API call?
    // A: Client-side validation reduces unnecessary API calls and provides
    // immediate feedback to users. Server should still validate for security.
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Q: Why hardcode localhost URL? What about production?
      // A: This should be configurable via environment variables or a config file.
      // In production, use a base URL constant or dependency injection.
      // Consider: const String baseUrl = "https://api.yourdomain.com";
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/contact"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "message": _messageController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      // Q: Why check status code 200? What about other success codes?
      // A: REST APIs may return 200 (OK), 201 (Created), or 204 (No Content).
      // Best practice: Check for response.statusCode >= 200 && response.statusCode < 300
      if (response.statusCode == 200) {
        // Q: Why use ScaffoldMessenger instead of showDialog?
        // A: ScaffoldMessenger provides temporary, non-blocking notifications.
        // SnackBars are better for success/error messages that don't require user action.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Message sent successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } else {
        // Q: What about parsing error messages from the server?
        // A: The server may return specific error messages in the response body.
        // Consider: json.decode(response.body)['error'] for more detailed feedback.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send message."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      // Q: What types of exceptions can occur here?
      // A: Network errors (SocketException), JSON encoding errors, timeout errors.
      // Consider: Implement retry logic or more specific error handling.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Q: Should we override dispose() to clean up controllers?
  // A: YES! Always dispose controllers to prevent memory leaks.
  // Add: @override void dispose() { _nameController.dispose(); ... super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Q: What does extendBodyBehindAppBar do?
      // A: It makes the AppBar transparent and allows the body content to extend behind it.
      // This creates a modern, immersive UI design.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Removes shadow for cleaner look
        title: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            "Contact Us",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        // Q: Why use gradient instead of solid color?
        // A: Gradients provide visual depth and modern aesthetics.
        // Performance consideration: Gradients are GPU-accelerated and perform well.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5D54A4), // Purple
              Color(0xFF9A57BD), // Magenta
              Color(0xFFF28EC4), // Pink
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Q: Why use specific padding values?
        // A: top: 120 accounts for AppBar height + extra space.
        // This ensures content doesn't hide behind AppBar while maintaining visual hierarchy.
        padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Name", TextInputType.text),
              const SizedBox(height: 20), // Consistent spacing
              _buildTextField(
                _emailController,
                "Email",
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _messageController,
                "Message",
                TextInputType.multiline,
                maxLines: 5,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : sendMessage,
                // Q: Why disable button during loading?
                // A: Prevents duplicate submissions and gives visual feedback that action is in progress.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 12, // Shadow for depth
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Send Message",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Q: Why extract TextFormField into a separate method?
  // A: Reduces code duplication, improves maintainability, and ensures consistent styling.
  // This is a common pattern for reusable form fields.
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
        ), // 70% opacity for subtlety
        filled: true,
        fillColor: Colors.white.withOpacity(0.18), // Semi-transparent white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none, // Removes default border
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label cannot be empty";
        }
        // Q: What about additional validation for email field?
        // A: Should add email format validation using regex or validator package.
        // Example for email: if (!EmailValidator.validate(value)) return "Invalid email";
        return null;
      },
    );
  }

  // MISSING DISPOSE METHOD - IMPORTANT FOR PRODUCTION:
  // @override
  // void dispose() {
  //   _nameController.dispose();
  //   _emailController.dispose();
  //   _messageController.dispose();
  //   super.dispose();
  // }

  // IMPROVEMENTS FOR PRODUCTION:
  // 1. Add email format validation
  // 2. Implement form state persistence (auto-save drafts)
  // 3. Add character counters for message field
  // 4. Implement debouncing for button presses
  // 5. Use a state management solution (Provider, Riverpod, Bloc) for complex forms
  // 6. Add accessibility labels and semantics
  // 7. Implement theme-aware colors (Theme.of(context).colorScheme)
  // 8. Add internationalization (i18n) support
  // 9. Implement proper error handling with retry options
  // 10. Add analytics for form submissions
}
