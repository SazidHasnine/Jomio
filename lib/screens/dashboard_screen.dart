import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jomio', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {})
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _buildSummaryCard(context, provider),
              const Divider(height: 1),
              _buildSearchBar(),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.customers.length,
                  itemBuilder: (context, index) {
                    final customer = provider.customers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: Text(customer.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                      ),
                      title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text("Tap to view details", style: TextStyle(fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "৳ ${customer.balance.abs()}",
                            style: TextStyle(
                              color: customer.balance > 0 ? const Color(0xFF4CAF50) : (customer.balance < 0 ? const Color(0xFFE53935) : Colors.grey),
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                          Text(
                            customer.balance > 0 ? "Advance" : (customer.balance < 0 ? "Due" : "Settled"),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => CustomerDetailsScreen(customer: customer),
                        ));
                      },
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()));
        },
        icon: const Icon(Icons.person_add),
        label: const Text("Add Customer"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AppProvider provider) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildSummaryItem("You will give", "৳ ${provider.totalGive}", const Color(0xFFE53935))),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(child: _buildSummaryItem("You will get", "৳ ${provider.totalGet}", const Color(0xFF4CAF50))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color amountColor) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Text(amount, style: TextStyle(color: amountColor, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search customer...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
          fillColor: Colors.grey.shade100,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
