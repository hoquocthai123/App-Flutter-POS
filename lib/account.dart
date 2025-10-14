import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccountPage extends StatefulWidget {
  final Map customer;
  const AccountPage({super.key, required this.customer});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isEditing = false;
  bool loading = false;
  String? message;

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer["name"]);
    _addressController =
        TextEditingController(text: widget.customer["address"]);
    _genderController = TextEditingController(text: widget.customer["gender"]);
  }

  Future<void> _updateCustomer() async {
    setState(() {
      loading = true;
      message = null;
    });

    try {
      final apiUrl =
          "http://localhost:3000/customers/${widget.customer["id_cus"]}";

      final res = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "phone": widget.customer["phone"], // không cho sửa
          "address": _addressController.text.trim(),
          "gender": _genderController.text.trim(),
          "email": widget.customer["email"], // không cho sửa
          "points": widget.customer["points"], // không cho sửa
        }),
      );

      if (res.statusCode == 200) {
        setState(() {
          message = "✅ Cập nhật thành công!";
          isEditing = false;
        });
      } else {
        setState(() {
          message = "❌ Lỗi: ${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Lỗi kết nối: $e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _logout() {
    // Navigate back to login page
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + tên
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade100,
                  child:
                      const Icon(Icons.person, size: 50, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.customer["name"],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Thông tin
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildReadOnlyRow("📧 Email", widget.customer["email"]),
                    const Divider(),
                    _buildReadOnlyRow("📱 SĐT", widget.customer["phone"]),
                    const Divider(),
                    _buildEditableRow("👤 Tên", _nameController),
                    const Divider(),
                    _buildEditableRow("🏠 Địa chỉ", _addressController),
                    const Divider(),
                    _buildEditableRow("⚥ Giới tính", _genderController),
                    const Divider(),
                    _buildReadOnlyRow(
                        "⭐ Điểm", widget.customer["points"].toString()),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (message != null)
              Text(
                message!,
                style: TextStyle(
                    color: message!.contains("✅") ? Colors.green : Colors.red),
              ),

            const SizedBox(height: 20),

            // Nút đăng xuất
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Đăng xuất"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Nút hành động
            isEditing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: loading ? null : _updateCustomer,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text("Lưu"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditing = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text("Hủy"),
                      ),
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Sửa thông tin"),
                  ),
          ],
        ),
      ),
    );
  }

  // Dòng không cho sửa
  Widget _buildReadOnlyRow(String label, String? value) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87))),
        Expanded(
            flex: 3,
            child: Text(value ?? "-",
                style: const TextStyle(color: Colors.black54))),
      ],
    );
  }

  // Dòng cho phép sửa
  Widget _buildEditableRow(String label, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87))),
        Expanded(
          flex: 3,
          child: isEditing
              ? TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(controller.text,
                  style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}
