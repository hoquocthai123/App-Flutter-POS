import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'gifts.dart';
import 'myid.dart';
import 'notifications.dart';
import 'account.dart';
import 'gachalucky.dart';
import 'point.dart';
import 'historypoint.dart';

class HomePage extends StatefulWidget {
  final Map customer;
  const HomePage({super.key, required this.customer});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTrangChu(),
      const GiftPage(),
      MyIDPage(customer: widget.customer),
      NotificationPage(customer: widget.customer),
      AccountPage(customer: widget.customer),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: "Khuyến mãi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "My ID"),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: "Đơn hàng",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }

  // Hàm helper build button
  Widget _buildFeatureButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "Quà tặng") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LuckyWheel()),
          );
        } else if (label == "Hạng thành viên") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PointPage(customer: widget.customer),
            ),
          );
        }
        else if (label == "Lịch sử điểm") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryPointPage(customer: widget.customer),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(icon, size: 28, color: Colors.green[700]),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
  String getRank(int points) {
  if (points >= 150000) {
    return "Kim cương";
  } else if (points >= 50000) {
    return "Vàng";
  } else if (points >= 10000) {
    return "Đồng";
  } else {
    return "Thành viên";
  }
}

  Widget _buildTrangChu() {
    final customer = widget.customer;
    return SafeArea(
  child: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // Header
      Row(
        children: [
          Image.asset("assets/logo.png", height: 40),
          const Spacer(),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer["name"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // Hiển thị rank
              Text(
                getRank(customer["points"]),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Card điểm và barcode
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF176), Color(0xFFFFD54F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              "Điểm hiện tại: ${customer["points"]}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BarcodeWidget(
              data: customer["id_cus"].toString(),
              barcode: Barcode.code128(),
              width: double.infinity,
              height: 100,
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // 6 nút chức năng
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildFeatureButton(Icons.star_border, "Hạng thành viên"),
          _buildFeatureButton(Icons.history, "Lịch sử điểm"),
          _buildFeatureButton(Icons.card_giftcard, "Quà tặng"),
          _buildFeatureButton(Icons.event, "Sự kiện"),
          _buildFeatureButton(Icons.location_on, "Hệ thống cửa hàng"),
          _buildFeatureButton(Icons.group, "Tuyển dụng"),
        ],
      ),
      const SizedBox(height: 20),
    ],
  ),
);
  }
}
