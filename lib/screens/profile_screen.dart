import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text("User ID"),
            subtitle: Text(provider.currentUserId ?? 'Not logged in'),
            leading: const Icon(Icons.fingerprint),
          ),
          const Divider(),
          const ListTile(
            title: Text("Business Name"),
            subtitle: Text("My Awesome Business"),
            leading: Icon(Icons.store),
            trailing: Icon(Icons.edit, size: 20),
          ),
          const Divider(),
          const ListTile(
            title: Text("Phone Number"),
            subtitle: Text("+880 1234 567890"),
            leading: Icon(Icons.phone),
            trailing: Icon(Icons.edit, size: 20),
          ),
        ],
      ),
    );
  }
}
