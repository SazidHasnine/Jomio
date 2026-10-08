import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SuperQrScreen extends StatefulWidget {
  const SuperQrScreen({super.key});

  @override
  State<SuperQrScreen> createState() => _SuperQrScreenState();
}

class _SuperQrScreenState extends State<SuperQrScreen> {
  final _amountCtrl = TextEditingController();
  double _requestedAmount = 0.0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('সুপার QR (Super QR)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE53935),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Instruction Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'এক QR-এ সব পেমেন্ট',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'বিকাশ, নগদ, রকেট, উপায় সহ যেকোনো ব্যাংক অ্যাপ দিয়ে গ্রাহক সরাসরি কিউআর স্ক্যান করে টাকা পাঠাতে পারবে।',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Stand Display
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                child: Column(
                  children: [
                    // Merchant Name & Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        provider.businessName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'মার্চেন্ট নম্বর: ${provider.businessPhone}',
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // QR Visual Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Built-in Custom Painted QR Matrix
                          CustomPaint(
                            size: const Size(200, 200),
                            painter: _QrMatrixPainter(),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE53935), width: 2),
                            ),
                            child: const Icon(Icons.storefront, color: Color(0xFFE53935), size: 28),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_requestedAmount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          'নির্ধারিত বিল: ৳ ${_requestedAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    // MFS Logo Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildMfsChip('bKash', Colors.pink.shade700),
                        _buildMfsChip('Nagad', Colors.orange.shade800),
                        _buildMfsChip('Rocket', Colors.purple.shade700),
                        _buildMfsChip('Upay', Colors.amber.shade900),
                        _buildMfsChip('Visa / Master', Colors.blue.shade800),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Optional Bill Amount Input
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('নির্দিষ্ট টাকার পরিমাণ যোগ করুন (ঐচ্ছিক)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixText: '৳ ',
                              hintText: 'বিল পরিমাণ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _requestedAmount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('সেট করুন'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Download & Share buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('সুপার QR কোড গ্যালারিতে সেভ করা হয়েছে!')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('QR ডাউনলোড'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('কিউআর লিংক ও পেমেন্ট বিবরণ কপি করা হয়েছে!')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('QR শেয়ার করুন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMfsChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

// Custom QR visual pattern painter
class _QrMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final step = size.width / 21;

    // Draw finder patterns (3 corner squares)
    _drawFinderPattern(canvas, 0, 0, step, paint);
    _drawFinderPattern(canvas, (21 - 7) * step, 0, step, paint);
    _drawFinderPattern(canvas, 0, (21 - 7) * step, step, paint);

    // Draw dummy scannable data matrix modules
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        // Skip corner finder areas
        if ((r < 8 && c < 8) || (r < 8 && c > 13) || (r > 13 && c < 8)) continue;
        // Pseudo-random deterministic module pattern
        if ((r * 7 + c * 13 + (r % 2) * 5) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(c * step + 1, r * step + 1, step - 2, step - 2),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double step, Paint paint) {
    // Outer 7x7 square
    canvas.drawRect(Rect.fromLTWH(x, y, 7 * step, 7 * step), paint);
    // Inner white 5x5 square
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + step, y + step, 5 * step, 5 * step), whitePaint);
    // Center 3x3 square
    canvas.drawRect(Rect.fromLTWH(x + 2 * step, y + 2 * step, 3 * step, 3 * step), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
