import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snailywhim/core/helper/image_picker_helper.dart';
import 'package:snailywhim/core/services/notification_services.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/image_picker.dart';
import 'package:snailywhim/core/widgets/menu_tile.dart';
import 'package:snailywhim/data/repositories/auth_repository.dart';
import 'package:snailywhim/logic/bloc/auth/auth_bloc.dart';
import 'package:snailywhim/logic/bloc/auth/auth_event.dart';
import 'package:snailywhim/logic/bloc/auth/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploading = false;

  Future<void> _handleImagePick(String userId) async {
    try {
      print("USER ID : $userId");

      final file = await ImagePickerHelper.pickImage(context);

      if (file == null) return;

      print("FILE : ${file.path}");

      setState(() {
        _isUploading = true;
      });

      await AuthRepository().updateProfileImage(file, userId);

      print("UPLOAD SUCCESS");

      if (mounted) {
        context.read<AuthBloc>().add(AppStarted());
      }
    } catch (e, stackTrace) {
      print("ERROR UPLOAD");
      print(e);
      print(stackTrace);

      if (mounted) {
        AppSnackbar.show(
          context,
          title: 'Gagal',
          message: e.toString(),
          type: SnackType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showNotDevelopedMessage() {
    AppSnackbar.show(
      context,
      title: 'Informasi',
      message: 'Mohon maaf fitur ini tidak dikembangkan',
      type: SnackType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.bgBtmColor,
          elevation: 0,
          title: const Text(
            "Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primTextColor,
              fontSize: 24,
            ),
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              final user = state.user;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomImagePicker(
                            isCircle: true,
                            size: 84,
                            imageUrl: user.imageUrl,
                            isLoading: _isUploading,
                            onTap: () => _handleImagePick(user.id),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.nama,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.isAdmin ? "Administrator" : "Customer",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (user.isAdmin && user.cabangId != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.circle,
                                  size: 4,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  LucideIcons.store,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                FutureBuilder<String?>(
                                  future: AuthRepository().getNamaCabang(
                                    user.cabangId!,
                                  ),
                                  builder: (context, snapshot) {
                                    final namaCabang =
                                        snapshot.data ?? 'Memuat...';
                                    return Text(
                                      namaCabang,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                          // const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    ProfileMenuTile(
                      icon: LucideIcons.languages,
                      title: "Language",
                      onTap: _showNotDevelopedMessage,
                    ),
                    ProfileMenuTile(
                      icon: LucideIcons.circleDollarSign,
                      title: "Currencies",
                      onTap: _showNotDevelopedMessage,
                    ),
                    ProfileMenuTile(
                      icon: LucideIcons.palette,
                      title: "Appearance",
                      onTap: _showNotDevelopedMessage,
                    ),
                    const SizedBox(height: 12),
                    ProfileMenuTile(
                      icon: LucideIcons.shieldCheck,
                      title: "Application Security",
                      onTap: _showNotDevelopedMessage,
                    ),
                    ProfileMenuTile(
                      icon: LucideIcons.smartphone,
                      title: "Manage Devices",
                      onTap: _showNotDevelopedMessage,
                    ),
                    ProfileMenuTile(
                      icon: LucideIcons.lockKeyhole,
                      title: "Change Password",
                      onTap: _showNotDevelopedMessage,
                    ),

                    const SizedBox(height: 24),

                    ProfileMenuTile(
                      icon: LucideIcons.logOut,
                      title: "Logout",
                      textColor: Colors.redAccent,
                      iconColor: Colors.redAccent,
                      hideArrow: true,
                      onTap: () {
                        NotificationService().stopListening();
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
