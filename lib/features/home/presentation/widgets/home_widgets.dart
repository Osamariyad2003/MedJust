import 'package:flutter/material.dart';

class HomeMenuCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const HomeMenuCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(_getIconData(icon), color: Colors.white, size: 24),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'person':
        return Icons.person;
      case 'article':
        return Icons.article;
      case 'store':
        return Icons.store;
      case 'calculate':
        return Icons.calculate;
      case 'map':
        return Icons.map;
      default:
        return Icons.dashboard;
    }
  }
}
