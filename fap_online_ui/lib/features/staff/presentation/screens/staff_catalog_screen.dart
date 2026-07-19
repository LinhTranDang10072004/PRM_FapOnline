import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/staff_models.dart';
import '../providers/staff_room_provider.dart';
import '../providers/staff_timeslot_provider.dart';

class StaffCatalogScreen extends StatefulWidget {
  const StaffCatalogScreen({super.key});

  @override
  State<StaffCatalogScreen> createState() => _StaffCatalogScreenState();
}

class _StaffCatalogScreenState extends State<StaffCatalogScreen>
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
      context.read<StaffRoomProvider>().loadRooms();
      context.read<StaffTimeSlotProvider>().loadTimeSlots();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Phòng & Ca học',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Phòng học'),
            Tab(text: 'Ca học'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showRoomSheet();
          } else {
            _showTimeSlotSheet();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(_tabController.index == 0 ? 'Thêm phòng' : 'Thêm ca'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RoomsTab(onEdit: (room) => _showRoomSheet(existing: room)),
          _TimeSlotsTab(onEdit: (slot) => _showTimeSlotSheet(existing: slot)),
        ],
      ),
    );
  }

  Future<void> _showRoomSheet({RoomModel? existing}) async {
    final codeCtrl = TextEditingController(text: existing?.roomCode ?? '');
    final nameCtrl = TextEditingController(text: existing?.roomName ?? '');
    final capacityCtrl =
        TextEditingController(text: existing?.capacity.toString() ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    String status = existing?.status ?? 'Active';
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
            builder: (context, setModalState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        existing == null ? 'Thêm phòng học' : 'Sửa phòng học',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: codeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mã phòng *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tên phòng *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: capacityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sức chứa *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1) return 'Số > 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: locationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Vị trí',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'Inactive', child: Text('Inactive')),
                          DropdownMenuItem(
                              value: 'Maintenance',
                              child: Text('Maintenance')),
                        ],
                        onChanged: (v) =>
                            setModalState(() => status = v ?? 'Active'),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final request = RoomRequest(
                            roomCode: codeCtrl.text.trim(),
                            roomName: nameCtrl.text.trim(),
                            capacity: int.parse(capacityCtrl.text.trim()),
                            location: locationCtrl.text.trim().isEmpty
                                ? null
                                : locationCtrl.text.trim(),
                            status: status,
                          );
                          final provider = context.read<StaffRoomProvider>();
                          final ok = existing == null
                              ? await provider.createRoom(request)
                              : await provider.updateRoom(
                                  existing.roomId, request);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx, ok);
                        },
                        child: Text(existing == null ? 'Tạo phòng' : 'Lưu'),
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

    if (!mounted) return;
    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existing == null
              ? 'Đã thêm phòng học'
              : 'Đã cập nhật phòng học'),
        ),
      );
    } else if (saved == false) {
      final err = context.read<StaffRoomProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Thao tác thất bại')),
      );
    }
  }

  Future<void> _showTimeSlotSheet({TimeSlotModel? existing}) async {
    final codeCtrl = TextEditingController(text: existing?.slotCode ?? '');
    final nameCtrl = TextEditingController(text: existing?.slotName ?? '');
    final startCtrl = TextEditingController(text: existing?.startTime ?? '07:30');
    final endCtrl = TextEditingController(text: existing?.endTime ?? '09:50');
    String status = existing?.status ?? 'Active';
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
            builder: (context, setModalState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        existing == null ? 'Thêm ca học' : 'Sửa ca học',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: codeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mã ca *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tên ca *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: startCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Giờ bắt đầu (HH:mm) *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            _isValidTime(v) ? null : 'Định dạng HH:mm',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: endCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Giờ kết thúc (HH:mm) *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            _isValidTime(v) ? null : 'Định dạng HH:mm',
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'Inactive', child: Text('Inactive')),
                        ],
                        onChanged: (v) =>
                            setModalState(() => status = v ?? 'Active'),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final request = TimeSlotRequest(
                            slotCode: codeCtrl.text.trim(),
                            slotName: nameCtrl.text.trim(),
                            startTime: startCtrl.text.trim(),
                            endTime: endCtrl.text.trim(),
                            status: status,
                          );
                          final provider =
                              context.read<StaffTimeSlotProvider>();
                          final ok = existing == null
                              ? await provider.createTimeSlot(request)
                              : await provider.updateTimeSlot(
                                  existing.timeSlotId, request);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx, ok);
                        },
                        child: Text(existing == null ? 'Tạo ca' : 'Lưu'),
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

    if (!mounted) return;
    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(existing == null ? 'Đã thêm ca học' : 'Đã cập nhật ca học'),
        ),
      );
    } else if (saved == false) {
      final err = context.read<StaffTimeSlotProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Thao tác thất bại')),
      );
    }
  }

  bool _isValidTime(String? value) {
    if (value == null) return false;
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').hasMatch(value.trim());
    return match;
  }
}

class _RoomsTab extends StatelessWidget {
  final void Function(RoomModel room) onEdit;

  const _RoomsTab({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffRoomProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.rooms.isEmpty) {
      return const Center(child: Text('Chưa có phòng học'));
    }

    return RefreshIndicator(
      onRefresh: provider.loadRooms,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: provider.rooms.length,
        itemBuilder: (_, i) {
          final room = provider.rooms[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.meeting_room)),
              title: Text('${room.roomCode} · ${room.roomName}'),
              subtitle: Text(
                'Sức chứa: ${room.capacity}'
                '${room.location != null && room.location!.isNotEmpty ? ' · ${room.location}' : ''}'
                ' · ${room.status ?? ''}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    onEdit(room);
                  } else if (value == 'delete') {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xóa phòng?'),
                        content: Text('Xóa ${room.roomCode}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      final success =
                          await context.read<StaffRoomProvider>().deleteRoom(
                                room.roomId,
                              );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Đã xóa phòng'
                                : (context.read<StaffRoomProvider>().error ??
                                    'Xóa thất bại'),
                          ),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeSlotsTab extends StatelessWidget {
  final void Function(TimeSlotModel slot) onEdit;

  const _TimeSlotsTab({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffTimeSlotProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.timeSlots.isEmpty) {
      return const Center(child: Text('Chưa có ca học'));
    }

    return RefreshIndicator(
      onRefresh: provider.loadTimeSlots,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: provider.timeSlots.length,
        itemBuilder: (_, i) {
          final slot = provider.timeSlots[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.schedule)),
              title: Text('${slot.slotCode} · ${slot.slotName}'),
              subtitle: Text('${slot.timeRange} · ${slot.status ?? ''}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    onEdit(slot);
                  } else if (value == 'delete') {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xóa ca học?'),
                        content: Text('Xóa ${slot.slotCode}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      final success = await context
                          .read<StaffTimeSlotProvider>()
                          .deleteTimeSlot(slot.timeSlotId);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Đã xóa ca'
                                : (context
                                        .read<StaffTimeSlotProvider>()
                                        .error ??
                                    'Xóa thất bại'),
                          ),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
