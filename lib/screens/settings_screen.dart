import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/birth_context.dart';
import '../models/profile.dart';
import '../services/premium_service.dart';
import '../state/app_state.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl        = TextEditingController();
  final _cityCtrl        = TextEditingController();
  final _latCtrl         = TextEditingController();
  final _lonCtrl         = TextEditingController();
  final _anthropicCtrl   = TextEditingController();
  final _geminiCtrl      = TextEditingController();

  DateTime _date   = DateTime(1996, 3, 13);
  TimeOfDay _time  = const TimeOfDay(hour: 11, minute: 0);
  bool _timeKnown  = false;
  bool _obscureAnthropic = true;
  bool _obscureGemini    = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final p     = state.profile;
    _nameCtrl.text = p.name;
    _cityCtrl.text = p.birthContext.locationName ?? '';
    _latCtrl.text  = p.birthContext.latitude.toStringAsFixed(4);
    _lonCtrl.text  = p.birthContext.longitude.toStringAsFixed(4);
    _date = p.birthContext.utcTime;
    _time = TimeOfDay.fromDateTime(p.birthContext.utcTime);
    _timeKnown = p.birthTimeKnown;

    final premium = PremiumService.instance;
    _anthropicCtrl.text = premium.anthropicApiKey;
    _geminiCtrl.text    = premium.geminiApiKey;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _cityCtrl.dispose();
    _latCtrl.dispose();  _lonCtrl.dispose();
    _anthropicCtrl.dispose(); _geminiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: CosmicColors.neonLavender,
            onPrimary: Colors.black,
            surface: CosmicColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: CosmicColors.neonLavender,
            surface: CosmicColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() { _time = t; _timeKnown = true; });
  }

  Future<void> _save() async {
    final premium = PremiumService.instance;
    await premium.setAnthropicKey(_anthropicCtrl.text);
    await premium.setGeminiKey(_geminiCtrl.text);

    final lat = double.tryParse(_latCtrl.text) ?? 50.9311;
    final lon = double.tryParse(_lonCtrl.text) ?? 5.3378;

    final utc = _timeKnown
        ? DateTime.utc(_date.year, _date.month, _date.day, _time.hour, _time.minute)
        : DateTime.utc(_date.year, _date.month, _date.day, 11, 0); // noon CET

    final newProfile = context.read<AppState>().profile.copyWith(
      name: _nameCtrl.text.isEmpty ? 'Paulien' : _nameCtrl.text,
      birthTimeKnown: _timeKnown,
      birthContext: BirthContext(
        utcTime: utc,
        latitude: lat,
        longitude: lon,
        locationName: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
        personName: _nameCtrl.text.isEmpty ? 'Paulien' : _nameCtrl.text,
      ),
    );

    await context.read<AppState>().updateProfile(newProfile);
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved & chart recalculated'),
          backgroundColor: CosmicColors.neonLavender.withValues(alpha: 0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final premium = PremiumService.instance;

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: CosmicColors.background,
                automaticallyImplyLeading: false,
                title: Text('Settings',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 20)),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SectionTitle('BIRTH PROFILE'),
                    const SizedBox(height: 12),
                    _betaNotice(context),
                    const SizedBox(height: 12),
                    _field(_nameCtrl, 'Name', Icons.person_outline),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _dateTile()),
                      const SizedBox(width: 10),
                      Expanded(child: _timeTile()),
                    ]),
                    const SizedBox(height: 4),
                    _timeUnknownToggle(),
                    const SizedBox(height: 10),
                    _field(_cityCtrl, 'Birth City', Icons.location_city_outlined),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _field(_latCtrl, 'Latitude', Icons.explore_outlined,
                          keyboard: TextInputType.numberWithOptions(
                              decimal: true, signed: true))),
                      const SizedBox(width: 10),
                      Expanded(child: _field(_lonCtrl, 'Longitude', Icons.explore_outlined,
                          keyboard: TextInputType.numberWithOptions(
                              decimal: true, signed: true))),
                    ]),
                    const SizedBox(height: 24),

                    _SectionTitle('AI API KEYS'),
                    const SizedBox(height: 8),
                    _apiKeyInfo(context),
                    const SizedBox(height: 12),
                    _apiKeyField(
                      controller: _anthropicCtrl,
                      label: 'Anthropic API Key',
                      hint: 'sk-ant-...',
                      obscure: _obscureAnthropic,
                      logo: '🤖',
                      onToggle: () => setState(
                          () => _obscureAnthropic = !_obscureAnthropic),
                      onClear: () async {
                        await PremiumService.instance.clearAnthropicKey();
                        setState(() => _anthropicCtrl.clear());
                      },
                    ),
                    const SizedBox(height: 10),
                    _apiKeyField(
                      controller: _geminiCtrl,
                      label: 'Google Gemini API Key',
                      hint: 'AIza...',
                      obscure: _obscureGemini,
                      logo: '✨',
                      onToggle: () =>
                          setState(() => _obscureGemini = !_obscureGemini),
                      onClear: () async {
                        await PremiumService.instance.clearGeminiKey();
                        setState(() => _geminiCtrl.clear());
                      },
                    ),
                    const SizedBox(height: 12),
                    _keyStatusRow(premium),
                    const SizedBox(height: 24),

                    _SectionTitle('SUBSCRIPTION'),
                    const SizedBox(height: 12),
                    _subscriptionCard(context, premium),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: Text(_saved ? 'SAVED ✓' : 'SAVE & RECALCULATE'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        await context.read<AppState>().resetToDefault();
                        setState(() {
                          _nameCtrl.text  = 'Paulien';
                          _cityCtrl.text  = 'Hasselt, Belgium';
                          _latCtrl.text   = '50.9311';
                          _lonCtrl.text   = '5.3378';
                          _timeKnown      = false;
                        });
                      },
                      child: const Text('Reset to Paulien\'s default',
                          style: TextStyle(
                              color: CosmicColors.textMuted, fontSize: 12)),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _betaNotice(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: CosmicColors.neonYellow.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: CosmicColors.neonYellow.withValues(alpha: 0.3)),
    ),
    child: Row(children: [
      const Text('⚡ ', style: TextStyle(fontSize: 14)),
      Expanded(child: Text(
        'Beta mode — all settings are editable. '
        'Birth time unknown uses synthetic noon (CET). '
        'Update when you know the exact time.',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: CosmicColors.neonYellow, fontSize: 11),
      )),
    ]),
  );

  Widget _apiKeyInfo(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: CosmicColors.neonLavender.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: CosmicColors.neonLavender.withValues(alpha: 0.2)),
    ),
    child: Text(
      'Adding your own API key unlocks Premium for free. '
      'Keys are stored locally on your device only — never sent to our servers.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
    ),
  );

  Widget _dateTile() => GestureDetector(
    onTap: _pickDate,
    child: _tilebox(
      icon: Icons.calendar_today_outlined,
      label: 'Birth Date',
      value: '${_date.day.toString().padLeft(2,'0')}/'
          '${_date.month.toString().padLeft(2,'0')}/${_date.year}',
    ),
  );

  Widget _timeTile() => GestureDetector(
    onTap: _pickTime,
    child: _tilebox(
      icon: Icons.access_time_outlined,
      label: 'Time (local)',
      value: _timeKnown ? _time.format(context) : 'Unknown',
      valueColor: _timeKnown ? null : CosmicColors.textMuted,
    ),
  );

  Widget _timeUnknownToggle() => GestureDetector(
    onTap: () => setState(() => _timeKnown = false),
    child: Row(children: [
      Icon(
        _timeKnown ? Icons.check_box_outline_blank : Icons.check_box,
        color: CosmicColors.textMuted, size: 16,
      ),
      const SizedBox(width: 6),
      Text('Birth time unknown (use synthetic noon)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
    ]),
  );

  Widget _tilebox({required IconData icon, required String label,
      required String value, Color? valueColor}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: CosmicColors.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CosmicColors.divider),
    ),
    child: Row(children: [
      Icon(icon, color: CosmicColors.textMuted, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: CosmicColors.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(
            color: valueColor ?? CosmicColors.textPrimary, fontSize: 14)),
      ])),
    ]),
  );

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboard}) => TextField(
    controller: ctrl,
    keyboardType: keyboard,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: CosmicColors.textMuted, size: 18),
    ),
    style: const TextStyle(color: CosmicColors.textPrimary),
  );

  Widget _apiKeyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required String logo,
    required VoidCallback onToggle,
    required VoidCallback onClear,
  }) => TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: '$logo  $label',
      hintText: hint,
      prefixIcon: const Icon(Icons.vpn_key_outlined,
          color: CosmicColors.textMuted, size: 18),
      suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: CosmicColors.textMuted, size: 18),
          onPressed: onToggle,
        ),
        if (controller.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: CosmicColors.textMuted, size: 18),
            onPressed: onClear,
          ),
      ]),
    ),
    style: const TextStyle(color: CosmicColors.textPrimary, fontSize: 13),
  );

  Widget _keyStatusRow(PremiumService premium) => Row(children: [
    _keyBadge('Claude', premium.hasAnthropicKey),
    const SizedBox(width: 8),
    _keyBadge('Gemini', premium.hasGeminiKey),
    const SizedBox(width: 8),
    if (premium.isPremium)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: CosmicColors.neonGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CosmicColors.neonGreen.withValues(alpha: 0.4)),
        ),
        child: const Text('PREMIUM ✓',
            style: TextStyle(color: CosmicColors.neonGreen,
                fontSize: 10, fontWeight: FontWeight.w700)),
      ),
  ]);

  Widget _keyBadge(String name, bool active) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: (active ? CosmicColors.neonLavender : CosmicColors.textMuted)
          .withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
          color: (active ? CosmicColors.neonLavender : CosmicColors.divider)
              .withValues(alpha: 0.4)),
    ),
    child: Text('$name ${active ? '✓' : '✗'}',
        style: TextStyle(
            color: active ? CosmicColors.neonLavender : CosmicColors.textMuted,
            fontSize: 11)),
  );

  Widget _subscriptionCard(BuildContext context, PremiumService premium) =>
      Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: premium.isPremium
            ? [
                CosmicColors.neonGreen.withValues(alpha: 0.12),
                CosmicColors.neonCyan.withValues(alpha: 0.06),
              ]
            : [
                CosmicColors.card,
                CosmicColors.card,
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: premium.isPremium
              ? CosmicColors.neonGreen.withValues(alpha: 0.4)
              : CosmicColors.divider),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(
          premium.isPremium ? '✦ Premium Unlocked' : '☽ Free Tier',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: premium.isPremium
                  ? CosmicColors.neonGreen
                  : CosmicColors.textPrimary,
              fontSize: 15),
        ),
        if (!premium.isPremium) ...[
          const Spacer(),
          Text(
            '${premium.freeAiCallsRemaining}/3 AI calls left today',
            style: const TextStyle(
                color: CosmicColors.textMuted, fontSize: 11),
          ),
        ],
      ]),
      const SizedBox(height: 8),
      Text(
        premium.isPremium
            ? 'All features unlocked via API key. Thank you!'
            : 'Add an Anthropic or Gemini API key above to unlock all features for free.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
    ]),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: CosmicColors.neonLavender, letterSpacing: 2, fontSize: 11),
  );
}
