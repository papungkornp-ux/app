import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_app/api_service.dart';
import 'package:project_app/merit_data.dart';

class MeritTrackingScreen extends StatefulWidget {
  final String username;
  final String religion;

  const MeritTrackingScreen({
    super.key,
    required this.username,
    required this.religion,
  });

  @override
  State<MeritTrackingScreen> createState() => _MeritTrackingScreenState();
}

class _MeritTrackingScreenState extends State<MeritTrackingScreen> {
  final Set<String> _selectedIds = <String>{};
  final Map<String, int> _minuteValues = <String, int>{};
  bool _isSaving = false;
  int _totalPoints = 0;
  List<dynamic> _history = <dynamic>[];
  late String _todayDate;
  late String _thaiTime;
  Timer? _dateRefreshTimer;

  // แปลงเวลาปัจจุบันของเครื่องเป็นเวลาไทย UTC+7
  // เพื่อไม่ขึ้นกับ timezone ของ Android Emulator
  DateTime _thaiNow() {
    return DateTime.now().toUtc().add(const Duration(hours: 7));
  }

  String _currentDate() {
    final now = _thaiNow();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  String _currentTime() {
    final now = _thaiNow();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute น.';
  }

  List<MeritItem> get _items => getMeritItemsForReligion(widget.religion);

  @override
  void initState() {
    super.initState();

    // กำหนดวันที่และเวลาเริ่มต้นเมื่อเปิดหน้า
    _todayDate = _currentDate();
    _thaiTime = _currentTime();

    // ตรวจสอบเวลาใหม่ทุก 1 นาที
    // เพื่อให้วันที่เปลี่ยนอัตโนมัติเมื่อข้ามเที่ยงคืน
    _dateRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final currentDate = _currentDate();
      final currentTime = _currentTime();

      if (mounted && (currentDate != _todayDate || currentTime != _thaiTime)) {
        setState(() {
          _todayDate = currentDate;
          _thaiTime = currentTime;
        });
      }
    });

    // โหลดแต้มรวมและประวัติจากฐานข้อมูล
    _loadAccountData();
  }

  @override
  void dispose() {
    // ยกเลิก Timer เพื่อป้องกันการใช้ทรัพยากรค้าง
    _dateRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAccountData() async {
    try {
      // ดึงแต้มสะสมและประวัติของผู้ใช้จาก PHP API
      final summary = await ApiService.getSummary(username: widget.username);
      final history = await ApiService.getHistory(username: widget.username);

      // ตรวจสอบว่าหน้ายังเปิดอยู่ก่อนเรียก setState
      if (!mounted) return;

      setState(() {
        _totalPoints = (summary['total_points'] as num?)?.toInt() ?? 0;
        _history = history;
      });
    } catch (_) {
      // หาก API ยังไม่พร้อม แอปยังสามารถเลือกกิจกรรมได้ตามปกติ
    }
  }

  void _toggleItem(String itemId, bool isChecked) {
    setState(() {
      if (isChecked) {
        // ศีล 5 และศีล 8 เลือกได้เพียงอย่างใดอย่างหนึ่ง
        if (itemId == 'sila_5') {
          _selectedIds.remove('sila_8');
        } else if (itemId == 'sila_8') {
          _selectedIds.remove('sila_5');
        }

        _selectedIds.add(itemId);
      } else {
        // ยกเลิกกิจกรรมที่เลือก
        _selectedIds.remove(itemId);
        _minuteValues.remove(itemId);
      }
    });
  }

  Future<void> _saveLog() async {
    // ห้ามบันทึกถ้ายังไม่ได้เลือกกิจกรรม
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกสิ่งที่ได้ทำอย่างน้อยหนึ่งรายการ'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // แปลงรายการที่เลือกเป็นข้อมูลสำหรับส่งให้ API
      // ค่า 1 หมายถึงกิจกรรมนั้นนับเป็น 1 แต้ม
      final activities = <String, int>{};

      for (final item in _items) {
        if (_selectedIds.contains(item.id)) {
          activities[item.id] = _minuteValues[item.id] ?? 1;
        }
      }

      // บันทึกกิจกรรมของผู้ใช้ในวันที่ปัจจุบัน
      await ApiService.saveDailyLog(
        username: widget.username,
        religion: widget.religion,
        date: _todayDate,
        activities: activities,
      );

      if (!mounted) return;

      // โหลดแต้มรวมและประวัติใหม่หลังบันทึกสำเร็จ
      await _loadAccountData();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')));
    } catch (error) {
      // แสดงข้อความเมื่อบันทึกไม่สำเร็จ
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      // เปิดปุ่มบันทึกกลับหลังจากการทำงานเสร็จ
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.religion == 'อิสลาม'
              ? 'บันทึกอิบาดะฮ์วันนี้'
              : 'บันทึกบุญวันนี้',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ผู้ใช้: ${widget.username}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'วันที่: $_todayDate',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              'เวลาไทย: $_thaiTime',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.stars, color: Colors.amber),
                title: const Text('แต้มสะสมทั้งหมด'),
                trailing: Text(
                  '$_totalPoints แต้ม',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final isChecked = _selectedIds.contains(item.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: isChecked,
                            title: Text(item.title),
                            subtitle: Text(item.subtitle),
                            onChanged: (value) {
                              _toggleItem(item.id, value ?? false);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveLog,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึกข้อมูล'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showHistory(context),
              icon: const Icon(Icons.history),
              label: const Text('ดูประวัติการบันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    // แสดงประวัติใน Bottom Sheet โดยไม่เปลี่ยนหน้า
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .65,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ประวัติการบันทึก',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _history.isEmpty
                      ? const Center(child: Text('ยังไม่มีประวัติการบันทึก'))
                      : ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final entry =
                                _history[index] as Map<String, dynamic>;
                            return ListTile(
                              leading: const Icon(Icons.event_available),
                              title: Text('${entry['points'] ?? 0} แต้ม'),
                              subtitle: Text(
                                '${entry['log_date'] ?? ''}  |  ${entry['activity_count'] ?? 0} รายการ',
                              ),
                            );
                          },
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
