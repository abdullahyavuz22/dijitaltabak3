import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/entities/diyet.dart';
import 'diyet_detay_page.dart';

class DiyetlerPage extends StatefulWidget {
  const DiyetlerPage({super.key});

  @override
  State<DiyetlerPage> createState() => _DiyetlerPageState();
}

class _DiyetlerPageState extends State<DiyetlerPage> {
  List<Diyet> _diyetler = [];
  bool _isLoading = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _loadDiyetler();
  }

  Future<void> _loadDiyetler() async {
    if (mounted) setState(() { _isLoading = true; _hata = null; });
    try {
      final response = await SupabaseConfig.client
          .from('diyet_planlari')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _diyetler = (response as List)
              .map((e) => Diyet.fromMap(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Diyetler] Hata: $e');
      if (mounted) {
        setState(() {
          _hata = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diyetler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Veri alınamadı:\n$_hata',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
          : _diyetler.isEmpty
              ? const Center(
                  child: Text(
                    'Henüz diyet listesi paylaşılmamış.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _diyetler.length,
                  itemBuilder: (context, index) {
                    final diyet = _diyetler[index];
                    return _DiyetKarti(
                      diyet: diyet,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiyetDetayPage(diyet: diyet),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _DiyetKarti extends StatelessWidget {
  final Diyet diyet;
  final VoidCallback onTap;
  const _DiyetKarti({required this.diyet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 22,
                    child: Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diyet.baslik,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          diyet.diyetisyen,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (diyet.aciklama != null) ...[
                const SizedBox(height: 12),
                Text(
                  diyet.aciklama!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (diyet.kalori != null)
                    _InfoChip(
                      icon: Icons.local_fire_department,
                      label: '${diyet.kalori} kcal',
                    ),
                  if (diyet.kalori != null && diyet.sure != null)
                    const SizedBox(width: 8),
                  if (diyet.sure != null)
                    _InfoChip(
                      icon: Icons.schedule,
                      label: diyet.sure!,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
