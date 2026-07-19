import 'package:flutter/material.dart';

import '../../config/app_routes.dart';
import '../../config/campus_config.dart';
import '../../theme/app_colors.dart';
import '../../utils/preferences.dart';

/// Bước 1: chọn campus trước khi login (chỉ Frontend).
class CampusSelectScreen extends StatefulWidget {
  const CampusSelectScreen({super.key});

  @override
  State<CampusSelectScreen> createState() => _CampusSelectScreenState();
}

class _CampusSelectScreenState extends State<CampusSelectScreen> {
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _loadSavedCampus();
  }

  Future<void> _loadSavedCampus() async {
    final saved = await PreferencesHelper.getCampusCode();
    if (!mounted) return;
    setState(() => _selectedCode = saved);
  }

  Future<void> _continue() async {
    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn campus')),
      );
      return;
    }

    await PreferencesHelper.saveCampusCode(_selectedCode!);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Image.asset(AppColors.logoAsset, height: 72),
              ),
              const SizedBox(height: 16),
              Text(
                'Chọn Campus',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Vui lòng chọn cơ sở trước khi đăng nhập',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: CampusConfig.campuses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final campus = CampusConfig.campuses[index];
                    final selected = campus.code == _selectedCode;

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedCode = campus.code),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: selected
                                    ? AppColors.primary
                                    : AppColors.accentLight,
                                child: Text(
                                  campus.code,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      campus.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      campus.city,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textHint,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tiếp tục đăng nhập'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
