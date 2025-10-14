import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class MyIDPage extends StatelessWidget {
  final Map customer;
  const MyIDPage({super.key, required this.customer});

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

  @override
  Widget build(BuildContext context) {
    final rank = getRank(customer["points"]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thẻ thành viên'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Thẻ thành viên
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[300]!, Colors.amber[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo và tên
                    Row(
                      children: [
                        Image.asset('assets/logo.png', height: 40),
                        const Spacer(),
                        Text(
                          rank,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Thông tin khách hàng
                    Text(
                      customer["name"],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SĐT: ${customer["phone"]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email: ${customer["email"]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Barcode
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          BarcodeWidget(
                            data: customer["id_cus"].toString(),
                            barcode: Barcode.code128(),
                            width: double.infinity,
                            height: 100,
                            drawText: false,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Mã thành viên: ${customer["id_cus"]}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Thông tin điểm
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Điểm tích lũy',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${customer["points"]}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
