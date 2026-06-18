import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/auth_form.dart';
import 'package:snailywhim/logic/bloc/auth/auth_bloc.dart';
import 'package:snailywhim/logic/bloc/auth/auth_event.dart';
import 'package:snailywhim/logic/bloc/auth/auth_state.dart';
import 'package:snailywhim/screen/auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final List<BugPosition> bugs;

  @override
  void initState() {
    super.initState();

    final random = Random();

    bugs = List.generate(
      12,
      (_) => BugPosition(
        left: random.nextDouble() * 360,
        top: random.nextDouble() * 350,
        size: 15 + random.nextDouble() * 20,
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenHeight * 0.65;

    return Scaffold(
      backgroundColor: AppColors.primColor,
      body: Stack(
        children: [
          ...bugs.map(
            (bug) => Positioned(
              left: bug.left,
              top: bug.top,
              child: Opacity(
                opacity: 0.55,
                child: Image.asset('assets/img/kumbang.png', width: bug.size),
              ),
            ),
          ),
          Positioned(
            right: -250,
            top: -0,
            child: Image.asset('assets/img/flower.png', width: 500),
          ),
          Positioned(
            left: 40,
            top: 50,
            child: Image.asset('assets/img/logo.png', width: 60),
          ),
          Positioned(
            left: 32,
            top: screenHeight * 0.12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primTextColor,
                  ),
                ),
                Text(
                  'Buat akun baru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primTextColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: cardHeight,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(screenWidth, 120),
                ),
              ),
            ),
          ),
          SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  AppSnackbar.show(
                    context,
                    title: 'Gagal Registrasi',
                    message: state.message,
                    type: SnackType.error,
                  );
                }

                if (state is Unauthenticated) {
                  AppSnackbar.show(
                    context,
                    title: 'Berhasil',
                    message: 'Registrasi berhasil, silakan login',
                    type: SnackType.success,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                }
              },
              builder: (context, state) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: cardHeight,
                    child: AuthForm(
                      isRegister: true,
                      formKey: _formKey,
                      showTitle: false,
                      namaController: _namaController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      onSubmit: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            RegisterRequested(
                              _namaController.text.trim(),
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ),
                          );
                        }
                      },
                      onSwitchMode: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
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

class BugPosition {
  final double left;
  final double top;
  final double size;

  BugPosition({required this.left, required this.top, required this.size});
}
