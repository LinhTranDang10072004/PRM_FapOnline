import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../providers/staff_class_provider.dart';
import '../../data/models/staff_models.dart';
import '../widgets/staff_widgets.dart';

class StaffClassDetailScreen extends StatefulWidget {
  final int classId;

  const StaffClassDetailScreen({super.key, required this.classId});

  @override
  State<StaffClassDetailScreen> createState() => _StaffClassDetailScreenState();
}

class _StaffClassDetailScreenState extends State<StaffClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StaffClassProvider>();
      provider.loadClassDetail(widget.classId);
      provider.loadReferences();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffClassProvider>();
    final cls = provider.selectedClass;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          cls?.className ?? 'Chi tiết lớp',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        actions: [
          if (cls != null && cls.status != 'Cancelled')
            PopupMenuButton<String>(
              onSelected: (v) => _handleMenuAction(context, v, cls),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Sửa thông tin'),
                ),
                const PopupMenuItem(
                  value: 'assign',
                  child: Text('Phân công GV'),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text(
                    'Hủy lớp',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Sinh viên'),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _InfoTab(cls: cls),
                _StudentsTab(
                  students: provider.students,
                  classId: widget.classId,
                ),
              ],
            ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, ClassModel cls) {
    switch (action) {
      case 'edit':
        _showEditDialog(context, cls);
        break;
      case 'assign':
        _showAssignTeacherDialog(context, cls);
        break;
      case 'cancel':
        _showCancelConfirm(context, cls);
        break;
    }
  }

  void _showEditDialog(BuildContext context, ClassModel cls) {
    final nameCtrl = TextEditingController(text: cls.className);
    final maxCtrl = TextEditingController(
      text: cls.maxStudents?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Sửa thông tin lớp',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Tên lớp',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sĩ số tối đa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final req = UpdateClassRequest(
                className: nameCtrl.text.trim(),
                maxStudents: int.tryParse(maxCtrl.text),
              );
              final provider = context.read<StaffClassProvider>();
              final ok = await provider.updateClass(cls.classId!, req);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'Cập nhật thành công!' : (provider.error ?? 'Lỗi'),
                  ),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAssignTeacherDialog(BuildContext context, ClassModel cls) {
    final formKey = GlobalKey<FormState>();
    int? selectedTeacherId = cls.teacherId;
    final allTeachers = context.read<StaffClassProvider>().allTeachers;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Phân công Giáo viên',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: DropdownButtonFormField<int>(
            value: allTeachers.any((t) => t.teacherId == selectedTeacherId)
                ? selectedTeacherId
                : null,
            decoration: InputDecoration(
              labelText: 'Chọn Giáo viên',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: allTeachers.map((t) {
              return DropdownMenuItem<int>(
                value: t.teacherId,
                child: Text('[${t.teacherCode}] ${t.fullName}'),
              );
            }).toList(),
            onChanged: (val) {
              selectedTeacherId = val;
            },
            validator: (v) => v == null ? 'Vui lòng chọn giáo viên' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              if (selectedTeacherId == null) return;
              final provider = context.read<StaffClassProvider>();
              final ok = await provider.assignTeacher(
                cls.classId!,
                selectedTeacherId!,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'Phân công thành công!' : (provider.error ?? 'Lỗi'),
                  ),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Phân công'),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirm(BuildContext context, ClassModel cls) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Hủy lớp học?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc muốn hủy lớp "${cls.className}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () async {
              final provider = context.read<StaffClassProvider>();
              final ok = await provider.cancelClass(cls.classId!);
              if (!context.mounted) return;
              Navigator.pop(context);
              if (ok) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Đã hủy lớp!' : (provider.error ?? 'Lỗi')),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hủy lớp'),
          ),
        ],
      ),
    );
  }
}

// ─── Info Tab ────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final ClassModel? cls;

  const _InfoTab({this.cls});

  @override
  Widget build(BuildContext context) {
    if (cls == null) return const Center(child: Text('Không có dữ liệu'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Thông tin lớp',
          items: [
            _InfoRow('Mã lớp', cls!.classCode),
            _InfoRow('Tên lớp', cls!.className),
            _InfoRow(
              'Môn học',
              '${cls!.subjectName ?? ''} (${cls!.subjectCode ?? ''})',
            ),
            _InfoRow('Học kỳ', cls!.semesterName),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Giảng dạy & Sĩ số',
          items: [
            _InfoRow('Giáo viên', cls!.teacherName ?? 'Chưa phân công'),
            _InfoRow('Sĩ số tối đa', '${cls!.maxStudents ?? '—'}'),
            _InfoRow('Đang đăng ký', '${cls!.currentStudents ?? 0}'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Trạng thái: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (cls!.status != null) StatusBadge(status: cls!.status!),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> items;

  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 20),
          ...items,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '—',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Students Tab ────────────────────────────────────────────────────────────

class _StudentsTab extends StatelessWidget {
  final List<ClassStudentModel> students;
  final int classId;

  const _StudentsTab({required this.students, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Text(
                '${students.length} sinh viên',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddStudentDialog(context),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Thêm SV'),
              ),
            ],
          ),
        ),
        Expanded(
          child: students.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có sinh viên',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (_, i) => _StudentTile(
                    student: students[i],
                    onRemove: () => _showRemoveConfirm(context, students[i]),
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int? selectedStudentId;
    final provider = context.read<StaffClassProvider>();
    final allStudents = provider.allStudents;
    final availableStudents = allStudents
        .where((s) => !students.any((cs) => cs.studentId == s.studentId))
        .toList();

    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Thêm Sinh viên',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Form(
              key: formKey,
              child: DropdownMenu<int>(
                enableFilter: true,
                enableSearch: true,
                width: 250,
                menuHeight: 300,
                label: const Text('Tìm / Chọn Sinh viên'),
                errorText: errorText,
                dropdownMenuEntries: availableStudents.map((s) {
                  return DropdownMenuEntry<int>(
                    value: s.studentId,
                    label: '[${s.studentCode}] ${s.fullName}',
                  );
                }).toList(),
                onSelected: (val) {
                  setState(() {
                    selectedStudentId = val;
                    errorText = null;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () async {
                  if (selectedStudentId == null) {
                    setState(() => errorText = 'Vui lòng chọn sinh viên');
                    return;
                  }
                  final provider = context.read<StaffClassProvider>();
                  final ok = await provider.addStudentToClass(
                    classId,
                    selectedStudentId!,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok ? 'Thêm thành công!' : (provider.error ?? 'Lỗi'),
                      ),
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Thêm'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoveConfirm(BuildContext context, ClassStudentModel student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Xóa sinh viên?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Xóa ${student.fullName ?? student.studentCode} khỏi lớp?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final provider = context.read<StaffClassProvider>();
              final ok = await provider.removeStudentFromClass(
                classId,
                student.studentId!,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Đã xóa!' : (provider.error ?? 'Lỗi')),
                  backgroundColor: ok ? AppColors.success : AppColors.error,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final ClassStudentModel student;
  final VoidCallback onRemove;

  const _StudentTile({required this.student, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight.withOpacity(0.1),
            child: Text(
              (student.fullName?.isNotEmpty == true)
                  ? student.fullName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primaryLight,
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
                  student.fullName ?? '—',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  student.studentCode ?? '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
