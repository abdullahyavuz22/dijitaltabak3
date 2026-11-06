import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/app_ui.dart';
import '../widgets/auth_layout.dart';
import '../../core/config/supabase_config.dart';

class KayitPage extends StatefulWidget {
  const KayitPage({super.key});

  @override
  State<KayitPage> createState() => _KayitPageState();
}

class _KayitPageState extends State<KayitPage> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _isLoading = false;
  bool _sifreGizli = true;
  String? _hata;

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _kayitOl() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _hata = null;
    });
    try {
      final res = await SupabaseConfig.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _sifreController.text,
      );
      if (!mounted) return;

      if (res.user != null) {
        await SupabaseConfig.client.from('kullanicilar').upsert({
          'id': res.user!.id,
          'ad': _adController.text.trim(),
          'soyad': _soyadController.text.trim(),
          'email': _emailController.text.trim(),
        });
      }
      if (!mounted) return;

      if (res.user != null && res.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.mark_email_read, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kayıt başarılı! E-postanıza gelen onay linkine tıklayın.',
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        if (mounted) Navigator.pop(context);
      }
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('rate limit') || m.contains('email rate limit')) {
        // Email gönderilemedi ama kullanıcı oluşturulmuş olabilir — direkt giriş dene
        try {
          await SupabaseConfig.client.auth.signInWithPassword(
            email: _emailController.text.trim(),
            password: _sifreController.text,
          );
          return; // Giriş başarılı, AuthGate yönlendirir
        } catch (_) {}
        if (mounted) {
          setState(
            () => _hata =
                'Hesabınız oluşturuldu ancak onay e-postası gönderilemedi. Birkaç dakika bekleyip giriş yapmayı deneyin.',
          );
        }
      } else {
        if (mounted) setState(() => _hata = _hataMesaji(e.message));
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _hata = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _hataMesaji(String message) {
    final m = message.toLowerCase();
    if (m.contains('user already registered') ||
        m.contains('already been registered')) {
      return 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
    }
    if (m.contains('password should be') ||
        m.contains('password is too short')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    if (m.contains('invalid api key') ||
        m.contains('apikey') ||
        m.contains('401')) {
      return 'Sunucu bağlantı hatası. Yöneticiyle iletişime geçin.';
    }
    if (m.contains('network') ||
        m.contains('connection') ||
        m.contains('timeout')) {
      return 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
    }
    return message;
  }

  bool _emailGecerli(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      tagline: 'Yeni hesabınızı oluşturun',
      title: 'Kayıt Ol',
      subtitle: 'Birkaç bilgiyle hemen başlayın',
      footerText: 'Zaten hesabınız var mı?',
      footerAction: 'Giriş Yap',
      onFooterTap: () => Navigator.pop(context),
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Ad'),
                        TextFormField(
                          controller: _adController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.givenName],
                          decoration: const InputDecoration(hintText: 'Adınız'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ad boş olamaz'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Soyad'),
                        TextFormField(
                          controller: _soyadController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
                          decoration: const InputDecoration(
                            hintText: 'Soyadınız',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Soyad boş olamaz'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const FieldLabel('E-posta'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: 'ornek@email.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'E-posta boş olamaz';
                  }
                  if (!_emailGecerli(v)) return 'Geçerli bir e-posta girin';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const FieldLabel('Şifre'),
              TextFormField(
                controller: _sifreController,
                obscureText: _sifreGizli,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) {
                  if (!_isLoading) _kayitOl();
                },
                decoration: InputDecoration(
                  hintText: 'En az 6 karakter',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: PasswordToggle(
                    obscured: _sifreGizli,
                    onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Şifre boş olamaz';
                  if (v.length < 6) return 'En az 6 karakter olmalıdır';
                  return null;
                },
              ),
              if (_hata != null) ...[
                const SizedBox(height: AppSpacing.md),
                AlertBanner(message: _hata!),
              ],
              const SizedBox(height: AppSpacing.xl),
              LoadingButton(
                label: 'Hesap Oluştur',
                icon: Icons.person_add_alt_1_rounded,
                loading: _isLoading,
                onPressed: _kayitOl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
