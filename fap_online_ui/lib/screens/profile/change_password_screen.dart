import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _obsCurrent = true;
  bool _obsNew = true;
  bool _obsConfirm = true;

  final _newPassController = TextEditingController();
  String _newPass = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu', style: AppTextStyles.subtitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  child: const Icon(Icons.lock_rounded, size: 40, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                obscureText: _obsCurrent,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obsCurrent ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obsCurrent = !_obsCurrent),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassController,
                obscureText: _obsNew,
                onChanged: (val) => setState(() => _newPass = val),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock_open_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obsNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obsNew = !_obsNew),
                  ),
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                  if (val.length < 8) return 'Tối thiểu 8 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: _obsConfirm,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obsConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obsConfirm = !_obsConfirm),
                  ),
                ),
                validator: (val) {
                  if (val != _newPassController.text) return 'Mật khẩu không khớp';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHint('Tối thiểu 8 ký tự', _newPass.length >= 8),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đổi mật khẩu thành công')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Đổi mật khẩu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHint(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? AppColors.success : AppColors.textHint,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isMet ? AppColors.success : AppColors.textHint,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
