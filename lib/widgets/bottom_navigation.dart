import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final String currentScreen;
  final Function(String) onNavigate;

  const BottomNavigation({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('home', Icons.home_outlined, 'Home'),
          _buildNavItem('search', Icons.search, 'Search'),
          _buildNavItem('upload', Icons.add, 'Share', isSpecial: true),
          _buildNavItem('chat', Icons.message_outlined, 'Chat'),
          _buildNavItem('profile', Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(String screen, IconData icon, String label, {bool isSpecial = false}) {
    final isActive = currentScreen == screen;
    final color = isActive ? const Color(0xFFA855F7) : Colors.grey[400];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNavigate(screen),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSpecial ? 8 : 4),
                decoration: isSpecial && isActive
                    ? const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF2DD4BF)]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.purple, blurRadius: 4)],
                      )
                    : null,
                child: Icon(
                  icon,
                  size: 24,
                  color: isSpecial && isActive ? Colors.white : color,
                ),
              ),
              if (!isSpecial || !isActive)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
