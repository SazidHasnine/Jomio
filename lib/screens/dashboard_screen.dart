import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/pdf_service.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';
import 'profile_screen.dart';
import 'help_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/jomio-custom-lettering.png', height: 28),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white), 
            onPressed: () async {
              final customers = context.read<AppProvider>().customers;
              if (customers.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No data to export!')));
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
              try {
                await PdfService.generateAndDownloadLedger(customers);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
              }
            }
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white), 
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Settings'),
                  content: const Text('Would you like to log out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<AppProvider>().logout();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('LOGOUT'),
                    ),
                  ],
                ),
              );
            }
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildReportsTab(),
          _buildMoreTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()));
        },
        icon: const Icon(Icons.person_add),
        label: const Text("Add Customer"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final totalCustomers = provider.customers.where((c) => c.userType.name == 'customer').length;
        final totalSuppliers = provider.customers.where((c) => c.userType.name == 'supplier').length;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text("Total Customers"),
                trailing: Text("$totalCustomers", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.business, color: Colors.orange),
                title: const Text("Total Suppliers"),
                trailing: Text("$totalSuppliers", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Financial Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text("Total to Receive (Advance)"),
                trailing: Text("৳ ${provider.totalGet}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text("Total to Pay (Due)"),
                trailing: Text("৳ ${provider.totalGive}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Profile"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text("Help & Support"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout", style: TextStyle(color: Colors.red)),
          onTap: () async {
            await context.read<AppProvider>().logout();
          },
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    return Consumer<AppProvider>(
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
                    title: Row(
                      children: [
                        Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            customer.userType.name.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      customer.lastTransactionDate != null
                          ? "Last tx: ${DateTime.now().difference(customer.lastTransactionDate!).inDays} days ago"
                          : "Tap to view details",
                      style: const TextStyle(fontSize: 12),
                    ),
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
