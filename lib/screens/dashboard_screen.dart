import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/app_provider.dart';
import '../services/pdf_service.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';
import 'profile_screen.dart';
import 'help_screen.dart';
import 'cashbox_screen.dart';
import 'super_qr_screen.dart';
import 'stock_screen.dart';
import 'tagada_screen.dart';
import 'business_notes_screen.dart';
import 'tally_message_screen.dart';
import 'multi_business_screen.dart';
import 'backup_screen.dart';
import 'inbox_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    final provider = context.read<AppProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.filter_list, color: Color(0xFFE53935)),
                SizedBox(width: 10),
                Text('ফিল্টার নির্বাচন করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilterOption(ctx, provider, 'সকল হিসাব (All)', CustomerFilter.all),
            _buildFilterOption(ctx, provider, 'শুধুমাত্র কাস্টমার (Customers)', CustomerFilter.customersOnly),
            _buildFilterOption(ctx, provider, 'শুধুমাত্র সাপ্লায়ার (Suppliers)', CustomerFilter.suppliersOnly),
            _buildFilterOption(ctx, provider, 'বকেয়া হিসাব - পাবো (Due Only)', CustomerFilter.dueOnly),
            _buildFilterOption(ctx, provider, 'অগ্রিম জমা - দেবো (Advance Only)', CustomerFilter.advanceOnly),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext ctx, AppProvider provider, String title, CustomerFilter filter) {
    final isSelected = provider.currentFilter == filter;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? const Color(0xFFE53935) : Colors.grey,
      ),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        provider.setFilter(filter);
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Name Pill matching TallyKhata
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MultiBusinessScreen()));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.businessName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'স্ট্যান্ডার্ড',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          // Inbox Action (ইনবক্স)
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen()));
            },
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, color: Colors.white, size: 22),
                  SizedBox(height: 2),
                  Text('ইনবক্স', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Help Action (হেল্প)
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
            },
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headset_mic_outlined, color: Colors.white, size: 22),
                  SizedBox(height: 2),
                  Text('হেল্প', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(context, provider),
          _buildReportsTab(provider),
          _buildMoreTab(context, provider),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()));
              },
              backgroundColor: const Color(0xFFE53935),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              icon: const Icon(Icons.person_add, size: 20, color: Colors.white),
              label: const Text(
                'নতুন কাস্টমার/সাপ্লায়ার',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFE53935),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'খাতা'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'রিপোর্ট'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'আরও'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, AppProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredList = provider.filteredCustomers;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Top Banner (Matching TallyKhata)
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFFF7043)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('সুপার অফার', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'সুপার QR দিয়ে ডিজিটাল পেমেন্ট গ্রহণ করুন',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    const Text('বিকাশ, নগদ, রকেটে টাকা সরাসরি আপনার অ্যাকাউন্টে', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperQrScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE53935),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('QR দেখুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // TallyKhata 8-Item Business Utilities Grid
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          children: [
            _menuItem(
              icon: Icons.store,
              title: 'মাল্টি ব্যবসা',
              color: 0xFF2E7D32,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MultiBusinessScreen())),
            ),
            _menuItem(
              icon: Icons.inventory_2,
              title: 'স্টক হিসাব',
              color: 0xFFC2185B,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockScreen())),
            ),
            _menuItem(
              icon: Icons.note_alt,
              title: 'ব্যবসার নোট',
              color: 0xFFE65100,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessNotesScreen())),
            ),
            _menuItem(
              icon: Icons.notifications_active,
              title: 'গ্রুপ তাগাদা',
              color: 0xFF2E7D32,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TagadaScreen())),
            ),
            _menuItem(
              icon: Icons.qr_code_2,
              title: 'সুপার QR',
              color: 0xFFC2185B,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperQrScreen())),
            ),
            _menuItem(
              icon: Icons.cloud_upload,
              title: 'ডাটা ব্যাকআপ',
              color: 0xFF2E7D32,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen())),
            ),
            _menuItem(
              icon: Icons.sms,
              title: 'টালি-মেসেজ',
              color: 0xFFC2185B,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TallyMessageScreen())),
            ),
            _menuItem(
              icon: Icons.point_of_sale,
              title: 'ক্যাশবক্স',
              color: 0xFFE65100,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CashboxScreen())),
            ),
          ],
        ),

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 6),

        // Summary Row ("মোট পাবো" vs "মোট দেবো")
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '৳ ${provider.totalGive.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('মোট পাবো (বাকি)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
              child: VerticalDivider(),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '৳ ${provider.totalGet.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('মোট দেবো (অগ্রিম)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Search, Filter & PDF Download Action Row (matching TallyKhata)
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                    hintText: 'খোঁজ (নাম বা মোবাইল নম্বর)...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Filter Button
            Container(
              decoration: BoxDecoration(
                color: provider.currentFilter != CustomerFilter.all ? Colors.red.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: provider.currentFilter != CustomerFilter.all ? const Color(0xFFE53935) : Colors.transparent,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: provider.currentFilter != CustomerFilter.all ? const Color(0xFFE53935) : Colors.black87,
                ),
                tooltip: 'ফিল্টার',
                onPressed: () => _showFilterSheet(context),
              ),
            ),
            const SizedBox(width: 8),
            // PDF Download Button
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.black87),
                tooltip: 'লেজার PDF ডাউনলোড',
                onPressed: () async {
                  if (provider.customers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ডাউনলোড করার কোনো ডাটা নেই!')));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('লেজার PDF তৈরি হচ্ছে...')));
                  try {
                    await PdfService.generateAndDownloadLedger(provider.customers);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF ত্রুটি: $e')));
                    }
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Customer & Supplier Stats Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'কাস্টমার ${provider.customerCount} / সাপ্লায়ার ${provider.supplierCount}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'পাবো ', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 13)),
                  TextSpan(text: '/ ', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  TextSpan(text: 'দেবো', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Customer & Supplier List
        filteredList.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_search, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        provider.customers.isEmpty
                            ? 'এখনো কোনো কাস্টমার বা সাপ্লায়ার যোগ করা হয়নি।'
                            : 'অনুসন্ধানের সাথে কোনো কাস্টমার মেলেনি।',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      if (provider.customers.isEmpty)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('নতুন কাস্টমার যোগ করুন'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFFE53935)),
                        ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: filteredList.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final customer = filteredList[index];
                  final isDue = customer.balance < 0;
                  final daysAgo = customer.lastTransactionDate != null
                      ? '${DateTime.now().difference(customer.lastTransactionDate!).inDays} দিন'
                      : 'নতুন';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CustomerDetailsScreen(customer: customer)),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0] : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            customer.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: customer.userType == UserType.customer ? Colors.blue.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            customer.userType == UserType.customer ? 'কাস্টমার' : 'সাপ্লায়ার',
                            style: TextStyle(
                              fontSize: 10,
                              color: customer.userType == UserType.customer ? Colors.blue.shade800 : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '$daysAgo • ${customer.phone}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '৳ ${customer.balance.abs().toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: customer.balance == 0
                                ? Colors.grey
                                : (isDue ? const Color(0xFFE53935) : Colors.green),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),

        const SizedBox(height: 70), // space for FAB
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required int color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Color(color).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(color), size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReportsTab(AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("সারসংক্ষেপ ও রিপোর্ট", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text("মোট কাস্টমার"),
            trailing: Text("${provider.customerCount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.business, color: Colors.orange),
            title: const Text("মোট সাপ্লায়ার"),
            trailing: Text("${provider.supplierCount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        const SizedBox(height: 20),
        const Text("আর্থিক স্থিতি", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.red),
            title: const Text("মোট পাওনা (বাকি)"),
            trailing: Text("৳ ${provider.totalGive}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Card(
          color: Colors.green.shade50,
          child: ListTile(
            leading: const Icon(Icons.arrow_downward, color: Colors.green),
            title: const Text("মোট দেনা (অগ্রিম)"),
            trailing: Text("৳ ${provider.totalGet}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Card(
          color: Colors.blue.shade50,
          child: ListTile(
            leading: const Icon(Icons.point_of_sale, color: Colors.blue),
            title: const Text("ক্যাশ ইন হ্যান্ড (ক্যাশবক্স)"),
            trailing: Text("৳ ${provider.cashInHand.toStringAsFixed(0)}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Card(
          color: Colors.purple.shade50,
          child: ListTile(
            leading: const Icon(Icons.inventory_2, color: Colors.purple),
            title: const Text("মোট স্টক মূল্য"),
            trailing: Text("৳ ${provider.totalStockValuation.toStringAsFixed(0)}", style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreTab(BuildContext context, AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.store, color: Color(0xFFE53935)),
          title: const Text("দোকান / ব্যবসার প্রোফাইল"),
          subtitle: Text(provider.businessName),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MultiBusinessScreen()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.cloud_sync, color: Colors.green),
          title: const Text("ডাটা ব্যাকআপ ও ক্লাউড সিঙ্ক"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("অ্যাকাউন্ট সেটিংস"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text("সহায়তা ও যোগাযোগ"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("লগআউট", style: TextStyle(color: Colors.red)),
          onTap: () async {
            await provider.logout();
          },
        ),
      ],
    );
  }
}
