import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Test/admin/services/admin_service.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final AdminService _adminService = AdminService();
  bool _maintenance = false;
  bool _enableRealTimeReports = true;
  bool _enableBackupDaily = true;
  bool _notifyAdminsOnReport = true;
  int _autoDeleteReportsAfterDays = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _adminService.getAdminSettings();
      setState(() {
        _maintenance = settings['maintenanceMode'] ?? false;
        _enableRealTimeReports = settings['enableRealTimeReports'] ?? true;
        _enableBackupDaily = settings['enableBackupDaily'] ?? true;
        _notifyAdminsOnReport = settings['notifyAdminsOnReport'] ?? true;
        _autoDeleteReportsAfterDays =
            settings['autoDeleteReportsAfterDays'] ?? 30;
      });
    } catch (e) {
      errorMessage('Không thể tải cài đặt: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _adminService.updateAdminSettings({
        'maintenanceMode': _maintenance,
        'enableRealTimeReports': _enableRealTimeReports,
        'enableBackupDaily': _enableBackupDaily,
        'notifyAdminsOnReport': _notifyAdminsOnReport,
        'autoDeleteReportsAfterDays': _autoDeleteReportsAfterDays,
      });

      successMessage('Cài đặt đã được lưu');
    } catch (e) {
      errorMessage('Lỗi khi lưu cài đặt: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt Quản Trị'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Lưu cài đặt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildReportSettings(),
            const SizedBox(height: 24),
            _buildBackupSettings(),
            const SizedBox(height: 24),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt chung',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Chế độ bảo trì'),
              subtitle: const Text(
                'Khi bật, người dùng không thể truy cập ứng dụng ngoại trừ admin',
              ),
              value: _maintenance,
              onChanged: (value) {
                setState(() {
                  _maintenance = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Phiên bản ứng dụng'),
              subtitle: const Text('1.0.0'),
              trailing: ElevatedButton(
                onPressed: () => _showForceUpdateDialog(),
                child: const Text('Cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt báo cáo & kiểm duyệt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Báo cáo thời gian thực'),
              subtitle: const Text(
                'Nhận thông báo khi có báo cáo mới từ người dùng',
              ),
              value: _enableRealTimeReports,
              onChanged: (value) {
                setState(() {
                  _enableRealTimeReports = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Thông báo cho admin'),
              subtitle: const Text(
                'Gửi email cho tất cả admin khi có báo cáo mới',
              ),
              value: _notifyAdminsOnReport,
              onChanged: (value) {
                setState(() {
                  _notifyAdminsOnReport = value;
                });
              },
            ),
            ListTile(
              title: const Text('Tự động xóa báo cáo cũ sau'),
              subtitle: Slider(
                min: 7,
                max: 90,
                divisions: 11,
                value: _autoDeleteReportsAfterDays.toDouble(),
                label: '$_autoDeleteReportsAfterDays ngày',
                onChanged: (value) {
                  setState(() {
                    _autoDeleteReportsAfterDays = value.round();
                  });
                },
              ),
              trailing: Text(
                '$_autoDeleteReportsAfterDays ngày',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt sao lưu & khôi phục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tự động sao lưu hàng ngày'),
              subtitle: const Text(
                'Tạo bản sao lưu dữ liệu tự động mỗi ngày',
              ),
              value: _enableBackupDaily,
              onChanged: (value) {
                setState(() {
                  _enableBackupDaily = value;
                });
              },
            ),
            ListTile(
              title: const Text('Sao lưu thủ công'),
              subtitle: const Text('Tạo bản sao lưu ngay bây giờ'),
              trailing: ElevatedButton.icon(
                onPressed: () => _createBackup(),
                icon: const Icon(Icons.backup),
                label: const Text('Sao lưu'),
              ),
            ),
            ListTile(
              title: const Text('Khôi phục dữ liệu'),
              subtitle: const Text('Khôi phục từ bản sao lưu đã chọn'),
              trailing: ElevatedButton.icon(
                onPressed: () => _showRestoreDialog(),
                icon: const Icon(Icons.restore),
                label: const Text('Khôi phục'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      elevation: 2,
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.red, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vùng nguy hiểm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Xóa tất cả báo cáo'),
              subtitle: const Text(
                'Xóa tất cả báo cáo nội dung từ người dùng',
              ),
              trailing: ElevatedButton(
                onPressed: () => _showDeleteAllReportsDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Xóa tất cả'),
              ),
            ),
            ListTile(
              title: const Text('Đặt lại cài đặt mặc định'),
              subtitle: const Text(
                'Khôi phục tất cả cài đặt quản trị về mặc định',
              ),
              trailing: ElevatedButton(
                onPressed: () => _showResetSettingsDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Đặt lại'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForceUpdateDialog() {
    final versionController = TextEditingController(text: '1.0.1');
    final messageController = TextEditingController(
      text:
          'Chúng tôi đã cập nhật tính năng mới và sửa một số lỗi. Vui lòng cập nhật để có trải nghiệm tốt nhất.',
    );
    bool forceUpdate = true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thông báo cập nhật ứng dụng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: versionController,
                  decoration: const InputDecoration(
                    labelText: 'Phiên bản mới',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Thông báo cập nhật',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Bắt buộc cập nhật'),
                  subtitle: const Text(
                    'Người dùng phải cập nhật để tiếp tục sử dụng ứng dụng',
                  ),
                  value: forceUpdate,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      forceUpdate = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement update notification logic
                Get.back();
                successMessage('Đã gửi thông báo cập nhật cho người dùng');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
              child: const Text('GỬI THÔNG BÁO'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Simulate backup creation
      await Future.delayed(const Duration(seconds: 2));

      Get.back();
      successMessage('Đã tạo bản sao lưu thành công');
    } catch (e) {
      Get.back();
      errorMessage('Lỗi khi tạo bản sao lưu: $e');
    }
  }

  void _showRestoreDialog() {
    // Mock backup data
    final backups = [
      {'date': '23/03/2025', 'size': '124 MB', 'id': 'backup1'},
      {'date': '22/03/2025', 'size': '123 MB', 'id': 'backup2'},
      {'date': '21/03/2025', 'size': '122 MB', 'id': 'backup3'},
    ];

    String? selectedBackupId;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Khôi phục dữ liệu'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn bản sao lưu để khôi phục:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cảnh báo: Khôi phục sẽ ghi đè lên dữ liệu hiện tại. Quá trình này không thể hoàn tác.',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: backups.length,
                    itemBuilder: (context, index) {
                      final backup = backups[index];
                      final isSelected = backup['id'] == selectedBackupId;

                      return RadioListTile<String>(
                        title: Text('Sao lưu ngày ${backup['date']}'),
                        subtitle: Text('Kích thước: ${backup['size']}'),
                        value: backup['id'] as String,
                        groupValue: selectedBackupId,
                        onChanged: (value) {
                          setState(() {
                            selectedBackupId = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              onPressed: selectedBackupId != null
                  ? () {
                      Get.back();
                      _confirmRestore(selectedBackupId!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: const Text('KHÔI PHỤC'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestore(String backupId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận khôi phục'),
        content: const Text(
          'Bạn có chắc chắn muốn khôi phục dữ liệu từ bản sao lưu này? Dữ liệu hiện tại sẽ bị mất.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              // Simulate restore process
              await Future.delayed(const Duration(seconds: 3));

              Get.back();
              successMessage('Khôi phục dữ liệu thành công');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('XÁC NHẬN'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllReportsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Xóa tất cả báo cáo'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả báo cáo? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              // Simulate deletion process
              await Future.delayed(const Duration(seconds: 2));

              Get.back();
              successMessage('Đã xóa tất cả báo cáo thành công');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('XÓA TẤT CẢ'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Đặt lại cài đặt'),
        content: const Text(
          'Bạn có chắc chắn muốn đặt lại tất cả cài đặt quản trị về mặc định?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              setState(() {
                _maintenance = false;
                _enableRealTimeReports = true;
                _enableBackupDaily = true;
                _notifyAdminsOnReport = true;
                _autoDeleteReportsAfterDays = 30;
              });

              await _saveSettings();
              successMessage('Đã đặt lại cài đặt thành công');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ĐẶT LẠI'),
          ),
        ],
      ),
    );
  }
}
