import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TicketStub extends StatelessWidget {
  final Widget child;
  final Widget? status;

  const TicketStub({super.key, required this.child, this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFDED9D1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
          if (status != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: _DashedDivider(),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: status!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFDED9D1)),
              ),
            );
          }),
        );
      },
    );
  }
}
