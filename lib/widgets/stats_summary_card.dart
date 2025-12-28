import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class StatsSummaryCard extends StatelessWidget {
  final String title;
  final int totalMinutes;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool showProgress;
  final double progress;
  final bool showMoney; // Para gösterimi

  const StatsSummaryCard({
    super.key,
    required this.title,
    required this.totalMinutes,
    this.subtitle,
    required this.icon,
    required this.color,
    this.showProgress = false,
    this.progress = 0,
    this.showMoney = true, // Varsayılan olarak para göster
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.formatMinutes(totalMinutes),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (totalMinutes > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(totalMinutes / 60).toStringAsFixed(1)}h',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (showMoney) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.money_off,
                                size: 12,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Helpers.formatMoney(Helpers.minutesToMoney(totalMinutes)),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            if (showProgress) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 1 ? Colors.red : color,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progress > 1
                        ? 'Hedefi aştın!'
                        : '${(progress * 100).toStringAsFixed(0)}% kullandın',
                    style: TextStyle(
                      color: progress > 1 ? Colors.red : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (progress > 0)
                    Text(
                      progress > 1
                          ? '+${Helpers.formatMinutes(((progress - 1) * (totalMinutes / progress)).round())}'
                          : 'Kalan: ${Helpers.formatMinutes(((1 - progress) * (totalMinutes / progress)).round())}',
                      style: TextStyle(
                        color: progress > 1 ? Colors.red : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
