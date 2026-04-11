alter table pantry_meal_plan
  add column meal_slot text not null default 'dinner'
  check (meal_slot in ('breakfast', 'lunch', 'dinner'));
