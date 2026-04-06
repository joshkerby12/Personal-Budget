class PantryCategoryMeta {
  const PantryCategoryMeta({
    required this.key,
    required this.label,
    required this.emoji,
  });

  final String key;
  final String label;
  final String emoji;
}

const List<String> kPantryCategoryOrder = <String>[
  'produce',
  'meat',
  'dairy',
  'bakery',
  'pantry',
  'frozen',
  'beverages',
  'snacks',
  'household',
  'personal',
  'other',
];

const Map<String, PantryCategoryMeta>
kPantryCategories = <String, PantryCategoryMeta>{
  'produce': PantryCategoryMeta(key: 'produce', label: 'Produce', emoji: '🥬'),
  'meat': PantryCategoryMeta(key: 'meat', label: 'Meat & Seafood', emoji: '🥩'),
  'dairy': PantryCategoryMeta(key: 'dairy', label: 'Dairy & Eggs', emoji: '🥛'),
  'bakery': PantryCategoryMeta(key: 'bakery', label: 'Bakery', emoji: '🍞'),
  'pantry': PantryCategoryMeta(key: 'pantry', label: 'Pantry', emoji: '🫙'),
  'frozen': PantryCategoryMeta(key: 'frozen', label: 'Frozen', emoji: '🧊'),
  'beverages': PantryCategoryMeta(
    key: 'beverages',
    label: 'Beverages',
    emoji: '🧃',
  ),
  'snacks': PantryCategoryMeta(key: 'snacks', label: 'Snacks', emoji: '🍿'),
  'household': PantryCategoryMeta(
    key: 'household',
    label: 'Household',
    emoji: '🧹',
  ),
  'personal': PantryCategoryMeta(
    key: 'personal',
    label: 'Personal Care',
    emoji: '🧴',
  ),
  'other': PantryCategoryMeta(key: 'other', label: 'Other', emoji: '📦'),
};

const Map<String, List<String>> _categoryKeywords = <String, List<String>>{
  'produce': <String>[
    'apple',
    'banana',
    'onion',
    'garlic',
    'potato',
    'lemon',
    'lime',
    'carrot',
    'celery',
    'tomato',
    'lettuce',
    'spinach',
    'kale',
    'broccoli',
    'cucumber',
    'pepper',
    'avocado',
    'zucchini',
    'mushroom',
    'ginger',
  ],
  'meat': <String>[
    'chicken',
    'beef',
    'pork',
    'salmon',
    'tuna',
    'shrimp',
    'turkey',
    'lamb',
    'bacon',
    'sausage',
    'ground beef',
    'steak',
    'tilapia',
    'cod',
  ],
  'dairy': <String>[
    'milk',
    'butter',
    'cheese',
    'yogurt',
    'cream',
    'eggs',
    'sour cream',
    'cream cheese',
    'parmesan',
    'mozzarella',
    'cheddar',
    'heavy cream',
  ],
  'bakery': <String>[
    'bread',
    'bagel',
    'muffin',
    'croissant',
    'tortilla',
    'pita',
    'roll',
    'baguette',
  ],
  'pantry': <String>[
    'flour',
    'sugar',
    'salt',
    'pepper',
    'oil',
    'olive oil',
    'vinegar',
    'soy sauce',
    'pasta',
    'rice',
    'beans',
    'lentils',
    'oats',
    'cereal',
    'coffee',
    'tea',
    'honey',
    'maple syrup',
    'ketchup',
    'mustard',
    'mayo',
    'sriracha',
    'hot sauce',
    'broth',
    'stock',
    'canned',
    'tomato sauce',
    'coconut milk',
    'breadcrumbs',
    'cornstarch',
    'baking powder',
    'baking soda',
    'vanilla',
    'cocoa',
    'chocolate chips',
    'peanut butter',
    'jam',
  ],
  'frozen': <String>['frozen', 'ice cream', 'edamame', 'peas', 'corn'],
  'beverages': <String>[
    'juice',
    'water',
    'soda',
    'wine',
    'beer',
    'sparkling',
    'kombucha',
    'almond milk',
    'oat milk',
  ],
  'snacks': <String>[
    'chips',
    'crackers',
    'popcorn',
    'nuts',
    'almonds',
    'cashews',
    'granola',
    'trail mix',
    'pretzels',
    'cookies',
    'candy',
  ],
  'household': <String>[
    'paper towel',
    'toilet paper',
    'dish soap',
    'laundry',
    'trash bag',
    'sponge',
    'cleaning',
    'bleach',
    'detergent',
  ],
  'personal': <String>[
    'shampoo',
    'conditioner',
    'soap',
    'toothpaste',
    'deodorant',
    'lotion',
    'razor',
    'floss',
  ],
};

const List<String> kCommonPantryItems = <String>[
  'flour',
  'sugar',
  'olive oil',
  'rice',
  'pasta',
  'canned tomatoes',
  'chicken broth',
  'eggs',
  'butter',
  'milk',
  'garlic',
  'onion',
  'salt',
  'pepper',
  'soy sauce',
  'hot sauce',
  'vinegar',
  'breadcrumbs',
  'oats',
  'honey',
  'peanut butter',
  'jam',
  'coffee',
  'tea',
  'beans',
];

String categorizePantryItem(String name) {
  final String lower = name.toLowerCase();
  for (final String key in kPantryCategoryOrder) {
    final List<String>? keywords = _categoryKeywords[key];
    if (keywords == null) {
      continue;
    }
    if (keywords.any(lower.contains)) {
      return key;
    }
  }
  return 'other';
}

String pantryCategoryLabel(String key) {
  return kPantryCategories[key]?.label ?? kPantryCategories['other']!.label;
}

String pantryCategoryEmoji(String key) {
  return kPantryCategories[key]?.emoji ?? kPantryCategories['other']!.emoji;
}

String normalizePantryName(String value) => value.trim().toLowerCase();
