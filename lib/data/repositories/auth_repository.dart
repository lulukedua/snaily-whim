import 'dart:io';
import 'package:snailywhim/core/services/supabase_services.dart';
import 'package:snailywhim/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = SupabaseServices.client;

  Future<void> register({
    required String email,
    required String password,
    required String nama,
  }) async {
    print('EMAIL: $email');
    print('NAMA: $nama');
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'nama': nama, 'role': 'user'},
    );
    final user = response.user;
    print('USER: ${response.user}');
    if (user == null) {
      throw Exception('Gagal membuat akun');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User tidak ditemukan');
    }
    return user;
  }
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
  Future<UserModel?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;
    final profile = await _supabase
        .from('profile')
        .select()
        .eq('id', authUser.id)
        .single();
    final user = UserModel(
      id: authUser.id,
      email: authUser.email ?? '',
      nama: profile['nama'] ?? '',
      role: profile['role'] ?? '',
      imageUrl: profile['image_url'],
      cabangId: profile['cabang_id'],
    );
    if (user.isAdmin && user.cabangId == null) {
      throw Exception('Admin harus memiliki cabang');
    }
    return user;
  }
  Future<String?> getNamaCabang(String cabangId) async {
    try {
      final response = await _supabase
          .from('cabang')
          .select('nama_cabang')
          .eq('id', cabangId)
          .single();
      return response['nama_cabang'] as String?;
    } catch (e) {
      return null;
    }
  }
  Future<void> updateProfileImage(File imageFile, String userId) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      await _supabase.storage.from('profile-image').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: false),
          );
      final imageUrl = _supabase.storage.from('profile-image').getPublicUrl(fileName);
      await _supabase
          .from('profile')
          .update({'image_url': imageUrl})
          .eq('id', userId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}