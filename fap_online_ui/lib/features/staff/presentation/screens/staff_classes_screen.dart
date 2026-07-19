import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../providers/staff_class_provider.dart';
import '../../data/models/staff_models.dart';
import '../widgets/staff_widgets.dart';
import 'staff_class_detail_screen.dart';

class StaffClassesScreen extends StatefulWidget {
  const StaffClassesScreen({super.key});

  @override
  State<StaffClassesScreen> createState() => _StaffClassesScreenState();
}

class _StaffClassesScreenState extends State<StaffClassesScreen> {
  String _statusFilter = 'All';
  final List<String> _statusOptions = ['All', 'Draft', 'Open', 'In Progress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffClassProvider>().loadClasses();
    });
  }

  List<ClassModel> _filteredClasses(List<ClassModel> all) {
    if (_statusFilter == 'All') return all;
    return all.where((c) => c.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffClassProvider>();
    final displayed = _filteredClasses(provider.classes);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Quản lý Lớp học',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.loadClasses(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateClassDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo lớp'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : provider.error != null && provider.classes.isEmpty
                    ? _ErrorView(
                        message: provider.error!,
                        onRetry: provider.loadClasses)
                    : displayed.isEmpty
                        ? const _EmptyView()
                        : RefreshIndicator(
                            onRefresh: () => provider.loadClasses(),
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: displayed.length,
                              itemBuilder: (_, i) => _ClassCard(
                                classModel: displayed[i],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StaffClassDetailScreen(
                                      classId: displayed[i].classId!,
                                    ),
                                  ),
                                ).then((_) => provider.loadClasses()),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statusOptions.map((s) {
            final active = _statusFilter == s;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(s),
                selected: active,
                onSelected: (_) => setState(() => _statusFilter = s),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
                checkmarkColor: Colors.white,
                backgroundColor: AppColors.background,
                side: BorderSide(
                    color: active ? AppColors.primary : AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final semesterCtrl = TextEditingController();
    final maxCtrl = TextEditingController(text: '30');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateClassSheet(
        formKey: formKey,
        codeCtrl: codeCtrl,
        nameCtrl: nameCtrl,
        subjectCtrl: subjectCtrl,
        semesterCtrl: semesterCtrl,
        maxCtrl: maxCtrl,
        onSubmit: () async {
          if (!formKey.currentState!.validate()) return;
          final req = CreateClassRequest(
            classCode: codeCtrl.text.trim(),
            className: nameCtrl.text.trim(),
            subjectId: int.tryParse(subjectCtrl.text) ?? 0,
            semesterId: int.tryParse(semesterCtrl.text) ?? 0,
            maxStudents: int.tryParse(maxCtrl.text) ?? 30,
          );
          final provider = context.read<StaffClassProvider>();
          final ok = await provider.createClass(req);
          if (!context.mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok ? 'Tạo lớp thành công!' : (provider.error ?? 'Lỗi')),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ));
        },
      ),
    );
  }
}

// ─── Class Card ────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;

  const _ClassCard({required this.classModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final filled = classModel.currentStudents ?? 0;
    final max = classModel.maxStudents ?? 1;
    final pct = (max > 0 ? filled / max : 0.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classModel.className ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${classModel.classCode ?? ''} • ${classModel.subjectCode ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (classModel.status != null)
                  StatusBadge(status: classModel.status!),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    classModel.teacherName ?? 'Chưa phân công GV',
                    style: TextStyle(
                      fontSize: 12,
                      color: classModel.teacherName != null
                          ? AppColors.textSecondary
                          : AppColors.warning,
                      fontWeight: classModel.teacherName == null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  '$filled / $max SV',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: AppColors.divider,
                color: pct > 0.9 ? AppColors.error : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Class Bottom Sheet ─────────────────────────────────────────────

class _CreateClassSheet extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController codeCtrl, nameCtrl, subjectCtrl, semesterCtrl, maxCtrl;
  final VoidCallback onSubmit;

  const _CreateClassSheet({
    required this.formKey,
    required this.codeCtrl,
    required this.nameCtrl,
    required this.subjectCtrl,
    required this.semesterCtrl,
    required this.maxCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Tạo lớp học mới',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(codeCtrl, 'Mã lớp *', 'VD: SE1234'),
              const SizedBox(height: 12),
              _field(nameCtrl, 'Tên lớp *', 'VD: Lập trình Mobile'),
              const SizedBox(height: 12),
              _field(subjectCtrl, 'ID Môn học *', '1', isNum: true),
              const SizedBox(height: 12),
              _field(semesterCtrl, 'ID Học kỳ *', '1', isNum: true),
              const SizedBox(height: 12),
              _field(maxCtrl, 'Sĩ số tối đa *', '30', isNum: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Tạo lớp',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint,
      {bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.class_outlined, size: 60, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text('Không có lớp học nào',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 52, color: AppColors.error),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
