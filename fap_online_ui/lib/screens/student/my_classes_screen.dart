import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/student_api_service.dart';
import 'timetable_screen.dart';
import 'mark_detail_screen.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  final _authService = AuthService();
  final _studentApi = StudentApiService();

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }
    return _studentApi.getMyClasses(token);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp của tôi'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Lỗi: ${snapshot.error}'),
              ),
            );
          }

          final classes = snapshot.data ?? [];
          if (classes.isEmpty) {
            return const Center(child: Text('Bạn chưa được ghi danh lớp nào'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: classes.length,
              itemBuilder: (_, i) {
                final item = classes[i];
                final classId = item['classId'] as int?;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.class_)),
                    title: Text(
                      '${item['classCode'] ?? ''} · ${item['subjectCode'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${item['className'] ?? ''}\n'
                      '${item['subjectName'] ?? ''} · ${item['status'] ?? ''}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: const Text('Xem thời khóa biểu'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TimetableScreen(),
                                    ),
                                  );
                                },
                              ),
                              if (classId != null)
                                ListTile(
                                  leading: const Icon(Icons.grade),
                                  title: const Text('Xem điểm môn này'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MarkDetailScreen(
                                          classId: classId,
                                          subjectTitle:
                                              '${item['subjectCode'] ?? ''} - ${item['subjectName'] ?? ''}',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
