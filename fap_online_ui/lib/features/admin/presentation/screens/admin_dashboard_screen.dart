import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/admin_models.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final dashboard = provider.dashboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildHeader(context),
              if (provider.isLoading && dashboard == null)
                const SliverFillRemaining(child: _LoadingView())
              else if (provider.error != null && dashboard == null)
                SliverFillRemaining(
                  child: _ErrorView(
                    message: provider.error!,
                    onRetry: provider.load,
                  ),
                )
              else
                SliverToBoxAdapter(child: _buildStatGrid(provider, dashboard)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(
              child: Center(
                child: Container(
                  height: 48,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    AppColors.logoAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(AdminDashboardProvider provider, AdminDashboardModel? d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _FilterBar(provider: provider),
          const SizedBox(height: 12),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
                minHeight: 2,
              ),
            ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              AdminStatCard(
                label: 'Sinh viên',
                value: '${d?.totalStudents ?? 0}',
                icon: Icons.school_rounded,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF7C3AED),
              ),
              AdminStatCard(
                label: 'Giáo viên',
                value: '${d?.totalTeachers ?? 0}',
                icon: Icons.person_rounded,
                iconBg: AppColors.successLight,
                iconColor: AppColors.success,
              ),
              AdminStatCard(
                label: 'Lớp học',
                value: '${d?.totalClasses ?? 0}',
                icon: Icons.class_rounded,
                iconBg: AppColors.primaryLight.withOpacity(0.12),
                iconColor: AppColors.primaryLight,
              ),
              AdminStatCard(
                label: 'Môn học',
                value: '${d?.totalSubjects ?? 0}',
                icon: Icons.menu_book_rounded,
                iconBg: AppColors.warningLight,
                iconColor: const Color(0xFFB45309),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final AdminDashboardProvider provider;

  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterDropdown<String?>(
              label: 'Năm học',
              value: provider.selectedAcademicYear,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tất cả'),
                ),
                ...provider.academicYears.map(
                  (y) => DropdownMenuItem<String?>(
                    value: y,
                    child: Text(y),
                  ),
                ),
              ],
              onChanged: (v) => provider.setAcademicYear(v),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _FilterDropdown<String?>(
              label: 'Kỳ',
              value: provider.selectedTerm,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tất cả'),
                ),
                ...AdminDashboardProvider.terms.map(
                  (t) => DropdownMenuItem<String?>(
                    value: t,
                    child: Text(t),
                  ),
                ),
              ],
              onChanged: (v) => provider.setTerm(v),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: AppColors.error),
            const SizedBox(height: 12),
            const Text(
              'Không thể tải Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
