import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class GiftPage extends StatefulWidget {
  const GiftPage({super.key});

  @override
  State<GiftPage> createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage> {
  List promotions = [];
  bool loading = true;
  String formatDate(String? dateStr) {
  if (dateStr == null) return "";
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return dateStr; // fallback nếu parse lỗi
  }
}


  @override
  void initState() {
    super.initState();
    fetchPromotions();
  }

  Future<void> fetchPromotions() async {
    setState(() {
      loading = true;
    });
    try {
      final res = await http.get(Uri.parse("${dotenv.env['APIURLKEY']}/promotions-with-items"));
      if (res.statusCode == 200) {
        final allPromotions = jsonDecode(res.body);
        final now = DateTime.now();
        setState(() {
          promotions = allPromotions.where((promo) {
            try {
              final endDate = DateTime.parse(promo["end_date"]);
              return endDate.isAfter(now);
            } catch (e) {
              return false;
            }
          }).toList();
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("🎁 Khuyến mãi & Quà tặng"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => fetchPromotions(),
            ),
          ],
          bottom: loading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(4.0),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.blue[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : null,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : promotions.isEmpty
                ? const Center(child: Text("Không có khuyến mãi nào"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: promotions.length,
                    itemBuilder: (context, index) {
                      final promo = promotions[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ảnh khuyến mãi
                            if (promo["image_url"] != null &&
                                promo["image_url"].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  promo["image_url"],
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, obj, trace) => Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Center(
                                        child: Icon(Icons.image_not_supported)),
                                  ),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    promo["title"] ?? "Không có tiêu đề",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    promo["description"] ?? "",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.discount,
                                          size: 18, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${promo["discount_percent"] ?? 0}% OFF",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
 "Thời gian: ${formatDate(promo["start_date"])} → ${formatDate(promo["end_date"])}",
 style: const TextStyle(fontSize: 12, color: Colors.grey),
),
                                  if (promo["items"] != null &&
                                      promo["items"].isNotEmpty) ...[
                                    const SizedBox(height: 8), 
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
