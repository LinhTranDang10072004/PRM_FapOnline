import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../providers/staff_schedule_provider.dart';
import '../../data/models/staff_models.dart';
import '../widgets/staff_widgets.dart';

class StaffScheduleScreen extends StatefulWidget {
  const StaffScheduleScreen({super.key});

  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _baseDate = DateTime.now();
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    context.read<StaffScheduleProvider>().loadSchedules(date: dateStr);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffScheduleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Lịch học',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Chọn ngày',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  _baseDate = picked;
                  _selectedDate = picked;
                });
                _loadForDate(picked);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Hôm nay',
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _baseDate = now;
                _selectedDate = now;
              });
              _loadForDate(now);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateScheduleSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo lịch'),
      ),
      body: Column(
        children: [
          _buildDateStrip(),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    color: AppColors.primary,
                    child: provider.schedules.isEmpty
                        ? const _EmptyView()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                            itemCount: provider.schedules.length,
                            itemBuilder: (_, i) => _ScheduleCard(
                              schedule: provider.schedules[i],
                              onEdit: () => _showEditScheduleSheet(
                                  context, provider.schedules[i]),
                              onDelete: () => _showDeleteConfirm(
                                  context, provider.schedules[i]),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    final days = List.generate(7, (i) {
      final d = _baseDate.subtract(Duration(days: 3 - i));
      return d;
    });

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            onPressed: () {
              setState(() => _baseDate = _baseDate.subtract(const Duration(days: 7)));
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) {
                final isSelected = DateFormat('yyyy-MM-dd').format(day) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDate);
                final isToday = DateFormat('yyyy-MM-dd').format(day) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = day);
                    _loadForDate(day);
                  },
            child: Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('E', 'vi_VN').format(day).substring(0, 2),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : AppColors.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? AppColors.primaryLight
                              : AppColors.textPrimary,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
          }).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            onPressed: () {
              setState(() => _baseDate = _baseDate.add(const Duration(days: 7)));
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  void _showCreateScheduleSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final classIdCtrl = TextEditingController();
    final roomIdCtrl = TextEditingController();
    final slotIdCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final dateCtrl = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(_selectedDate));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              children: [
                const Text('Tạo lịch học mới',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _formField(classIdCtrl, 'ID Lớp học *', isNum: true, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Không được để trống';
                  if (int.tryParse(v) == null) return 'ID không hợp lệ';
                  return null;
                }),
                const SizedBox(height: 10),
                _formField(roomIdCtrl, 'ID Phòng học *', isNum: true, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Không được để trống';
                  if (int.tryParse(v) == null) return 'ID không hợp lệ';
                  return null;
                }),
                const SizedBox(height: 10),
                _formField(slotIdCtrl, 'ID Ca học *', isNum: true, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Không được để trống';
                  if (int.tryParse(v) == null) return 'ID không hợp lệ';
                  return null;
                }),
                const SizedBox(height: 10),
                _formField(dateCtrl, 'Ngày (yyyy-MM-dd) *', validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Không được để trống';
                  try {
                    DateFormat('yyyy-MM-dd').parseStrict(v);
                  } catch (_) {
                    return 'Định dạng yyyy-MM-dd không hợp lệ';
                  }
                  return null;
                }),
                const SizedBox(height: 10),
                _formField(noteCtrl, 'Ghi chú (tùy chọn)'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      final req = StaffCreateScheduleRequest(
                        classId: int.parse(classIdCtrl.text),
                        roomId: int.parse(roomIdCtrl.text),
                        timeSlotId: int.parse(slotIdCtrl.text),
                        scheduleDate: dateCtrl.text.trim(),
                        note: noteCtrl.text.trim(),
                      );
                      final provider = context.read<StaffScheduleProvider>();
                      final ok = await provider.createSchedule(req);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? 'Tạo lịch thành công!'
                            : (provider.error ?? 'Lỗi')),
                        backgroundColor: ok ? AppColors.success : AppColors.error,
                      ));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Tạo lịch',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditScheduleSheet(BuildContext context, ScheduleModel s) {
    final formKey = GlobalKey<FormState>();
    final roomIdCtrl =
        TextEditingController(text: s.roomId?.toString() ?? '');
    final slotIdCtrl =
        TextEditingController(text: s.timeSlotId?.toString() ?? '');
    final noteCtrl = TextEditingController(text: s.note ?? '');
    final dateCtrl =
        TextEditingController(text: s.scheduleDate ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              children: [
                const Text('Sửa lịch học',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _formField(roomIdCtrl, 'ID Phòng học', isNum: true, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Không được để trống';
                  if (int.tryParse(v) == null) return 'ID không hợp lệ';
                  return null;
                }),
                const SizedBox(height: 10),
                _formField(slotIdCtrl, 'ID Ca học', isNum: true, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Không được để trống';
                  if (int.tryParse(v) == null) return 'ID không hợp lệ';
                  return null;
                }),
                const SizedBox(height: 10),
                _formField(dateCtrl, 'Ngày (yyyy-MM-dd)', validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Không được để trống';
                  try {
                    DateFormat('yyyy-MM-dd').parseStrict(v);
                  } catch (_) {
                    return 'Định dạng yyyy-MM-dd không hợp lệ';
                  }
                  return null;
                }),
                const SizedBox(height: 10),
                _formField(noteCtrl, 'Ghi chú'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      final req = StaffUpdateScheduleRequest(
                        roomId: int.tryParse(roomIdCtrl.text),
                        timeSlotId: int.tryParse(slotIdCtrl.text),
                        scheduleDate: dateCtrl.text.trim().isNotEmpty
                            ? dateCtrl.text.trim()
                            : null,
                        note: noteCtrl.text.trim().isNotEmpty
                            ? noteCtrl.text.trim()
                            : null,
                      );
                      final provider = context.read<StaffScheduleProvider>();
                      final ok =
                          await provider.updateSchedule(s.scheduleId!, req);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? 'Sửa lịch thành công!'
                            : (provider.error ?? 'Lỗi')),
                        backgroundColor: ok ? AppColors.success : AppColors.error,
                      ));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Lưu thay đổi',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, ScheduleModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa lịch học?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Xóa buổi học ngày ${s.displayDate} - ${s.className ?? ''}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              final provider = context.read<StaffScheduleProvider>();
              final ok = await provider.deleteSchedule(s.scheduleId!);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(ok ? 'Đã xóa lịch!' : (provider.error ?? 'Lỗi')),
                backgroundColor: ok ? AppColors.success : AppColors.error,
              ));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label,
      {bool isNum = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─── Schedule Card ────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          schedule.className ?? schedule.classCode ?? '—',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (schedule.status != null)
                        StatusBadge(status: schedule.status!),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        schedule.displayTime,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.room_rounded,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        schedule.roomName ?? '—',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (schedule.note?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      schedule.note!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textHint),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded,
                    size: 18, color: AppColors.primaryLight),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded,
                    size: 18, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 60, color: AppColors.textHint),
              SizedBox(height: 12),
              Text('Không có lịch học trong ngày này',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}
