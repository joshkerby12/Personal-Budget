enum MealSlot { breakfast, lunch, dinner }

extension MealSlotX on MealSlot {
  String get value {
    switch (this) {
      case MealSlot.breakfast:
        return 'breakfast';
      case MealSlot.lunch:
        return 'lunch';
      case MealSlot.dinner:
        return 'dinner';
    }
  }

  String get label {
    switch (this) {
      case MealSlot.breakfast:
        return 'Breakfast';
      case MealSlot.lunch:
        return 'Lunch';
      case MealSlot.dinner:
        return 'Dinner';
    }
  }
}

MealSlot mealSlotFromValue(String value) {
  final String normalized = value.trim().toLowerCase();
  for (final MealSlot slot in kMealSlotOrder) {
    if (slot.value == normalized) {
      return slot;
    }
  }
  return MealSlot.dinner;
}

const List<MealSlot> kMealSlotOrder = <MealSlot>[
  MealSlot.breakfast,
  MealSlot.lunch,
  MealSlot.dinner,
];
