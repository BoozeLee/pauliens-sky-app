import 'package:flutter/material.dart';
import '../services/ui_schema.dart';

// ── Generic insight card (maps to "insight_block" template) ───────────────

class InsightCard extends StatelessWidget {
  final Color accent;
  final Widget child;
  final EdgeInsets? padding;
  const InsightCard({
    super.key,
    required this.accent,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final schema = UiSchema.instance;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: schema.palette.textPrimary),
        child: child,
      ),
    );
  }
}

// ── Tradition card (grid cell, replaces hardcoded _TraditionsGrid cell) ───

class TraditionCard extends StatelessWidget {
  final TraditionDef tradition;
  final String label;
  final String description;
  final VoidCallback? onTap;
  const TraditionCard({
    super.key,
    required this.tradition,
    required this.label,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = tradition.accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: tradition.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(tradition.borderRadius),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tradition.symbol, style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                color: UiSchema.instance.palette.textMuted,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Schema-driven sign badge ──────────────────────────────────────────────

class SchemaSignBadge extends StatelessWidget {
  final String text;
  final Color color;
  const SchemaSignBadge(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, letterSpacing: 0.3),
      ),
    );
  }
}
