import 'package:flutter/material.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/widgets/custom_button.dart';
import 'package:snailywhim/core/widgets/custom_text_field.dart';

class AuthForm extends StatelessWidget {
  final bool isRegister;
  final bool showTitle;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? namaController;
  final TextEditingController? confirmPasswordController;
  final VoidCallback onSubmit;
  final VoidCallback? onGoogleLogin;
  final VoidCallback onSwitchMode;
  final VoidCallback? onForgotPassword;
  final bool loading;

  const AuthForm({
    super.key,
    required this.isRegister,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    this.namaController,
    this.confirmPasswordController,
    required this.onSubmit,
    required this.onSwitchMode,
    this.onGoogleLogin,
    this.onForgotPassword,
    this.loading = false,
    this.showTitle = true,
  });

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 32, right: 32, bottom: 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: isRegister ? 80 : 50),
              if (showTitle) ...[
                Text(
                  isRegister ? 'Register' : 'Login',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primTextColor
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isRegister ? 'Buat Akun Baru' : 'Selamat Datang Kembali',
                  style: TextStyle(fontSize: 15, color: AppColors.primTextColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 30),
              ] else
                const SizedBox(height: 10),

              if (isRegister) ...[
                CustomTextField(
                  controller: namaController!,
                  label: 'Nama',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Nama wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              CustomTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email wajib diisi';
                  if (!isValidEmail(value)) return 'Format email salah';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password wajib diisi';
                  if (value.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),

              if (isRegister) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: confirmPasswordController!,
                  label: 'Konfirmasi Password',
                  icon: Icons.lock_reset,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                    if (value != passwordController.text) return 'Password tidak sama';
                    return null;
                  },
                ),
              ],

              if (!isRegister)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onForgotPassword,
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(color: Color(0xFF6B8F5E)),
                    ),
                  ),
                ),

              SizedBox(height: isRegister ? 30 : 10),

              CustomButton(
                text: isRegister ? 'Register' : 'Login',
                isLoading: loading,
                onPressed: loading ? null : () {
                  if (formKey.currentState!.validate()) onSubmit();
                },
              ),

              if (!isRegister) ...[
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.primTextColor)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ATAU', style: TextStyle(fontSize: 12, color: AppColors.primTextColor, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: AppColors.primTextColor)),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Masuk dengan Google',
                  icon: Icons.login,
                  onPressed: onGoogleLogin ?? () {},
                ),
              ],

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isRegister ? 'Sudah punya akun? ' : 'Belum punya akun? ',
                    style: TextStyle(color: AppColors.primTextColor),
                  ),
                  GestureDetector(
                    onTap: onSwitchMode,
                    child: Text(
                      isRegister ? 'Login' : 'Register',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primTextColor,
                      ),
                    ),
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