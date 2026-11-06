import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/app_ui.dart';
import '../../core/config/supabase_config.dart';

class SoruSormaPage extends StatefulWidget {
  const SoruSormaPage({super.key});

  @override
  State<SoruSormaPage> createState() => _SoruSormaPageState();
}

class _SoruSormaPageState extends State<SoruSormaPage> {
  final TextEditingController _konuController = TextEditingController();
  final TextEditingController _soruController = TextEditingController();
  List<Map<String, dynamic>> _sorular = [];
  bool _isLoading = true;
  bool _isSending = false;

  String get _userEmail => SupabaseConfig.client.auth.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    _loadSorular();
  }

  @override
  void dispose() {
    _konuController.dispose();
    _soruController.dispose();
    super.dispose();
  }

  Future<void> _loadSorular() async {
    if (_userEmail.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final response = await SupabaseConfig.client
          .from('sorular')
          .select()
          .eq('email', _userEmail)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _sorular = List<Map<String, dynamic>>.from(response as List);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _soruEkle() async {
    if (_konuController.text.trim().isEmpty ||
        _soruController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konu ve soru alanlarını doldurun')),
      );
      return;
    }
    if (_userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soru sormak için giriş yapmalısınız')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await SupabaseConfig.client.from('sorular').insert({
        'email': _userEmail,
        'konu': _konuController.text.trim(),
        'soru': _soruController.text.trim(),
      });
      _konuController.clear();
      _soruController.clear();
      await _loadSorular();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sorunuz iletildi')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Soru Sor')),
      body: RefreshIndicator(
        onRefresh: _loadSorular,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Form ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconBadge(icon: Icons.forum_outlined),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Uzmanına danış',
                                    style: text.titleMedium,
                                  ),
                                  Text(
                                    _userEmail.isNotEmpty
                                        ? _userEmail
                                        : 'Beslenme ile ilgili sorularını gönder',
                                    style: text.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextField(
                          controller: _konuController,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Konu',
                            hintText: 'örn. Kahvaltı önerisi',
                            prefixIcon: Icon(Icons.label_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _soruController,
                          minLines: 3,
                          maxLines: 6,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Sorunuzu yazın...',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LoadingButton(
                          label: 'Soruyu Gönder',
                          icon: Icons.send_rounded,
                          loading: _isSending,
                          onPressed: _soruEkle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Başlık ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionTitle(
                  title: 'Sorularım',
                  trailing: _isLoading
                      ? null
                      : InfoPill(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: '${_sorular.length}',
                        ),
                ),
              ),
            ),

            // ── Liste ───────────────────────────────────────────
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_sorular.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.help_outline_rounded,
                  title: 'Henüz soru sormadınız',
                  message: 'Gönderdiğiniz sorular burada listelenir.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                sliver: SliverList.separated(
                  itemCount: _sorular.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _SoruKarti(soru: _sorular[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SoruKarti extends StatelessWidget {
  const _SoruKarti({required this.soru});

  final Map<String, dynamic> soru;

  String? get _tarih {
    final raw = soru['created_at'];
    if (raw == null) return null;
    final d = DateTime.tryParse(raw.toString())?.toLocal();
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tarih = _tarih;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(soru['konu'] ?? '', style: text.titleSmall),
                ),
                if (tarih != null)
                  Text(
                    tarih,
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              soru['soru'] ?? '',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
