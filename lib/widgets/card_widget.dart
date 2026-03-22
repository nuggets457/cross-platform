import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/design_size.dart';

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // This wrapper gives every screen a consistent full-screen canvas.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return SafeArea(
      child: SizedBox.expand(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.fromLTRB(
            DesignSize.w(context, 28),
            DesignSize.h(context, 28),
            DesignSize.w(context, 28),
            DesignSize.h(context, 28),
          ),
          decoration: BoxDecoration(
            color: surface,
          ),
          child: SizedBox.expand(
            child: child,
          ),
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // The header keeps title alignment stable whether the back button exists
    // or not by reserving the same width on both sides.
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 32,
              child: onBack == null
                  ? null
                  : IconButton(
                      onPressed: onBack,
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: textColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
        if (subtitle != null) ...[
          SizedBox(height: DesignSize.h(context, 20)),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: textColor),
          ),
        ],
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.chevron_right,
    this.onTap,
    this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSoft : AppColors.lightSoft;
    final textColor = isDark ? Colors.white : Colors.black;
    final accent = accentColor ?? Colors.orange;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSize.r(context, 10)),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSize.w(context, 14),
            vertical: DesignSize.h(context, 12),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                cardColor.withAlpha((255 * 0.85).toInt()),
              ],
            ),
            borderRadius: BorderRadius.circular(DesignSize.r(context, 10)),
            border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textColor,
                          ),
                    ),
                    SizedBox(height: DesignSize.h(context, 8)),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: accent, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.caption,
    required this.onTap,
    this.imageUrl,
    this.description,
  });

  final String title;
  final String caption;
  final VoidCallback onTap;
  final String? imageUrl;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? Colors.white : Colors.black;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignSize.r(context, 12)),
          child: Ink(
            padding: EdgeInsets.all(DesignSize.r(context, 14)),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(DesignSize.r(context, 12)),
              image: imageUrl == null
                  ? null
                  : DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.45),
                        BlendMode.darken,
                      ),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: DesignSize.h(context, 20)),
                Text(
                  caption,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor,
                      ),
                ),
                if (description != null && description!.isNotEmpty) ...[
                  SizedBox(height: DesignSize.h(context, 12)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        description!.length > 150
                            ? '${description!.substring(0, 150)}...'
                            : description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.chevron_right, color: textColor, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkSoft : AppColors.lightSoft;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignSize.r(context, 12)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DesignSize.r(context, 10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacity(0.8),
                ),
          ),
          SizedBox(height: DesignSize.h(context, 10)),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}

class ImagePanel extends StatelessWidget {
  const ImagePanel({
    super.key,
    this.imageUrl,
    this.heightFactor = 0.26,
    this.child,
  });

  final String? imageUrl;
  final double heightFactor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      width: double.infinity,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(DesignSize.r(context, 16)),
        border: Border.all(color: borderColor, width: 1.4),
        image: imageUrl == null
            ? null
            : DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              ),
      ),
      child: child ??
          Center(
            child: Icon(
              Icons.image_outlined,
              color: borderColor,
              size: 42,
            ),
          ),
    );
  }
}
