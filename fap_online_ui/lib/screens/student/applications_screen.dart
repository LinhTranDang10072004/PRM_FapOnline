import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/application_model.dart';
import '../../services/application_api_service.dart';
import '../../services/auth_service.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final ApplicationApiService _apiService = ApplicationApiService();
  final AuthService _authService = AuthService();
  late Future<List<ApplicationModel>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _fetchApplications();
  }

  Future<List<ApplicationModel>> _fetchApplications() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Không tìm thấy token');
    return _apiService.getMyApplications(token);
  }

  Future<void> _showAddApplicationSheet() async {
    final token = await _authService.getToken();
    if (token == null || !mounted) return;

    List<ApplicationTypeModel> types;
    try {
      types = await _apiService.getTypes(token);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải loại đơn: $e')),
      );
      return;
    }
    if (types.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có loại đơn. Restart backend để seed.')),
      );
      return;
    }
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    int selectedTypeId = types.first.applicationTypeId;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Nộp đơn mới',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedTypeId,
                        decoration: const InputDecoration(
                          labelText: 'Loại đơn *',
                          border: OutlineInputBorder(),
                        ),
                        items: types
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.applicationTypeId,
                                child: Text(t.typeName),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setSheetState(() => selectedTypeId = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contentCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung (lý do) *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: ctx,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (date != null) {
                                  setSheetState(() => startDate = date);
                                }
                              },
                              child: Text(
                                startDate == null
                                    ? 'Từ ngày'
                                    : DateFormat('yyyy-MM-dd').format(startDate!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: ctx,
                                  initialDate: startDate ?? DateTime.now(),
                                  firstDate: startDate ?? DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (date != null) {
                                  setSheetState(() => endDate = date);
                                }
                              },
                              child: Text(
                                endDate == null
                                    ? 'Đến ngày'
                                    : DateFormat('yyyy-MM-dd').format(endDate!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final err = await _apiService.submitApplication(
                            token,
                            applicationTypeId: selectedTypeId,
                            title: titleCtrl.text.trim(),
                            content: contentCtrl.text.trim(),
                            startDate: startDate != null
                                ? DateFormat('yyyy-MM-dd').format(startDate!)
                                : null,
                            endDate: endDate != null
                                ? DateFormat('yyyy-MM-dd').format(endDate!)
                                : null,
                          );
                          if (!ctx.mounted) return;
                          if (err == null) {
                            Navigator.pop(ctx, true);
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(err)),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Gửi đơn'),
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

    titleCtrl.dispose();
    contentCtrl.dispose();

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nộp đơn thành công')),
      );
      setState(() => _applicationsFuture = _fetchApplications());
    }
  }

  Color _statusBg(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'approved':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Đơn từ của tôi'),
      ),
      body: FutureBuilder<List<ApplicationModel>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lỗi: ${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(
                        () => _applicationsFuture = _fetchApplications(),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bạn chưa gửi đơn nào.'));
          }

          final apps = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    app.title ?? 'Không có tiêu đề',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nội dung: ${app.content ?? ''}'),
                      if (app.startDate != null && app.endDate != null)
                        Text('Từ: ${app.startDate} - Đến: ${app.endDate}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(app.status ?? 'Unknown'),
                    backgroundColor: _statusBg(app.status),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddApplicationSheet,
        tooltip: 'Nộp đơn mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}
