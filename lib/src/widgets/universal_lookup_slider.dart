import 'package:flutter/material.dart';
import 'package:asteroid_racers/src/models/lookup_item.dart';

class UniversalLookupSlider
    extends
        StatelessWidget {
  final String title;
  final List<
    LookupItem
  >
  items;
  final int selectedIndex;
  final ValueChanged<
    int
  >
  onChanged;
  final int hiddenCount;

  const UniversalLookupSlider({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.hiddenCount = 0,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    final currentItem = items[selectedIndex];
    final bool canSlide =
        items.length >
        1;
    final maxIndex = canSlide
        ? (items.length -
                  1)
              .toDouble()
        : 1.0;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        // Glassmorphism: More transparent background to let the space background peek through
        color: Colors.black.withValues(
          alpha: 0.6,
        ),
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          // Sharper holographic border
          color: Colors.blueAccent.withValues(
            alpha: 0.3,
          ),
          width: 1.5,
        ),
        boxShadow: [
          // Subtle outer glow
          BoxShadow(
            color: Colors.blueAccent.withValues(
              alpha: 0.1,
            ),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (hiddenCount >
                      0)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                      ),
                      child: Text(
                        "(+$hiddenCount more available in Premium!)",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              // Moved the current value label back to the right of the header for symmetry
              Text(
                currentItem.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),

          // 2. DESCRIPTION (Keeping your concatenated name + description logic)
          Text(
            '${currentItem.name}: ${currentItem.description}',
            style: const TextStyle(
              color: Colors.white54,
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // 3. SLIDER OR LOCKED MESSAGE
          if (canSlide) ...[
            SliderTheme(
              data:
                  SliderTheme.of(
                    context,
                  ).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14.0,
                    ),
                    // Neon Glow Colors
                    activeTrackColor: Colors.blueAccent,
                    inactiveTrackColor: Colors.white10,
                    thumbColor: Colors.white,
                  ),
              child: Slider(
                value: selectedIndex.toDouble(),
                min: 0,
                max: maxIndex,
                divisions:
                    items.length -
                    1,
                onChanged:
                    (
                      val,
                    ) => onChanged(
                      val.round(),
                    ),
              ),
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
                child: Text(
                  "LOCKED (UPGRADE FOR MORE OPTIONS)",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
