import 'package:flutter/material.dart';

class SharedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(BuildContext)? onHomePressed;
  final Function(BuildContext)? onTimesPressed;
  final Function(BuildContext)? onQiblaPressed;
  final Function(BuildContext)? onSettingsPressed;

  const SharedBottomNav({
    Key? key,
    required this.currentIndex,
    this.onHomePressed,
    this.onTimesPressed,
    this.onQiblaPressed,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(
            context,
            Icons.home_rounded,
            0,
            onHomePressed,
          ),
          _buildNavIcon(
            context,
            Icons.access_time_rounded,
            1,
            onTimesPressed,
          ),
          _buildNavIcon(
            context,
            Icons.explore_rounded,
            2,
            onQiblaPressed,
          ),
          _buildNavIcon(
            context,
            Icons.settings_rounded,
            3,
            onSettingsPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(
    BuildContext context,
    IconData icon,
    int index,
    Function(BuildContext)? onPressed,
  ) {
    final isActive = index == currentIndex;
    
    return GestureDetector(
      onTap: onPressed != null ? () => onPressed(context) : null,
      child: Icon(
        icon,
        color: isActive ? const Color(0xFFFFA726) : const Color(0xFF0F3460),
        size: 28,
      ),
    );
  }
}