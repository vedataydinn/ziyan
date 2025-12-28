import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/motivation_quotes.dart';

class MotivationCard extends StatefulWidget {
  final String? initialQuote;

  const MotivationCard({
    super.key,
    this.initialQuote,
  });

  @override
  State<MotivationCard> createState() => _MotivationCardState();
}

class _MotivationCardState extends State<MotivationCard> {
  late String _currentQuote;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _currentQuote = widget.initialQuote ?? MotivationQuotes.getRandomQuote();
    _startQuoteTimer();
  }

  void _startQuoteTimer() {
    // Her 5 dakikada bir söz değiştir
    _quoteTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentQuote = MotivationQuotes.getRandomQuote();
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  void _changeQuote() {
    setState(() {
      _currentQuote = MotivationQuotes.getRandomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeQuote,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.secondaryColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.format_quote,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentQuote,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yeni söz için dokun',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.refresh,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
