import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  String? _selectedColor;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing(String displayName, String avatarColor) {
    _nameController.text = displayName;
    setState(() {
      _selectedColor = avatarColor;
      _editing = true;
      _error = null;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(authStateProvider.notifier).updateProfile(
            displayName: name,
            avatarColor: _selectedColor,
          );
      if (mounted) {
        setState(() => _editing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(stringsProvider).profileUpdated)),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).value;
    final s = ref.watch(stringsProvider);
    final lang = ref.watch(appLanguageProvider).valueOrNull ?? 'tr';

    if (auth == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final avatarColor = MimioColors.fromHex(_editing ? (_selectedColor ?? auth.avatarColor) : auth.avatarColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: avatarColor,
                  child: Text(
                    auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  auth.email,
                  style: const TextStyle(color: MimioColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _SectionHeader(title: s.account),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: Text(s.editProfile),
            trailing: Icon(_editing ? Icons.expand_less : Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: Colors.white,
            onTap: () {
              if (_editing) {
                setState(() => _editing = false);
              } else {
                _startEditing(auth.displayName, auth.avatarColor);
              }
            },
          ),
          if (_editing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.displayName, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: s.displayName),
                  ),
                  const SizedBox(height: 16),
                  Text(s.avatarColor, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: MimioColors.taskColors.map((hex) {
                      final color = MimioColors.fromHex(hex);
                      final selected = (_selectedColor ?? auth.avatarColor) == hex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = hex),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selected ? Border.all(color: MimioColors.textPrimary, width: 3) : null,
                          ),
                          child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(s.save),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader(title: s.integrations),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8F0)),
            ),
            child: ListTile(
              leading: const Icon(Icons.calendar_month_rounded, color: MimioColors.primary),
              title: Text(s.calendarImport),
              subtitle: Text(s.calendarImportSubtitle, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/calendar-import'),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: s.preferences),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(s.language),
                  subtitle: Text(s.languageName(lang)),
                  trailing: DropdownButton<String>(
                    value: lang,
                    underline: const SizedBox.shrink(),
                    items: supportedLanguageCodes
                        .map((code) => DropdownMenuItem(value: code, child: Text(s.languageName(code))))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(appLanguageProvider.notifier).setLanguage(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(s.notifications),
                  subtitle: Text(s.comingSoon, style: const TextStyle(fontSize: 12)),
                  enabled: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.red.shade400),
            title: Text(s.logout, style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: Colors.white,
            onTap: () => ref.read(authStateProvider.notifier).logout(),
          ),
          const SizedBox(height: 32),
          Text(
            '${s.version} 1.0.0',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: MimioColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: MimioColors.textSecondary,
        ),
      ),
    );
  }
}
