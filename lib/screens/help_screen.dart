import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(
            leading: Icon(Icons.support_agent, size: 40, color: Colors.blue),
            title: Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Support available 24/7"),
          ),
          const SizedBox(height: 16),
          _buildFaqItem("How do I add a new customer?", "Tap the 'Add Customer' button on the Home screen."),
          _buildFaqItem("What is Advance vs Due?", "Advance means the customer owes you money (you will get). Due means you owe the customer money (you will give)."),
          _buildFaqItem("Can I export to PDF?", "This feature is coming soon!"),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat),
            label: const Text("Live Chat"),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(answer, style: const TextStyle(color: Colors.black54)),
        )
      ],
    );
  }
}
