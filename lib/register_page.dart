import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Homepage.dart';
import 'package:dropdown_search/dropdown_search.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); 
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  String? selectedGender;

  bool loading = false;
  String? message;
  String? serverOtp;

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];

  String? selectedProvinceCode;
  String? selectedProvinceName;
  String? selectedDistrictCode;
  String? selectedDistrictName;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    try {
      final res = await http.get(Uri.parse('${dotenv.env['APIURLKEY']}/api/provinces'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          provinces = data.map((p) => p as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching provinces: $e');
    }
  }

  Future<void> fetchDistricts(String provinceCode) async {
    try {
      final res = await http.get(
        Uri.parse('${dotenv.env['APIURLKEY']}/api/provinces/$provinceCode/communes'),
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          districts = data.map((d) => d as Map<String, dynamic>).toList();
          selectedDistrictCode = null;
          selectedDistrictName = null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final res = await http.get(Uri.parse('${dotenv.env['APIURLKEY']}/customers/check-email?email=$email'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['exists'] ?? false;
      }
    } catch (e) {
      debugPrint('Error checking email: $e');
    }
    return false;
  }

  Future<void> _registerAndSendOtp() async {
    setState(() {
      loading = true;
      message = null;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        message = "Vui lòng nhập email";
        loading = false;
      });
      return;
    }

    // Check if email already exists
    bool emailExists = await checkEmailExists(email);
    if (emailExists) {
      setState(() {
        message = "Email này đã được đăng ký trước đó";
        loading = false;
      });
      return;
    }

    try {
      final otpApiUrl = "${dotenv.env['APIURLKEY']}/send-otp";
      final otpRes = await http.post(
        Uri.parse(otpApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (otpRes.statusCode == 200) {
        final data = jsonDecode(otpRes.body);
        serverOtp = data['otpCode']?.toString();
        if (serverOtp != null) {
          _showOtpDialog();
        }
      } else {
        setState(() {
          message = "❌ Lỗi gửi OTP: ${otpRes.body}";
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

  Future<void> _verifyOtpAndRegister() async {
    final otpInput = _otpController.text.trim();
    if (otpInput != serverOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP không đúng")),
      );
      return;
    }

    Navigator.of(context).pop();

    setState(() {
      loading = true;
      message = null;
    });

    final wardText = _addressController.text.trim();
    final fullAddress = '$wardText, $selectedDistrictName, $selectedProvinceName'.trim();

    try {
      final apiUrl = "${dotenv.env['APIURLKEY']}/customers";
      final phone = _phoneController.text.trim();
      final id = phone.startsWith('0') ? phone.substring(1) : phone;

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_cus": id,
          "name": _nameController.text.trim(),
          "phone": phone,
          "points": 0,
          "address": fullAddress,
          "gender": selectedGender,
          "email": _emailController.text.trim(),
        }),
      );

      if (res.statusCode == 200) {
        setState(() {
          message = "🎉 Đăng ký thành công!";
        });

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomePage(
                customer: {
                  "id_cus": id,
                  "name": _nameController.text.trim(),
                  "email": _emailController.text.trim(),
                  "phone": phone,
                  "address": fullAddress,
                  "gender": selectedGender,
                  "points": 0,
                },
              ),
            ),
          );
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
            onPressed: _verifyOtpAndRegister,
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký"),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amberAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Logo
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 20),
              // Form Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Name
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Tên",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Phone
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: "Số điện thoại",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      // Email
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      // Gender
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Giới tính",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.wc),
                        ),
                        value: selectedGender,
                        hint: const Text('Chọn giới tính'),
                        items: ['Nam', 'Nữ', 'Khác'].map((gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Province
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Tỉnh/Thành phố',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.location_city),
                        ),
                        value: selectedProvinceCode,
                        hint: const Text('Chọn Tỉnh/Thành phố'),
                        items: provinces.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['code']?.toString() ?? '',
                            child: Text(p['name']?.toString() ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null && value.isNotEmpty) {
                            final selected = provinces.firstWhere((p) => p['code'] == value);
                            setState(() {
                              selectedProvinceCode = value;
                              selectedProvinceName = selected['name']?.toString() ?? '';
                              selectedDistrictCode = null;
                              selectedDistrictName = null;
                              districts = [];
                            });
                            fetchDistricts(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // District
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.location_on),
                            ),
                            Expanded(
                              child: DropdownSearch<String>(
                                enabled: districts.isNotEmpty,
                                items: districts.map((d) => d['name']?.toString() ?? '').toList(),
                                selectedItem: selectedDistrictName,
                                dropdownBuilder: (context, selectedItem) => Text(selectedItem ?? 'Chọn Quận/Huyện'),
                                popupProps: PopupProps<String>.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      hintText: 'Tìm kiếm...',
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    final selected = districts.firstWhere((d) => d['name'] == value);
                                    setState(() {
                                      selectedDistrictCode = selected['code']?.toString();
                                      selectedDistrictName = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Address
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: "Số nhà, Đường",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.home),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (message != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : _registerAndSendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text("Đăng ký"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
