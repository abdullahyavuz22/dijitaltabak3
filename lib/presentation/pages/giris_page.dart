import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/app_ui.dart';
import '../widgets/auth_layout.dart';
import '../../core/config/supabase_config.dart';
import 'kayit_page.dart';

class GirisPage extends StatefulWidget {
  const GirisPage({super.key});

  @override
  State<GirisPage> createState() => _GirisPageState();
}

class _GirisPageState extends State<GirisPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _isLoading = false;
  bool _sifreGizli = true;
  String? _hata;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _girisYap() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _hata = null;
    });
    try {
      await SupabaseConfig.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _sifreController.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _hata = _hataMesaji(e.message));
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
    if (m.contains('invalid login credentials') ||
        m.contains('invalid email or password')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (m.contains('email not confirmed')) {
      return 'E-postanız henüz onaylanmamış. Gelen kutunuzu kontrol edin.';
    }
    if (m.contains('invalid api key') ||
        m.contains('apikey') ||
        m.contains('401')) {
      return 'Sunucu bağlantı hatası. Yöneticiyle iletişime geçin.';
    }
    if (m.contains('rate limit') || m.contains('email rate limit')) {
      return 'E-posta onayı şu an gönderilemedi. Birkaç dakika bekleyip tekrar deneyin.';
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
      tagline: 'Sağlıklı yaşama hoş geldiniz',
      title: 'Giriş Yap',
      subtitle: 'Hesabınıza erişmek için bilgilerinizi girin',
      footerText: 'Hesabınız yok mu?',
      footerAction: 'Kayıt Ol',
      onFooterTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KayitPage()),
      ),
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) {
                  if (!_isLoading) _girisYap();
                },
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: PasswordToggle(
                    obscured: _sifreGizli,
                    onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Şifre boş olamaz';
                  return null;
                },
              ),
              if (_hata != null) ...[
                const SizedBox(height: AppSpacing.md),
                AlertBanner(message: _hata!),
              ],
              const SizedBox(height: AppSpacing.xl),
              LoadingButton(
                label: 'Giriş Yap',
                icon: Icons.login_rounded,
                loading: _isLoading,
                onPressed: _girisYap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
