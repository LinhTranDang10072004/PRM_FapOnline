import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/parent_models.dart';
import '../../provider/child_detail_provider.dart';
import '../../utils/display_utils.dart';

class ChildDetailScreen extends StatefulWidget {
  final int studentId;

  const ChildDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loaded) return;
      _loaded = true;
      context.read<ChildDetailProvider>().load(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChildDetailProvider>();
    final detail = provider.detail;

    if (provider.isLoading && detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Child Detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null && detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Child Detail')),
        body: _ChildDetailError(
          message: provider.error!,
          onRetry: () => context.read<ChildDetailProvider>().load(widget.studentId),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(displayText(detail?.fullName, fallback: 'Child Detail')),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Timetable'),
              Tab(text: 'Attendance'),
              Tab(text: 'Grades'),
              Tab(text: 'Transcript'),
              Tab(text: 'Fees'),
            ],
          ),
        ),
        body: Column(
          children: [
            _ChildHeader(detail: detail),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  _TabRecordList<ParentWeeklyTimetableItem>(
                    records: provider.timetable,
                    emptyTitle: 'No timetable records',
                    emptyBody: 'Timetable data will appear here when the backend returns sessions.',
                    itemBuilder: (context, item) => _TimetableCard(item: item),
                    onRefresh: () => context.read<ChildDetailProvider>().load(widget.studentId),
                  ),
                  _TabRecordList<ParentAttendanceRecord>(
                    records: provider.attendance,
                    emptyTitle: 'No attendance records',
                    emptyBody: 'Attendance data will appear here when the backend returns records.',
                    itemBuilder: (context, item) => _AttendanceCard(item: item),
                    onRefresh: () => context.read<ChildDetailProvider>().load(widget.studentId),
                  ),
                  _TabRecordList<ParentGradeRecord>(
                    records: provider.grades,
                    emptyTitle: 'No grade records',
                    emptyBody: 'Grades will appear here when the backend returns records.',
                    itemBuilder: (context, item) => _GradeCard(item: item),
                    onRefresh: () => context.read<ChildDetailProvider>().load(widget.studentId),
                  ),
                  _TabRecordList<ParentTranscriptRecord>(
                    records: provider.transcript,
                    emptyTitle: 'No transcript records',
                    emptyBody: 'Transcript data will appear here when the backend returns records.',
                    itemBuilder: (context, item) => _TranscriptCard(item: item),
                    onRefresh: () => context.read<ChildDetailProvider>().load(widget.studentId),
                  ),
                  _TabRecordList<ParentFeeRecord>(
                    records: provider.fees,
                    emptyTitle: 'No fee records',
                    emptyBody: 'Fee details will appear here when the backend returns records.',
                    itemBuilder: (context, item) => _FeeCard(item: item),
                    onRefresh: () => context.read<ChildDetailProvider>().load(widget.studentId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildHeader extends StatelessWidget {
  final ParentChildDetailData? detail;

  const _ChildHeader({required this.detail});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatarUrl = detail?.avatarUrl;
    final hasAvatar = (avatarUrl ?? '').trim().isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: scheme.primary,
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
            child: hasAvatar ? null : Icon(Icons.school_rounded, color: scheme.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText(detail?.fullName, fallback: 'Student'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('${displayText(detail?.studentCode)} • ${displayText(detail?.major)}'),
                const SizedBox(height: 4),
                Text('${displayText(detail?.academicStatus)} • ${displayText(detail?.enrollmentYear?.toString())}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabRecordList<T> extends StatelessWidget {
  final List<T> records;
  final String emptyTitle;
  final String emptyBody;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() onRefresh;

  const _TabRecordList({
    required this.records,
    required this.emptyTitle,
    required this.emptyBody,
    required this.itemBuilder,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (records.isEmpty)
            _EmptyState(title: emptyTitle, body: emptyBody)
          else
            ...records.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: itemBuilder(context, item),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimetableCard extends StatelessWidget {
  final ParentWeeklyTimetableItem item;

  const _TimetableCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayText(item.subjectCode),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('${displayText(item.scheduleDate)} • ${displayText(item.timeSlot)}'),
            const SizedBox(height: 4),
            Text('${displayText(item.roomName)} • ${displayText(item.status)}'),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final ParentAttendanceRecord item;

  const _AttendanceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = (item.status ?? '').trim().toLowerCase();
    final color = status.contains('present')
        ? Colors.green
        : status.contains('late')
            ? Colors.orange
            : status.contains('absent')
                ? Colors.red
                : Theme.of(context).colorScheme.primary;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(Icons.calendar_today, color: color),
        ),
        title: Text(displayText(item.subjectCode)),
        subtitle: Text('${displayText(item.date)} • ${displayText(item.timeSlot)}'),
        trailing: Text(
          displayText(item.status),
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final ParentGradeRecord item;

  const _GradeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${displayText(item.subjectCode)} • ${displayText(item.gradeComponent)}'),
        subtitle: Text('Weight ${displayText(item.weight?.toString())}'),
        trailing: Text(
          displayText(item.score?.toString()),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  final ParentTranscriptRecord item;

  const _TranscriptCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(displayText(item.subjectName)),
        subtitle: Text('${displayText(item.subjectCode)} • ${displayText(item.status)}'),
        trailing: Text(
          displayText(item.finalScore?.toString()),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final ParentFeeRecord item;

  const _FeeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final outstanding = (item.amount ?? 0) - (item.paidAmount ?? 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayText(item.feeType),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  formatMoney(outstanding),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Due ${formatDateLabel(item.dueDate)} • ${displayText(item.status)}'),
            const SizedBox(height: 4),
            Text('Paid ${formatMoney(item.paidAmount)} of ${formatMoney(item.amount)}'),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String body;

  const _EmptyState({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}

class _ChildDetailError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ChildDetailError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(
              'Could not load child detail',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
