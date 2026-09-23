import 'package:flutter/material.dart';
import 'package:project_app/api_service.dart';
import 'package:project_app/buddhism_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'บันทึกบุญ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _religion = 'พุทธ';
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // ตรวจสอบข้อมูลก่อนส่งไปยัง API
    if (username.isEmpty || password.isEmpty) {
      _showMessage('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // เรียก API เพื่อตรวจสอบชื่อผู้ใช้และรหัสผ่าน
      final result = await ApiService.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      // ใช้ศาสนาที่ได้จากฐานข้อมูล
      _openTracker(username, result['religion'] as String? ?? _religion);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      // เปิดปุ่มกลับหลังจาก API ทำงานเสร็จ
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openTracker(String username, String religion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MeritTrackingScreen(username: username, religion: religion),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openRegister() async {
    // เปิดหน้าสร้างบัญชีและรอผลลัพธ์ true เมื่อสร้างสำเร็จ
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );

    if (registered == true && mounted) {
      _showMessage('สร้างบัญชีสำเร็จ กรุณาเข้าสู่ระบบ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'บันทึกบุญ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'เข้าสู่ระบบเพื่อบันทึกกิจกรรมประจำวัน',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อผู้ใช้',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'รหัสผ่าน',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _login,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                          _isLoading ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _openRegister,
                        child: const Text('ยังไม่มีบัญชี? สร้างบัญชีใหม่'),
                      ),
                    ),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GroupMembersScreen(),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.groups_outlined),
                        label: const Text('สมาชิกกลุ่ม'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GroupMembersScreen extends StatelessWidget {
  const GroupMembersScreen({super.key});

  // รายชื่อสมาชิกกลุ่มและรหัสนิสิต
  static const members = [
    ('นายปภังกร ผาทอง', '6721652323'),
    ('นายอัครชัย ทองสุพรรณ์', '6721652846'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมาชิกกลุ่ม')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final member = members[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(
                member.$1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('รหัสนิสิต ${member.$2}'),
            ),
          );
        },
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _religion = 'พุทธ';
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // ตรวจสอบชื่อผู้ใช้และความยาวรหัสผ่าน
    if (username.isEmpty || password.length < 4) {
      _showMessage('กรุณากรอกชื่อผู้ใช้และรหัสผ่านอย่างน้อย 4 ตัวอักษร');
      return;
    }

    // ป้องกันการสร้างบัญชีด้วยรหัสผ่านที่ยืนยันไม่ตรงกัน
    if (password != _confirmController.text) {
      _showMessage('รหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ส่งข้อมูลบัญชีใหม่ไปบันทึกในฐานข้อมูลผ่าน API
      await ApiService.register(
        username: username,
        password: password,
        religion: _religion,
      );

      // ส่งค่า true กลับไปยังหน้า Login เพื่อแจ้งว่าสร้างบัญชีสำเร็จ
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างบัญชีใหม่')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'ชื่อผู้ใช้',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'รหัสผ่าน',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'ยืนยันรหัสผ่าน',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('ศาสนา', style: TextStyle(fontWeight: FontWeight.w600)),
          RadioListTile<String>(
            title: const Text('พุทธ'),
            value: 'พุทธ',
            groupValue: _religion,
            onChanged: (value) {
              if (value != null) setState(() => _religion = value);
            },
          ),
          RadioListTile<String>(
            title: const Text('อิสลาม'),
            value: 'อิสลาม',
            groupValue: _religion,
            onChanged: (value) {
              if (value != null) setState(() => _religion = value);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _register,
            icon: const Icon(Icons.person_add),
            label: Text(_isLoading ? 'กำลังสร้างบัญชี...' : 'สร้างบัญชี'),
          ),
        ],
      ),
    );
  }
}
