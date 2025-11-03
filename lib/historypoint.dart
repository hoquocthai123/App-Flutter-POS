import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryPointPage extends StatefulWidget {
  final Map customer;
  const HistoryPointPage({super.key, required this.customer});

  @override
  State<HistoryPointPage> createState() => _HistoryPointPageState();
}

class _HistoryPointPageState extends State<HistoryPointPage> {
  List orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => loading = true);
    try {
      final res = await http.get(
        Uri.parse("${dotenv.env['APIURLKEY']}/customers/${widget.customer["id_cus"]}/orders"),
      );
      if (res.statusCode == 200) {
        setState(() {
          orders = json.decode(res.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Lỗi khi load lịch sử điểm: $e");
      setState(() => loading = false);
    }
  }

  int calculatePoints(double total) {
    return (total * 0.03).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử tích điểm'),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? const Center(child: Text("Chưa có lịch sử tích điểm"))
                : Column(
                    children: [
                      // Tổng điểm hiện tại
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber[300]!, Colors.amber[100]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Tổng điểm tích lũy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.customer["points"]}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Danh sách lịch sử
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          itemBuilder: (_, index) {
                            final order = orders[index];
                            final pointsEarned = calculatePoints(order["tongtien"].toDouble());

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  "Đơn hàng #${order["id_order"]}",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text("Ngày: ${order["created_at"]}"),
                                    Text("Tổng tiền: ${order["tongtien"]} đ"),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "+$pointsEarned điểm",
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}