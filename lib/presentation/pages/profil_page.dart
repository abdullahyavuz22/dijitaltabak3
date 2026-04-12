import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _profil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final response = await SupabaseConfig.client
          .from('profiller')
          .select()
          .eq('user_id', userId)
          .single();
      if (mounted) setState(() { _profil = response; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage("assets/images/db.jpg"),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: const Icon(Icons.person, color: AppColors.primary),
                    title: Text(
                      _profil != null
                          ? '${_profil!['ad']} ${_profil!['soyad'] ?? ''}'
                          : 'Doğukan BAYESEN',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email, color: AppColors.primary),
                    title: Text(_profil?['email'] ?? 'dogukan.bayesen@rumeli.edu.tr'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: AppColors.primary),
                    title: Text(_profil?['telefon'] ?? '+90 555 123 45 67'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: AppColors.primary),
                    title: Text(_profil?['bio'] ?? 'Flutter geliştiricisi, tarif meraklısı.'),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profil düzenleme tıklandı")),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Profili Düzenle"),
                  ),
                ],
              ),
            ),
    );
  }
}
