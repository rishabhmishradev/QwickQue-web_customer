import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoutiqueBottomNav extends StatelessWidget {
  const BoutiqueBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDED9D1), width: 1)),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_outlined, size: 24),
                    onPressed: () => context.go('/home'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.explore_outlined, size: 24),
                    onPressed: () => context.go('/explore'),
                  ),
                  const SizedBox(width: 50), // Space for center button
                  IconButton(
                    icon: const Icon(Icons.percent_outlined, size: 24),
                    onPressed: () => context.push('/offers'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, size: 24),
                    onPressed: () => context.push('/profile'),
                  ),
                ],
              ),
              Positioned(
                top: -25,
                child: GestureDetector(
                  onTap: () => context.push('/my-bookings'),
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A0000),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.hourglass_bottom, color: Colors.black, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
