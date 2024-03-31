import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';

class NoticeCard extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String description;
  final Function()? onTap;

  const NoticeCard({
    super.key,
    this.iconData = Icons.info_outline_rounded,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(iconData),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18)),
                  onTap == null
                      ? Text(description)
                      : GestureDetector(
                          onTap: onTap,
                          child: Expanded(
                              child: Text.rich(TextSpan(
                                  children: [
                                TextSpan(text: description),
                                WidgetSpan(
                                    child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Icon(Icons.arrow_forward_rounded, size: 17, color: context.theme.primaryColor),
                                ))
                              ],
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(color: context.theme.primaryColor, fontWeight: FontWeight.w500)))),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
