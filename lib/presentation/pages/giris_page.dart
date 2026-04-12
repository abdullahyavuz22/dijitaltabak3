import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';

class GirisPage extends StatefulWidget {
  const GirisPage({super.key});

  @override
  State<GirisPage> createState() => _GirisPageState();
}

class _GirisPageState extends State<GirisPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  bool _isLoading = false;
  bool _sifreGizli = true;
  bool _kayitModu = false;
  String? _hata;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    _adController.dispose();
    _soyadController.dispose();
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
    } catch (e) {
      if (mounted) {
        setState(() => _hata = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

      // Kullanıcı profil verisini profiller tablosuna kaydet
      if (res.user != null) {
        await SupabaseConfig.client.from('profiller').upsert({
          'user_id': res.user!.id,
          'ad': _adController.text.trim(),
          'soyad': _soyadController.text.trim(),
          'email': _emailController.text.trim(),
        });
      }

      if (!mounted) return;

      if (res.user != null && res.session == null) {
        // E-posta onayı gerekiyor
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.mark_email_read, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Kayıt başarılı! E-postanıza gelen onay linkine tıklayın.'),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _kayitModu = false);
      }
      // Eğer session döndüyse AuthGate zaten MainPage'e yönlendirir
    } on AuthException catch (e) {
      if (mounted) setState(() => _hata = _hataMesaji(e.message));
    } catch (e) {
      if (mounted) {
        setState(() => _hata = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _hataMesaji(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') || m.contains('invalid email or password')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (m.contains('email not confirmed')) {
      return 'E-postanız henüz onaylanmamış. Gelen kutunuzu kontrol edin.';
    }
    if (m.contains('user already registered') || m.contains('already been registered')) {
      return 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
    }
    if (m.contains('password should be') || m.contains('password is too short')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    if (m.contains('invalid api key') || m.contains('apikey') || m.contains('401')) {
      return 'Sunucu bağlantı hatası. Yöneticiyle iletişime geçin.';
    }
    if (m.contains('rate limit') || m.contains('too many requests') || m.contains('email rate limit')) {
      return 'Çok fazla deneme yapıldı. Lütfen birkaç dakika bekleyip tekrar deneyin.';
    }
    if (m.contains('network') || m.contains('connection') || m.contains('timeout')) {
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan gradyanı
          Container(
            height: size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF68BE6D),
                  Color(0xFF81C784),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.6,
              color: const Color(0xFFF7F8FA),
            ),
          ),

          // Dekoratif daireler
          Positioned(
            top: -50,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // İçerik
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // Logo
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.restaurant,
                        color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Dijital Tabağım',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _kayitModu
                        ? 'Yeni hesabınızı oluşturun'
                        : 'Sağlıklı yaşama hoş geldiniz',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Kart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _kayitModu ? 'Kayıt Ol' : 'Giriş Yap',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _kayitModu
                                    ? 'Bilgilerinizi girin'
                                    : 'Hesabınıza erişin',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black45),
                              ),
                              const SizedBox(height: 28),

                              // Ad & Soyad (sadece kayıt modunda)
                              if (_kayitModu) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Ad'),
                                          const SizedBox(height: 8),
                                          _buildTextField(
                                            controller: _adController,
                                            hint: 'Adınız',
                                            icon: Icons.person_outline,
                                            validator: (v) {
                                              if (v == null || v.trim().isEmpty) {
                                                return 'Ad boş olamaz';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Soyad'),
                                          const SizedBox(height: 8),
                                          _buildTextField(
                                            controller: _soyadController,
                                            hint: 'Soyadınız',
                                            icon: Icons.person_outline,
                                            validator: (v) {
                                              if (v == null || v.trim().isEmpty) {
                                                return 'Soyad boş olamaz';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],

                              // E-posta
                              _buildLabel('E-posta'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _emailController,
                                hint: 'ornek@email.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'E-posta boş olamaz';
                                  }
                                  if (!_emailGecerli(v)) {
                                    return 'Geçerli bir e-posta girin (ornek@domain.com)';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Şifre
                              _buildLabel('Şifre'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _sifreController,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _sifreGizli,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _sifreGizli
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _sifreGizli = !_sifreGizli),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Şifre boş olamaz';
                                  }
                                  if (_kayitModu && v.length < 6) {
                                    return 'En az 6 karakter olmalıdır';
                                  }
                                  return null;
                                },
                              ),

                              // Hata
                              if (_hata != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F0),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFFFCDD2)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 1),
                                        child: Icon(Icons.error_outline,
                                            color: Color(0xFFE57373),
                                            size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _hata!,
                                          style: const TextStyle(
                                            color: Color(0xFFC62828),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Ana Buton
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : (_kayitModu ? _kayitOl : _girisYap),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppColors.primary.withValues(alpha: 0.6),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          _kayitModu
                                              ? 'Hesap Oluştur'
                                              : 'Giriş Yap',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Geçiş linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _kayitModu
                            ? 'Zaten hesabınız var mı?  '
                            : 'Hesabınız yok mu?  ',
                        style:
                            const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _kayitModu = !_kayitModu;
                          _hata = null;
                        }),
                        child: Text(
                          _kayitModu ? 'Giriş Yap' : 'Kayıt Ol',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(icon, color: Colors.grey.shade400, size: 20),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.8),
        ),
      ),
      validator: validator,
    );
  }
}
