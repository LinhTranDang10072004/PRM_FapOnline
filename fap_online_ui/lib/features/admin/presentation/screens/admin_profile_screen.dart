import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/admin_models.dart';
import '../providers/admin_profile_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProfileProvider>().load();
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _fillFromProfile(AdminProfileModel profile) {
    if (_filled) return;
    _fullNameCtrl.text = profile.fullName;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone ?? '';
    _addressCtrl.text = profile.address ?? '';
    _filled = true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProfileProvider>();
    final profile = provider.profile;
    if (profile != null) _fillFromProfile(profile);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _filled = false;
              provider.load();
            },
          ),
        ],
      ),
      body: provider.isLoading && profile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : provider.error != null && profile == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(provider.error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: provider.load,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    _filled = false;
                    await provider.load();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(profile),
                          const SizedBox(height: 20),
                          const Text(
                            'Thông tin cá nhân',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _fullNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Bắt buộc'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Bắt buộc'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Địa chỉ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed:
                                provider.isSaving ? null : _saveProfile,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: provider.isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Lưu thông tin'),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Đổi mật khẩu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Nhập mật khẩu cũ và mật khẩu mới. Không cần gửi email.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _oldPassCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Mật khẩu cũ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _newPassCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Mật khẩu mới (≥ 8 ký tự)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPassCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Xác nhận mật khẩu mới',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: provider.isSaving
                                ? null
                                : _changePassword,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryDark,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Đổi mật khẩu'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader(AdminProfileModel? profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Text(
              (profile?.fullName.isNotEmpty == true)
                  ? profile!.fullName[0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.fullName ?? 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${profile?.username ?? ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: (profile?.roles ?? ['ADMIN'])
                      .map(
                        (r) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            r,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AdminProfileProvider>();
    final ok = await provider.updateProfile(
      AdminProfileUpdateRequest(
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Đã cập nhật hồ sơ' : (provider.error ?? 'Cập nhật thất bại'),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final oldP = _oldPassCtrl.text;
    final newP = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (oldP.isEmpty || newP.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Điền đủ 3 ô mật khẩu')),
      );
      return;
    }
    if (newP.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới tối thiểu 8 ký tự')),
      );
      return;
    }
    if (newP != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác nhận mật khẩu không khớp')),
      );
      return;
    }

    final provider = context.read<AdminProfileProvider>();
    final ok = await provider.changePassword(
      AdminChangePasswordRequest(
        oldPassword: oldP,
        newPassword: newP,
        confirmPassword: confirm,
      ),
    );
    if (!mounted) return;
    if (ok) {
      _oldPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Đã đổi mật khẩu' : (provider.error ?? 'Đổi mật khẩu thất bại'),
        ),
      ),
    );
  }
}
