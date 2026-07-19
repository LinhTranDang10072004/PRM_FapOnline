import 'package:flutter/material.dart';
import '../../services/application_api_service.dart';
import '../../services/auth_service.dart';
import '../../models/application_model.dart';
import 'package:intl/intl.dart';

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

  void _showAddApplicationDialog() {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    DateTime? _startDate;
    DateTime? _endDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nộp đơn mới'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Tiêu đề'),
                        validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                      ),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(labelText: 'Nội dung (lý do)'),
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setDialogState(() => _startDate = date);
                                }
                              },
                              child: Text(_startDate == null ? 'Từ ngày' : DateFormat('yyyy-MM-dd').format(_startDate!)),
                            ),
                          ),
                          const Text(' - '),
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: _startDate ?? DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setDialogState(() => _endDate = date);
                                }
                              },
                              child: Text(_endDate == null ? 'Đến ngày' : DateFormat('yyyy-MM-dd').format(_endDate!)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final token = await _authService.getToken();
                      if (token == null) return;

                      final newApp = ApplicationModel(
                        title: _titleController.text,
                        content: _contentController.text,
                        status: 'Pending',
                        startDate: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null,
                        endDate: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
                      );

                      final success = await _apiService.submitApplication(token, newApp);
                      Navigator.pop(ctx);

                      if (success) {
                        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Nộp đơn thành công')));
                        setState(() {
                          _applicationsFuture = _fetchApplications();
                        });
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Nộp đơn thất bại')));
                      }
                    }
                  },
                  child: const Text('Gửi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn từ của tôi'),
      ),
      body: FutureBuilder<List<ApplicationModel>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bạn chưa gửi đơn nào.'));
          }

          final apps = snapshot.data!;
          return ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(app.title ?? 'Không có tiêu đề', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    backgroundColor: app.status == 'Pending' ? Colors.orange.shade100 : Colors.green.shade100,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddApplicationDialog,
        child: const Icon(Icons.add),
        tooltip: 'Nộp đơn mới',
      ),
    );
  }
}
