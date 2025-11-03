import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Homepage.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String? errorMessage;
  bool loading = false;
  String? serverOtp;

  Future<void> _sendOtp() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errorMessage = "Vui lòng nhập email";
        loading = false;
      });
      return;
    }

    try {
      // Kiểm tra email có tồn tại trong hệ thống không
      final apiUrl = "${dotenv.env['APIURLKEY']}/customers";
      final checkEmailRes = await http.get(Uri.parse(apiUrl));
      
      if (checkEmailRes.statusCode == 200) {
        final List customers = jsonDecode(checkEmailRes.body);
        final existingUser = customers.any(
          (c) => c["email"] == email,
        );

        if (!existingUser) {
          setState(() {
            errorMessage = "Email này chưa được đăng ký! Vui lòng đăng ký tài khoản.";
            loading = false;
          });
          return;
        }

        // Nếu email tồn tại, tiếp tục gửi OTP
        final otpApiUrl = "${dotenv.env['APIURLKEY']}/send-otp";
        final otpRes = await http.post(
          Uri.parse(otpApiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email}),
        );

        if (otpRes.statusCode == 200) {
          final data = jsonDecode(otpRes.body);
          serverOtp = data['otpCode'].toString();
          _showOtpDialog();
        } else {
          setState(() {
            errorMessage = "❌ Lỗi gửi OTP: ${otpRes.body}";
          });
        }
      } else {
        setState(() {
          errorMessage = "Lỗi server: ${checkEmailRes.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Lỗi kết nối: $e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _verifyOtpAndLogin() async {
    final otpInput = _otpController.text.trim();
    if (otpInput.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Vui lòng nhập OTP")));
      return;
    }

    if (otpInput != serverOtp) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("OTP không đúng")));
      return;
    }

    Navigator.of(context).pop(); // đóng popup OTP

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final apiUrl = "${dotenv.env['APIURLKEY']}/customers";
      final res = await http.get(Uri.parse(apiUrl));
      
      if (res.statusCode == 200) {
        final List customers = jsonDecode(res.body);
        final user = customers.firstWhere(
          (c) => c["email"] == _emailController.text.trim(),
          orElse: () => null,
        );

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(customer: user),
            ),
          );
        } else {
          setState(() => errorMessage = "Email chưa được đăng ký!");
        }
      } else {
        setState(() => errorMessage = "Lỗi server: ${res.statusCode}");
      }
    } catch (e) {
      setState(() => errorMessage = "Lỗi kết nối: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void _showOtpDialog() {
    _otpController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nhập mã OTP"),
        content: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Mã 6 số"),
        ),
        actions: [
          TextButton(
            onPressed: _verifyOtpAndLogin,
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Image.asset(
                    'assets/logo.png', // Đảm bảo thêm logo.png vào thư mục assets
                    width: 200,
                    height: 200,
                  ),
                ),

                // Welcome text
                const Text(
                  "Chào mừng bạn đến với DuckBunnStore",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Đăng nhập để tiếp tục",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email của bạn",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Error message
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Gửi mã OTP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Đăng ký tài khoản mới",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
