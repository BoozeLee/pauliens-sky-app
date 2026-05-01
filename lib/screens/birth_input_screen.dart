import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/birth_context.dart';
import '../models/profile.dart';
import '../state/app_state.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';
import 'chart_screen.dart';

class BirthInputScreen extends StatefulWidget {
  final BirthContext? initial;
  // When set: editing an existing profile in place
  final String? existingProfileId;
  const BirthInputScreen({super.key, this.initial, this.existingProfileId});

  @override
  State<BirthInputScreen> createState() => _BirthInputScreenState();
}

class _BirthInputScreenState extends State<BirthInputScreen> {
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  DateTime _date = DateTime(1996, 3, 13);
  TimeOfDay _time = const TimeOfDay(hour: 12, minute: 0);
  double _lat = 52.3676;
  double _lon = 4.9041;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameCtrl.text = widget.initial!.personName ?? '';
      _cityCtrl.text = widget.initial!.locationName ?? '';
      _date = widget.initial!.utcTime;
      _time = TimeOfDay.fromDateTime(widget.initial!.utcTime);
      _lat = widget.initial!.latitude;
      _lon = widget.initial!.longitude;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
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
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
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
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _calculate() async {
    setState(() => _loading = true);
    final utc = DateTime.utc(
      _date.year, _date.month, _date.day,
      _time.hour, _time.minute,
    );
    final ctx = BirthContext(
      utcTime: utc,
      latitude: _lat,
      longitude: _lon,
      locationName: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
      personName: _nameCtrl.text.isEmpty ? null : _nameCtrl.text,
    );
    setState(() => _loading = false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChartScreen(birthContext: ctx)),
    );
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a name first'),
      ));
      return;
    }
    setState(() => _loading = true);
    final utc = DateTime.utc(
      _date.year, _date.month, _date.day,
      _time.hour, _time.minute,
    );
    final ctx = BirthContext(
      utcTime: utc,
      latitude: _lat,
      longitude: _lon,
      locationName: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
      personName: _nameCtrl.text.trim(),
    );
    final appState = context.read<AppState>();
    if (widget.existingProfileId != null) {
      // Edit existing
      final existing = appState.profiles
          .firstWhere((p) => p.id == widget.existingProfileId);
      await appState.updateProfile(existing.copyWith(
        name: _nameCtrl.text.trim(),
        birthContext: ctx,
      ));
    } else {
      // Create new
      await appState.addProfile(Profile(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        birthContext: ctx,
      ));
    }
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.existingProfileId != null
            ? 'Profile updated!'
            : 'Profile saved!'),
        backgroundColor: CosmicColors.neonGreen.withValues(alpha: 0.9),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: CosmicColors.background,
                title: Text('Read the Sky',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20)),
                leading: BackButton(color: CosmicColors.textSecondary),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SectionLabel('Who are we reading?'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name (optional)',
                        prefixIcon: Icon(Icons.person_outline,
                            color: CosmicColors.textMuted, size: 18),
                      ),
                      style: const TextStyle(color: CosmicColors.textPrimary),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('Birth Date & Time'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TapField(
                            label: 'Date',
                            value: '${_date.day.toString().padLeft(2, '0')} / '
                                '${_date.month.toString().padLeft(2, '0')} / '
                                '${_date.year}',
                            icon: Icons.calendar_today_outlined,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TapField(
                            label: 'Time (local)',
                            value: _time.format(context),
                            icon: Icons.access_time_outlined,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('Birth Location'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_on_outlined,
                            color: CosmicColors.textMuted, size: 18),
                        hintText: 'e.g. Amsterdam',
                      ),
                      style: const TextStyle(color: CosmicColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _CoordField(
                            label: 'Latitude',
                            value: _lat,
                            onChanged: (v) => setState(() => _lat = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CoordField(
                            label: 'Longitude',
                            value: _lon,
                            onChanged: (v) => setState(() => _lon = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Latitude/longitude auto-filled for Amsterdam. '
                      'Update if birth city is different.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _calculate,
                        child: _loading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black),
                              )
                            : const Text('REVEAL THE SKY'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          widget.existingProfileId != null
                              ? Icons.save_outlined
                              : Icons.person_add_outlined,
                          size: 16,
                          color: CosmicColors.neonCyan,
                        ),
                        label: Text(
                          widget.existingProfileId != null
                              ? 'UPDATE PROFILE'
                              : 'SAVE AS PROFILE',
                          style: const TextStyle(color: CosmicColors.neonCyan),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: CosmicColors.neonCyan.withValues(alpha: 0.5)),
                        ),
                        onPressed: _loading ? null : _saveProfile,
                      ),
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
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: CosmicColors.neonLavender, letterSpacing: 2),
    );
  }
}

class _TapField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  const _TapField(
      {required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: CosmicColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CosmicColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: CosmicColors.textMuted, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: CosmicColors.textMuted, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          color: CosmicColors.textPrimary, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _CoordField(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.toStringAsFixed(4),
      keyboardType: const TextInputType.numberWithOptions(
          decimal: true, signed: true),
      decoration: InputDecoration(labelText: label),
      style: const TextStyle(color: CosmicColors.textPrimary),
      onChanged: (v) {
        final parsed = double.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}
