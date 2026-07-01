import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimio/core/models/ai_models.dart';
import 'package:mimio/core/repositories/ai_repository.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';
import 'package:mimio/features/timeline/home_tab.dart';

enum AiMode { breakdown, plan }

final aiModeProvider = StateProvider<AiMode>((ref) => AiMode.plan);

class AiPlanScreen extends ConsumerStatefulWidget {
  const AiPlanScreen({super.key});

  @override
  ConsumerState<AiPlanScreen> createState() => _AiPlanScreenState();
}

class _AiPlanScreenState extends ConsumerState<AiPlanScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  AiBreakdownModel? _breakdown;
  AiPlanModel? _plan;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _breakdown = null;
      _plan = null;
    });

    try {
      final mode = ref.read(aiModeProvider);
      if (mode == AiMode.breakdown) {
        final result = await ref.read(aiRepositoryProvider).breakdown(text);
        setState(() => _breakdown = result);
      } else {
        final date = ref.read(selectedDateProvider);
        final result = await ref.read(aiRepositoryProvider).plan(text, date: date);
        setState(() => _plan = result);
      }
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      if (status == 401) return 'Oturum süresi doldu. Tekrar giriş yapın.';
      if (status == 403) {
        return 'AI endpoint erişilemedi. Backend ve ngrok çalışıyor mu? Backend\'i yeniden başlatın.';
      }
    }
    final msg = e.toString();
    if (msg.contains('Groq')) return 'AI servisi kullanılamıyor. Groq API anahtarını kontrol edin.';
    if (msg.contains('connection') || msg.contains('SocketException')) {
      return 'Sunucuya bağlanılamadı. Backend çalışıyor mu?';
    }
    return msg.replaceFirst('Exception: ', '').replaceFirst('DioException [bad response]: ', '');
  }

  Future<void> _applyPlan() async {
    if (_plan == null) return;
    for (final task in _plan!.tasks) {
      await ref.read(timelineProvider.notifier).createTask(
            title: task.title,
            durationMinutes: task.durationMinutes,
            color: task.color,
            scheduledAt: task.scheduledAt(_plan!.date),
          );
    }
    if (mounted) {
      ref.read(homeTabProvider.notifier).state = HomeTab.today;
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_plan!.tasks.length} görev plana eklendi ✨')),
      );
    }
  }

  Future<void> _applyBreakdown() async {
    if (_breakdown == null) return;
    final date = ref.read(selectedDateProvider);
    var hour = DateTime.now().hour;
    var minute = 0;
    if (hour < 8) {
      hour = 8;
    }
    final scheduledAt = DateTime(date.year, date.month, date.day, hour, minute);

    await ref.read(timelineProvider.notifier).createTaskWithSubtasks(
          title: _breakdown!.originalTask,
          scheduledAt: scheduledAt,
          color: _breakdown!.steps.first.color,
          subtasks: _breakdown!.steps
              .map((s) => (title: s.title, durationMinutes: s.durationMinutes, color: s.color))
              .toList(),
        );

    if (mounted) {
      ref.read(homeTabProvider.notifier).state = HomeTab.today;
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_breakdown!.steps.length} adımlı görev eklendi ✨')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(aiModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Planlayıcı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E8F0)),
              ),
              child: Row(
                children: [
                  _ModeChip(
                    label: 'Gün Planla',
                    icon: Icons.auto_awesome_rounded,
                    selected: mode == AiMode.plan,
                    onTap: () => ref.read(aiModeProvider.notifier).state = AiMode.plan,
                  ),
                  _ModeChip(
                    label: 'Görev Böl',
                    icon: Icons.checklist_rounded,
                    selected: mode == AiMode.breakdown,
                    onTap: () => ref.read(aiModeProvider.notifier).state = AiMode.breakdown,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              mode == AiMode.plan ? 'Aklındakileri yaz' : 'Büyük görevi yaz',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              mode == AiMode.plan
                  ? 'Örn: "Sabah spor, öğleden sonra toplantı, akşam alışveriş"'
                  : 'Örn: "Ev temizliği yapacağım" → küçük adımlara böler',
              style: const TextStyle(color: MimioColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: mode == AiMode.plan ? 'Bugün ne yapmak istiyorsun?' : 'Hangi görevi bölelim?',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_loading ? 'AI düşünüyor...' : 'Plan Oluştur'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade700))),
                  ],
                ),
              ),
            ],
            if (_plan != null) ...[
              const SizedBox(height: 24),
              _ResultHeader(
                title: _plan!.summary,
                subtitle: '${_plan!.tasks.length} görev · ${_plan!.totalMinutes} dk',
              ),
              ..._plan!.tasks.map((t) => _TaskResultTile(
                    title: t.title,
                    subtitle: '${t.suggestedTime} · ${t.durationMinutes} dk',
                    color: MimioColors.fromHex(t.color),
                  )),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _applyPlan,
                icon: const Icon(Icons.calendar_today_rounded),
                label: const Text('Planı Güne Ekle'),
                style: ElevatedButton.styleFrom(backgroundColor: MimioColors.success),
              ),
            ],
            if (_breakdown != null) ...[
              const SizedBox(height: 24),
              _ResultHeader(
                title: _breakdown!.originalTask,
                subtitle: '${_breakdown!.steps.length} adım · ${_breakdown!.totalMinutes} dk',
              ),
              ..._breakdown!.steps.asMap().entries.map((e) => _TaskResultTile(
                    title: '${e.key + 1}. ${e.value.title}',
                    subtitle: '${e.value.durationMinutes} dk',
                    color: MimioColors.fromHex(e.value.color),
                  )),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _applyBreakdown,
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Görev ve Adımları Ekle'),
                style: ElevatedButton.styleFrom(backgroundColor: MimioColors.success),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Powered by Groq AI',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: MimioColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? MimioColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : MimioColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : MimioColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MimioColors.primary.withValues(alpha: 0.15), MimioColors.primaryLight.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: MimioColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TaskResultTile extends StatelessWidget {
  const _TaskResultTile({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8F0)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
