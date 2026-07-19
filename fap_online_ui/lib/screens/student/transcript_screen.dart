import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../services/auth_service.dart';
import '../../models/transcript_model.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  final StudentApiService _studentApiService = StudentApiService();
  final AuthService _authService = AuthService();
  late Future<TranscriptModel> _transcriptFuture;

  @override
  void initState() {
    super.initState();
    _transcriptFuture = _fetchTranscript();
  }

  Future<TranscriptModel> _fetchTranscript() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token đăng nhập. Vui lòng đăng nhập lại.');
    }
    return _studentApiService.getTranscript(token);
  }

  void _reload() {
    setState(() {
      _transcriptFuture = _fetchTranscript();
    });
  }

  bool _isPassed(String? result) {
    final value = result?.toLowerCase() ?? '';
    return value == 'passed' || value == 'pass';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điểm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<TranscriptModel>(
        future: _transcriptFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.subjects.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu bảng điểm.'));
          }

          final transcript = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 1,
            itemBuilder: (context, index) {
              final subjects = transcript.subjects;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      color: Colors.blue.shade100,
                      child: Text(
                        transcript.semesterName ?? 'Tất cả học kỳ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    ...subjects.map((sub) {
                      final isPassed = _isPassed(sub.result);
                      return ListTile(
                        title: Text('${sub.subjectCode} - ${sub.subjectName}'),
                        subtitle: Text(sub.classCode != null ? 'Lớp: ${sub.classCode}' : ''),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${sub.finalScore ?? '-'}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              sub.result ?? 'Draft',
                              style: TextStyle(
                                color: isPassed ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
