import 'package:flutter/material.dart';
import 'package:raksha/widgets/app_drawer.dart';

class UPIPaymentScreen extends StatefulWidget {
  const UPIPaymentScreen({super.key});

  @override
  State<UPIPaymentScreen> createState() => _UPIPaymentScreenState();
}

class _UPIPaymentScreenState extends State<UPIPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text(
          'UPI Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page heading
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.payment,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'UPI Payment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Quick and secure payments',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Dummy content sections
            _buildSection(
              title: 'Recent Contacts',
              icon: Icons.people,
              items: [
                'John Doe - john.doe@upi',
                'Jane Smith - jane.smith@okicici',
                'Mike Johnson - mike@paytm',
                'Sarah Wilson - sarah@phonepe',
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildSection(
              title: 'Quick Actions',
              icon: Icons.flash_on,
              items: [
                'Scan QR Code',
                'Pay to Mobile Number',
                'Pay to UPI ID',
                'Request Money',
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildSection(
              title: 'Recent Transactions',
              icon: Icons.history,
              items: [
                'Paid ₹500 to John Doe - 2 hours ago',
                'Received ₹1000 from Jane Smith - Yesterday',
                'Paid ₹250 to Mike Johnson - 2 days ago',
                'Requested ₹750 from Sarah Wilson - 3 days ago',
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildSection(
              title: 'UPI Apps',
              icon: Icons.apps,
              items: [
                'Google Pay',
                'PhonePe',
                'Paytm',
                'BHIM',
                'Amazon Pay',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF667EEA), size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF667EEA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(  
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}