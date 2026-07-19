import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../providers/staff_application_provider.dart';
import '../../data/models/staff_models.dart';
import '../widgets/staff_widgets.dart';
import 'staff_application_detail_screen.dart';

class StaffApplicationsScreen extends StatefulWidget {
  const StaffApplicationsScreen({super.key});

  @override
  State<StaffApplicationsScreen> createState() =>
      _StaffApplicationsScreenState();
}

class _StaffApplicationsScreenState extends State<StaffApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    (AppFilter.pending, 'Chờ xử lý'),
    (AppFilter.approved, 'Đã duyệt'),
    (AppFilter.rejected, 'Từ chối'),
    (AppFilter.all, 'Tất cả'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      context
          .read<StaffApplicationProvider>()
          .setFilter(_tabs[_tabController.index].$1);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffApplicationProvider>().loadApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffApplicationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Text('Đơn từ', style: TextStyle(fontWeight: FontWeight.w700)),
            if (provider.pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${provider.pendingCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: provider.refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : provider.applications.isEmpty
              ? _EmptyView(
                  filter: _tabs[_tabController.index].$2)
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: provider.applications.length,
                    itemBuilder: (_, i) => _ApplicationCard(
                      app: provider.applications[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StaffApplicationDetailScreen(
                            application: provider.applications[i],
                          ),
                        ),
                      ).then((_) => provider.refresh()),
                    ),
                  ),
                ),
    );
  }
}

// ─── Application Card ─────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel app;
  final VoidCallback onTap;

  const _ApplicationCard({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPending = app.status == 'Pending';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPending
              ? Border.all(color: AppColors.warning.withOpacity(0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  child: Text(
                    (app.studentName?.isNotEmpty == true)
                        ? app.studentName![0].toUpperCase()
                        : 'SV',
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.studentName ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        app.studentCode ?? '—',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (app.status != null) StatusBadge(status: app.status!),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    app.applicationTypeName ?? 'Đơn từ',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    app.title ?? app.content ?? '—',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 12, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  app.displayCreatedAt,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint),
                ),
                const Spacer(),
                if (isPending)
                  const Text(
                    'Nhấn để xem & xử lý →',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String filter;

  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 60, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            'Không có đơn "$filter"',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
