import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

/// Kimlik doğrulama ile ilgili tüm Supabase erişimini kapsar.
class AuthRepository {
  /// Supabase başlatılmış mı? (örn. `.env` yoksa `false` döner)
  bool get isConfigured {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  Session? get currentSession => SupabaseConfig.client.auth.currentSession;

  Stream<AuthState> get authStateChanges =>
      SupabaseConfig.client.auth.onAuthStateChange;

  Future<void> signOut() => SupabaseConfig.client.auth.signOut();

  /// Oturum sahibinin hesabını ve ona bağlı verileri kalıcı olarak siler,
  /// ardından oturumu kapatır (bkz. 012_hesap_silme.sql).
  Future<void> deleteAccount() async {
    await SupabaseConfig.client.rpc('delete_my_account');
    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (_) {
      // Kullanıcı artık yok; sunucu tarafı çıkış hata verebilir.
      await SupabaseConfig.client.auth.signOut(scope: SignOutScope.local);
    }
  }

  /// Oturum sahibinin `kullanicilar` satırı (rol + ad/soyad).
  /// Giriş yapılmamışsa veya satır bulunamazsa `null` döner.
  Future<Map<String, dynamic>?> _currentProfile() async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return null;
    return SupabaseConfig.client
        .from('kullanicilar')
        .select('role, ad, soyad')
        .eq('id', userId)
        .maybeSingle();
  }

  /// Oturum sahibinin rolü: `user`, `admin` veya `diyetisyen`.
  Future<String?> currentUserRole() async =>
      (await _currentProfile())?['role'] as String?;

  /// Oturum sahibi `kullanicilar.role = 'admin'` mi?
  Future<bool> isCurrentUserAdmin() async => await currentUserRole() == 'admin';

  /// Oturum sahibi diyet planı ekleyebilir mi? (diyetisyen veya admin)
  Future<bool> canManageDiets() async {
    final role = await currentUserRole();
    return role == 'diyetisyen' || role == 'admin';
  }

  /// Oturum sahibinin görünen adı ("Ad Soyad").
  Future<String?> currentUserFullName() async {
    final p = await _currentProfile();
    if (p == null) return null;
    final name = [
      p['ad'],
      p['soyad'],
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    return name.isEmpty ? null : name;
  }

  /// E-posta onayı / magic link derin bağlantılarını dinler.
  Future<void> listenDeepLinks() async {
    final appLinks = AppLinks();

    // Uygulama kapalıyken açılan link
    try {
      final uri = await appLinks.getInitialLink();
      if (uri != null) {
        await SupabaseConfig.client.auth.getSessionFromUrl(uri);
      }
    } catch (_) {}

    // Uygulama açıkken gelen link
    appLinks.uriLinkStream.listen((uri) async {
      try {
        await SupabaseConfig.client.auth.getSessionFromUrl(uri);
      } catch (_) {}
    });
  }
}
