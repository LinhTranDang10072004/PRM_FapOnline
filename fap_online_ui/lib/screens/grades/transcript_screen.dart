import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/parent_child_provider.dart';
import '../../provider/transcript_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/child_selector.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  int? _selectedChildId;
  int? _selectedSemesterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childProvider = context.read<ParentChildProvider>();
      if (childProvider.children.isNotEmpty && _selectedChildId == null) {
        _selectedChildId = childProvider.children.first.studentId;
        _fetchTranscript();
      }
    });
  }

  void _fetchTranscript() {
    if (_selectedChildId == null) return;
    
    final provider = context.read<TranscriptProvider>();
    if (_selectedSemesterId != null) {
      provider.fetchSemesterTranscript(_selectedChildId!, _selectedSemesterId!);
    } else {
      provider.fetchStudentTranscript(_selectedChildId!);
      provider.fetchAverageScore(_selectedChildId!);
    }
  }

  void _onChildSelected(int childId) {
    setState(() => _selectedChildId = childId);
    _fetchTranscript();
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ParentChildProvider>();
    final transcriptProvider = context.watch<TranscriptProvider>();

    if (childProvider.children.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Bảng điểm', style: AppTextStyles.h2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Chưa có dữ liệu học sinh'),
        ),
      );
    }

    _selectedChildId ??= childProvider.children.first.studentId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bảng điểm', style: AppTextStyles.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (childProvider.children.length > 1)
            ChildSelector(
              children: childProvider.children
                  .map((c) => ChildData(studentId: c.studentId, name: c.fullName))
                  .toList(),
              selectedId: _selectedChildId!,
              onSelected: _onChildSelected,
            ),
          
          const SizedBox(height: 12),
          
          // Semester Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Học kỳ:', style: AppTextStyles.body),
                  DropdownButton<int?>(
                    value: _selectedSemesterId,
                    onChanged: (value) {
                      setState(() => _selectedSemesterId = value);
                      _fetchTranscript();
                    },
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      const DropdownMenuItem(
                        value: 1,
                        child: Text('Học kỳ 1'),
                      ),
                      const DropdownMenuItem(
                        value: 2,
                        child: Text('Học kỳ 2'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Average Score
          if (transcriptProvider.averageScore != null && _selectedSemesterId == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Điểm trung bình:', style: AppTextStyles.body),
                    Text(
                      transcriptProvider.averageScore!.toStringAsFixed(2),
                      style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 12),

          // Transcript List
          if (transcriptProvider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (transcriptProvider.error != null)
            Expanded(
              child: Center(
                child: Text(
                  transcriptProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            )
          else if (transcriptProvider.transcriptList.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Không có dữ liệu bảng điểm',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: transcriptProvider.transcriptList.length,
                itemBuilder: (context, index) {
                  final transcript = transcriptProvider.transcriptList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.menu_book, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transcript.subjectName.isNotEmpty
                                      ? transcript.subjectName
                                      : transcript.subjectCode,
                                  style: AppTextStyles.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  transcript.subjectCode,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                transcript.finalScore != null
                                    ? transcript.finalScore!.toStringAsFixed(2)
                                    : '-',
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: transcript.status == 'PUBLISHED'
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  transcript.status,
                                  style: AppTextStyles.caption.copyWith(
                                    color: transcript.status == 'PUBLISHED'
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
