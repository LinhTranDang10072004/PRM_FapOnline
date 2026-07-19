import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/admin_models.dart';
import '../providers/admin_role_provider.dart';

class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminRoleProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminRoleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Quản lý Role',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Danh sách Role'),
            Tab(text: 'Gán Role'),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showRoleSheet(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tạo role'),
            )
          : null,
      body: provider.isLoading && provider.roles.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : provider.error != null && provider.roles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(provider.error!),
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
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _RolesTab(
                      onEdit: (role) => _showRoleSheet(existing: role),
                      onDelete: _confirmDelete,
                    ),
                    const _AssignTab(),
                  ],
                ),
    );
  }

  Future<void> _confirmDelete(AdminRoleModel role) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa role?'),
        content: Text('Xóa role "${role.roleName}"? Chỉ xóa được nếu chưa gán user.'),
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
    final provider = context.read<AdminRoleProvider>();
    final success = await provider.deleteRole(role.roleId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã xóa role' : (provider.error ?? 'Xóa thất bại'),
        ),
      ),
    );
  }

  Future<void> _showRoleSheet({AdminRoleModel? existing}) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.roleName ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    var isActive = existing?.isActive ?? true;
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEdit ? 'Sửa role' : 'Tạo role mới',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Tên role *',
                        hintText: 'VD: MODERATOR',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Đang hoạt động'),
                      value: isActive,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setModalState(() => isActive = v),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final provider = context.read<AdminRoleProvider>();
                        final request = AdminRoleRequest(
                          roleName: nameCtrl.text.trim().toUpperCase(),
                          description: descCtrl.text.trim(),
                          isActive: isActive,
                        );
                        final ok = isEdit
                            ? await provider.updateRole(
                                existing.roleId,
                                request,
                              )
                            : await provider.createRole(request);
                        if (!ctx.mounted) return;
                        if (ok) {
                          Navigator.pop(ctx, true);
                        } else {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content:
                                  Text(provider.error ?? 'Lưu thất bại'),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(isEdit ? 'Lưu' : 'Tạo role'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    nameCtrl.dispose();
    descCtrl.dispose();

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Đã cập nhật role' : 'Đã tạo role')),
      );
    }
  }
}

class _RolesTab extends StatelessWidget {
  final void Function(AdminRoleModel role) onEdit;
  final void Function(AdminRoleModel role) onDelete;

  const _RolesTab({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminRoleProvider>();

    if (provider.roles.isEmpty) {
      return const Center(child: Text('Chưa có role nào'));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: provider.load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: provider.roles.length,
        itemBuilder: (context, index) {
          final role = provider.roles[index];
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
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.roleName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (role.description != null &&
                          role.description!.isNotEmpty)
                        Text(
                          role.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${role.userCount} user · ${role.isActive ? 'Active' : 'Inactive'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: role.isActive
                              ? AppColors.success
                              : AppColors.textHint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => onEdit(role),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => onDelete(role),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AssignTab extends StatefulWidget {
  const _AssignTab();

  @override
  State<_AssignTab> createState() => _AssignTabState();
}

class _AssignTabState extends State<_AssignTab> {
  int? _selectedUserId;
  int? _selectedRoleId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminRoleProvider>();
    final users = provider.users;
    final roles = provider.activeRoles;

    AdminUserModel? selectedUser;
    for (final u in users) {
      if (u.userId == _selectedUserId) {
        selectedUser = u;
        break;
      }
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: provider.load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Gán / thu hồi role',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _selectedUserId,
            decoration: const InputDecoration(
              labelText: 'Chọn user',
              border: OutlineInputBorder(),
            ),
            items: users
                .map(
                  (u) => DropdownMenuItem(
                    value: u.userId,
                    child: Text('${u.fullName} (@${u.username})'),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedUserId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _selectedRoleId,
            decoration: const InputDecoration(
              labelText: 'Chọn role',
              border: OutlineInputBorder(),
            ),
            items: roles
                .map(
                  (r) => DropdownMenuItem(
                    value: r.roleId,
                    child: Text(r.roleName),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedRoleId = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _assign(provider),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Gán role'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _unassign(provider),
                  icon: const Icon(Icons.person_remove_rounded),
                  label: const Text('Thu hồi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (selectedUser != null) ...[
            const SizedBox(height: 24),
            Text(
              'Role hiện tại của @${selectedUser.username}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (selectedUser.roles.isEmpty)
              const Text(
                'Chưa có role',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedUser.roles
                    .map(
                      (r) => Chip(
                        label: Text(r),
                        backgroundColor: const Color(0xFFEDE9FE),
                        labelStyle: const TextStyle(
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _assign(AdminRoleProvider provider) async {
    if (_selectedUserId == null || _selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn user và role trước')),
      );
      return;
    }
    final ok = await provider.assignRole(_selectedUserId!, _selectedRoleId!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Đã gán role' : (provider.error ?? 'Gán thất bại')),
      ),
    );
    setState(() {});
  }

  Future<void> _unassign(AdminRoleProvider provider) async {
    if (_selectedUserId == null || _selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn user và role trước')),
      );
      return;
    }
    final ok =
        await provider.unassignRole(_selectedUserId!, _selectedRoleId!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Đã thu hồi role' : (provider.error ?? 'Thu hồi thất bại'),
        ),
      ),
    );
    setState(() {});
  }
}
