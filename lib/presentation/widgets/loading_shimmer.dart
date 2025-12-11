import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Loading Shimmer Widget
class LoadingShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Shimmer List Loader
class ShimmerListLoader extends StatelessWidget {
  final int itemCount;

  const ShimmerListLoader({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const LoadingShimmer(
        height: 80,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

/// PDF Preview Shimmer
class PdfPreviewShimmer extends StatelessWidget {
  const PdfPreviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          LoadingShimmer(
            height: 400,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              LoadingShimmer(width: 100, height: 50),
              LoadingShimmer(width: 100, height: 50),
              LoadingShimmer(width: 100, height: 50),
            ],
          ),
        ],
      ),
    );
  }
}
