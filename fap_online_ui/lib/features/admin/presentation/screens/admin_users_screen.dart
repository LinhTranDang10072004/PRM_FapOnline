import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/admin_models.dart';
import '../providers/admin_user_provider.dart';

const _roles = ['ADMIN', 'STAFF', 'TEACHER', 'STUDENT', 'PARENT'];

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUserProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Quản lý tài khoản',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserSheet(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Thêm user'),
      ),
      body: Column(
        children: [
          _buildFilters(provider),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildFilters(AdminUserProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Tìm username, họ tên, email...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: () {
                  provider.setQuery(_searchCtrl.text.trim());
                  provider.search();
                },
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onSubmitted: (v) {
              provider.setQuery(v.trim());
              provider.search();
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả role',
                  selected: provider.roleFilter.isEmpty,
                  onTap: () => provider.setRoleFilter(''),
                ),
                ..._roles.map(
                  (r) => _FilterChip(
                    label: r,
                    selected: provider.roleFilter == r,
                    onTap: () => provider.setRoleFilter(r),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả trạng thái',
                  selected: provider.statusFilter.isEmpty,
                  onTap: () => provider.setStatusFilter(''),
                ),
                _FilterChip(
                  label: 'Active',
                  selected: provider.statusFilter == 'Active',
                  onTap: () => provider.setStatusFilter('Active'),
                ),
                _FilterChip(
                  label: 'Locked',
                  selected: provider.statusFilter == 'Locked',
                  onTap: () => provider.setStatusFilter('Locked'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminUserProvider provider) {
    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (provider.error != null && provider.users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: provider.loadUsers,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    if (provider.users.isEmpty) {
      return const Center(child: Text('Không có tài khoản nào'));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: provider.loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: provider.users.length,
        itemBuilder: (context, index) {
          final user = provider.users[index];
          return _UserCard(
            user: user,
            onEdit: () => _showUserSheet(existing: user),
            onToggleLock: () => _confirmToggleLock(user),
            onDelete: () => _confirmDelete(user),
          );
        },
      ),
    );
  }

  Future<void> _confirmToggleLock(AdminUserModel user) async {
    final lock = !user.isLocked;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lock ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?'),
        content: Text(
          lock
              ? 'User "${user.username}" sẽ không đăng nhập được.'
              : 'User "${user.username}" sẽ đăng nhập được lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(lock ? 'Khóa' : 'Mở khóa'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final provider = context.read<AdminUserProvider>();
    final success = await provider.toggleLock(user);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (lock ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản')
              : (provider.error ?? 'Thất bại'),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AdminUserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: Text('Xóa "${user.username}"? Hành động này không hoàn tác dễ dàng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final provider = context.read<AdminUserProvider>();
    final success = await provider.deleteUser(user.userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã xóa tài khoản' : (provider.error ?? 'Xóa thất bại')),
      ),
    );
  }

  Future<void> _showUserSheet({AdminUserModel? existing}) async {
    final isEdit = existing != null;
    final usernameCtrl = TextEditingController(text: existing?.username ?? '');
    final passwordCtrl = TextEditingController();
    final fullNameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final profileCodeCtrl = TextEditingController();
    String roleName = existing?.primaryRole?.toUpperCase() ?? 'STUDENT';
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEdit ? 'Sửa tài khoản' : 'Thêm tài khoản',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!isEdit) ...[
                        TextFormField(
                          controller: usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Username *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: isEdit
                              ? 'Password mới (để trống nếu không đổi)'
                              : 'Password *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (!isEdit && (v == null || v.length < 6)) {
                            return 'Tối thiểu 6 ký tự';
                          }
                          if (isEdit && v != null && v.isNotEmpty && v.length < 6) {
                            return 'Tối thiểu 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: fullNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: roleName,
                        decoration: const InputDecoration(
                          labelText: 'Role *',
                          border: OutlineInputBorder(),
                        ),
                        items: _roles
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setModalState(() => roleName = v);
                        },
                      ),
                      if (!isEdit) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: profileCodeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Mã hồ sơ (tùy chọn)',
                            hintText: 'VD: SE18099, TC010...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final provider = context.read<AdminUserProvider>();
                          bool ok;
                          if (isEdit) {
                            ok = await provider.updateUser(
                              existing.userId,
                              AdminUserUpdateRequest(
                                fullName: fullNameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                password: passwordCtrl.text.trim().isEmpty
                                    ? null
                                    : passwordCtrl.text.trim(),
                                roleName: roleName,
                              ),
                            );
                          } else {
                            ok = await provider.createUser(
                              AdminUserCreateRequest(
                                username: usernameCtrl.text.trim(),
                                password: passwordCtrl.text.trim(),
                                fullName: fullNameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                roleName: roleName,
                                profileCode: profileCodeCtrl.text.trim().isEmpty
                                    ? null
                                    : profileCodeCtrl.text.trim(),
                              ),
                            );
                          }
                          if (!ctx.mounted) return;
                          if (ok) {
                            Navigator.pop(ctx, true);
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(provider.error ?? 'Lưu thất bại'),
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(isEdit ? 'Lưu thay đổi' : 'Tạo tài khoản'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    usernameCtrl.dispose();
    passwordCtrl.dispose();
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    profileCodeCtrl.dispose();

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Đã cập nhật tài khoản' : 'Đã tạo tài khoản'),
        ),
      );
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onEdit;
  final VoidCallback onToggleLock;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onToggleLock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final locked = user.isLocked;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '@${user.username} · ${user.email}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'edit':
                      onEdit();
                    case 'lock':
                      onToggleLock();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  PopupMenuItem(
                    value: 'lock',
                    child: Text(locked ? 'Mở khóa' : 'Khóa'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Xóa',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Badge(
                text: user.roleLabel,
                bg: const Color(0xFFEDE9FE),
                fg: const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 8),
              _Badge(
                text: user.status,
                bg: locked ? AppColors.errorLight : AppColors.successLight,
                fg: locked ? AppColors.error : AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Badge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
