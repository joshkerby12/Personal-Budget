import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';

class CategoryService {
  const CategoryService(this._client);

  final SupabaseClient _client;

  Future<List<Category>> fetchCategories(String orgId) async {
    final List<dynamic> rows = await _client
        .from('categories')
        .select()
        .eq('org_id', orgId)
        .order('parent_category', ascending: true)
        .order('sort_order', ascending: true);

    return rows
        .cast<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList(growable: false);
  }

  Future<void> seedDefaultCategories(String orgId) async {
    final List<Map<String, dynamic>> rows = _defaultCategorySeed
        .map(
          (_CategorySeed row) => <String, dynamic>{
            'org_id': orgId,
            'parent_category': row.parentCategory,
            'subcategory': row.subcategory,
            'sort_order': row.sortOrder,
          },
        )
        .toList(growable: false);

    await _client
        .from('categories')
        .upsert(rows, onConflict: 'org_id,parent_category,subcategory');
  }
}

class _CategorySeed {
  const _CategorySeed(this.parentCategory, this.subcategory, this.sortOrder);

  final String parentCategory;
  final String subcategory;
  final int sortOrder;
}

const List<_CategorySeed> _defaultCategorySeed = <_CategorySeed>[
  _CategorySeed('Housing', 'Mortgage/Rent', 10),
  _CategorySeed('Housing', 'Property Tax', 20),
  _CategorySeed('Housing', 'HOA Fees', 30),
  _CategorySeed('Housing', 'Home Insurance', 40),
  _CategorySeed('Housing', 'Home Maintenance', 50),
  _CategorySeed('Housing', 'Utilities - Electric', 60),
  _CategorySeed('Housing', 'Utilities - Gas', 70),
  _CategorySeed('Housing', 'Utilities - Water', 80),
  _CategorySeed('Housing', 'Internet', 90),
  _CategorySeed('Housing', 'Phone', 100),
  _CategorySeed('Transportation', 'Car Payment', 10),
  _CategorySeed('Transportation', 'Car Insurance', 20),
  _CategorySeed('Transportation', 'Gas/Fuel', 30),
  _CategorySeed('Transportation', 'Car Maintenance', 40),
  _CategorySeed('Transportation', 'Parking/Tolls', 50),
  _CategorySeed('Transportation', 'Public Transit', 60),
  _CategorySeed('Food', 'Groceries', 10),
  _CategorySeed('Food', 'Dining Out', 20),
  _CategorySeed('Food', 'Coffee/Drinks', 30),
  _CategorySeed('Food', 'Takeout/Delivery', 40),
  _CategorySeed('Healthcare', 'Health Insurance', 10),
  _CategorySeed('Healthcare', 'Doctor/Dentist', 20),
  _CategorySeed('Healthcare', 'Prescriptions', 30),
  _CategorySeed('Healthcare', 'Vision', 40),
  _CategorySeed('Healthcare', 'Gym/Fitness', 50),
  _CategorySeed('Personal', 'Clothing', 10),
  _CategorySeed('Personal', 'Hair/Beauty', 20),
  _CategorySeed('Personal', 'Personal Care', 30),
  _CategorySeed('Personal', 'Subscriptions', 40),
  _CategorySeed('Personal', 'Entertainment', 50),
  _CategorySeed('Personal', 'Hobbies', 60),
  _CategorySeed('Children', 'Childcare/Daycare', 10),
  _CategorySeed('Children', 'School/Tuition', 20),
  _CategorySeed('Children', 'School Supplies', 30),
  _CategorySeed('Children', 'Activities/Sports', 40),
  _CategorySeed('Children', 'Toys/Clothing', 50),
  _CategorySeed('Savings', 'Emergency Fund', 10),
  _CategorySeed('Savings', 'Retirement', 20),
  _CategorySeed('Savings', 'Investments', 30),
  _CategorySeed('Savings', 'Vacation Fund', 40),
  _CategorySeed('Business', 'Office Supplies', 10),
  _CategorySeed('Business', 'Software/Tools', 20),
  _CategorySeed('Business', 'Marketing', 30),
  _CategorySeed('Business', 'Professional Services', 40),
  _CategorySeed('Business', 'Travel', 50),
  _CategorySeed('Business', 'Meals (Business)', 60),
  _CategorySeed('Business', 'Equipment', 70),
  _CategorySeed('Business', 'Other Business', 80),
  _CategorySeed('Debt', 'Credit Card', 10),
  _CategorySeed('Debt', 'Student Loan', 20),
  _CategorySeed('Debt', 'Personal Loan', 30),
  _CategorySeed('Debt', 'Other Debt', 40),
  _CategorySeed('Giving', 'Charitable Donations', 10),
  _CategorySeed('Giving', 'Church/Tithe', 20),
  _CategorySeed('Giving', 'Gifts', 30),
  _CategorySeed('Income', 'Salary/Wages', 10),
  _CategorySeed('Income', 'Freelance/Side Income', 20),
  _CategorySeed('Income', 'Rental Income', 30),
  _CategorySeed('Income', 'Investment Income', 40),
  _CategorySeed('Income', 'Other Income', 50),
  _CategorySeed('Other', 'Miscellaneous', 10),
];
