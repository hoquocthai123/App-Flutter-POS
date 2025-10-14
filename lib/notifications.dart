import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  final Map customer; // thông tin khách đã đăng nhập
  const NotificationPage({super.key, required this.customer});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
        Uri.parse("http://localhost:3000/customers/${widget.customer["id_cus"]}/orders"),
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
      debugPrint("Lỗi khi load orders: $e");
      setState(() => loading = false);
    }
  }

  Future<void> fetchOrderDetails(int orderId) async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:3000/customers/${widget.customer["id_cus"]}/orders/$orderId"),
      );
      if (res.statusCode == 200) {
        final order = json.decode(res.body);

        // Hiển thị dialog chi tiết với UI đẹp hơn
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Chi tiết đơn #$orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Ngày: ${DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.parse(order["created_at"]))}", style: const TextStyle(color: Colors.grey)),
                  Text("Tổng tiền: ${order["tongtien"].toString()} đ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 12),
                  const Text("Sản phẩm:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: order["items"].length,
                      itemBuilder: (_, index) {
                        final item = order["items"][index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Hiển thị ảnh sản phẩm
                                if (item["image"] != null && item["image"].toString().startsWith('http'))
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item["image"],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 60),
                                    ),
                                  )
                                else
                                  const Icon(Icons.image, size: 60),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item["name"] ?? "Sản phẩm", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text("Số lượng: ${item["quantity"]}", style: const TextStyle(color: Colors.grey)),
                                      Text("${item["price"]} đ", style: const TextStyle(color: Colors.blue)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Đóng"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy chi tiết đơn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn hàng của tôi"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? const Center(child: Text("Bạn chưa có đơn hàng nào", style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    itemBuilder: (_, index) {
                      final order = orders[index];
                      final firstItemImage = (order["items"] != null && order["items"].isNotEmpty && order["items"][0]["image"] != null)
                          ? order["items"][0]["image"]
                          : null;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: firstItemImage != null && firstItemImage.toString().startsWith('http')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    firstItemImage,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_cart, size: 50),
                                  ),
                                )
                              : const Icon(Icons.shopping_cart, size: 50),
                          title: Text("Đơn hàng #${order["id_order"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Ngày: ${DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.parse(order["created_at"]))}", style: const TextStyle(color: Colors.grey)),
                          trailing: Text(
                            "${order["tongtien"].toString()} đ",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                          ),
                          onTap: () => fetchOrderDetails(order["id_order"]),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
