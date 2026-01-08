import 'package:flutter/material.dart';
import 'package:my_new_app/app/custome_widgets/skeleton_box.dart';

class SkeletonCarousel extends StatelessWidget {
  final int itemCount;
  final double height;

  const SkeletonCarousel({
    super.key,
    this.itemCount = 3,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) {
          return SkeletonBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: height,
            radius: 18,
          );
        },
      ),
    );
  }
}
