import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../models/parent_models.dart';
import '../../provider/parent_dashboard_provider.dart';
import '../../utils/display_utils.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentDashboardProvider>();
    final dashboard = provider.dashboard;

    if (provider.isLoading && dashboard == null) {
      return const _DashboardLoading();
    }

    if (provider.error != null && dashboard == null) {
      return _DashboardError(
        message: provider.error!,
        onRetry: provider.load,
      );
    }

    final displayName = displayText(provider.displayName, fallback: 'phụ huynh');

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _GreetingCard(
            name: displayName,
            unreadCount: dashboard?.unreadNotificationCount ?? 0,
          ),
          const SizedBox(height: 20),
          _SectionTitle(
            title: 'Children',
            trailing: dashboard?.children.isNotEmpty == true
                ? Text('${dashboard!.children.length} students')
                : null,
          ),
          const SizedBox(height: 12),
          if (dashboard?.children.isEmpty ?? true)
            const _EmptyBlock(
              title: 'No linked children',
              body: 'Children will appear here when the backend returns linked student records.',
            )
          else
            ...dashboard!.children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChildCard(
                  child: child,
                  attendanceSummary: provider.attendanceByChild[child.studentId] ?? const AttendanceSummary.empty(),
                  onTap: child.studentId == null
                      ? null
                      : () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.childDetail,
                            arguments: child.studentId,
                          );
                        },
                ),
              ),
            ),
          const SizedBox(height: 12),
          _SectionTitle(title: 'Today\'s Schedule'),
          const SizedBox(height: 12),
          if (dashboard?.todaySchedules.isEmpty ?? true)
            const _EmptyBlock(
              title: 'No schedule today',
              body: 'Today\'s schedule will appear here when the backend returns sessions.',
            )
          else
            ...dashboard!.todaySchedules.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ScheduleCard(item: item),
              ),
            ),
          const SizedBox(height: 12),
          _SectionTitle(title: 'Attendance Summary'),
          const SizedBox(height: 12),
          _AttendanceSummaryCard(summary: provider.attendanceSummary),
          const SizedBox(height: 12),
          _SectionTitle(title: 'Outstanding Fees'),
          const SizedBox(height: 12),
          if (dashboard?.unpaidFees.isEmpty ?? true)
            const _EmptyBlock(
              title: 'No outstanding fees',
              body: 'Fee records will show here when the backend returns unpaid items.',
            )
          else
            ...dashboard!.unpaidFees.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FeeCard(item: item),
              ),
            ),
          const SizedBox(height: 12),
          _SectionTitle(title: 'Unread Notifications'),
          const SizedBox(height: 12),
          _UnreadCard(count: dashboard?.unreadNotificationCount ?? 0),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String name;
  final int unreadCount;

  const _GreetingCard({
    required this.name,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, $name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Theo dõi lớp học, điểm số và thông báo của con ở một nơi.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.88),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricPill(
                label: 'Unread',
                value: unreadCount.toString(),
                foreground: scheme.onPrimary,
                background: scheme.onPrimary.withValues(alpha: 0.14),
              ),
              const SizedBox(width: 10),
              _MetricPill(
                label: 'Home',
                value: 'Parent',
                foreground: scheme.onPrimary,
                background: scheme.onPrimary.withValues(alpha: 0.14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color foreground;
  final Color background;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: foreground.withValues(alpha: 0.82),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (trailing != null) DefaultTextStyle.merge(style: Theme.of(context).textTheme.labelMedium, child: trailing!),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ParentChildSummary child;
  final AttendanceSummary attendanceSummary;
  final VoidCallback? onTap;

  const _ChildCard({
    required this.child,
    required this.attendanceSummary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  (child.fullName ?? '?').trim().isNotEmpty ? child.fullName!.trim()[0].toUpperCase() : '?',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayText(child.fullName),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('${displayText(child.studentCode)} • ${displayText(child.major)}'),
                    const SizedBox(height: 6),
                    Text(
                      displayText(child.academicStatus),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${attendanceSummary.present}/${attendanceSummary.total}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Attendance',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ParentTodaySchedule item;

  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayText(item.subjectCode),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text('${displayText(item.timeSlot)} • ${displayText(item.roomName)}'),
                  if ((item.studentName ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(displayText(item.studentName)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  final AttendanceSummary summary;

  const _AttendanceSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(label: 'Total', value: summary.total.toString()),
                ),
                Expanded(
                  child: _SummaryTile(label: 'Present', value: summary.present.toString()),
                ),
                Expanded(
                  child: _SummaryTile(label: 'Late', value: summary.late.toString()),
                ),
                Expanded(
                  child: _SummaryTile(label: 'Absent', value: summary.absent.toString()),
                ),
              ],
            ),
            if (summary.other > 0) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Other statuses: ${summary.other}'),
              ),
            ],
            if (summary.total == 0) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No attendance records returned by the backend yet.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeeCard extends StatelessWidget {
  final ParentUnpaidFee item;

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
            Text('${displayText(item.studentName)} • Due ${formatDateLabel(item.dueDate)}'),
            const SizedBox(height: 4),
            Text('Paid ${formatMoney(item.paidAmount)} of ${formatMoney(item.amount)}'),
          ],
        ),
      ),
    );
  }
}

class _UnreadCard extends StatelessWidget {
  final int count;

  const _UnreadCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                count == 0
                    ? 'You have no unread notifications.'
                    : 'You have $count unread notification${count == 1 ? '' : 's'}.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String title;
  final String body;

  const _EmptyBlock({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SkeletonCard(height: 150),
        const SizedBox(height: 16),
        _SkeletonCard(height: 110),
        const SizedBox(height: 12),
        _SkeletonCard(height: 110),
        const SizedBox(height: 12),
        _SkeletonCard(height: 180),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;

  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _DashboardError({
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
              'Could not load dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
