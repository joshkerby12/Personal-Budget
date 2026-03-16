# [Feature] Spec

## Overview
What this feature does and its role in the app.

## Scope
What is included. What is explicitly out of scope.

## User Stories
- As a [role], I can [action] so that [outcome]

## Org/User Context
- Data scoping: all records scoped to `org_id`
- Role access: who can read / write / delete

## Page States
Each page in this feature can be in these states:
- Loading
- Loaded
- Empty
- Error
- Editing (if applicable)

## UI Behavior
- What the user sees in each state
- Interactions and expected responses
- Validation rules
- Edge cases

## Layouts
- **Mobile** — description of mobile-specific layout (< 600px)
- **Tablet** — description of tablet-specific layout (600–1200px)
- **Web** — description of web/desktop-specific layout (> 1200px)

## Data
- What data this feature reads
- What data this feature writes
- Supabase tables involved (ref: `docs/data_structure.md`)

## Edge Cases & Rules
- List any non-obvious rules or constraints

## Open Questions
- Unresolved decisions that need director input before implementation

---

## Code Map

### Functions
- [Plain English concept] → [file path] → `functionName()`
- Example: Calculate line item subtotal → `helpers/budget_calculations.dart` → `calculateLineItemSubtotal()`

### Key Files
- Provider → `lib/features/[feature]/[page]_provider.dart`
- Layout router → `lib/features/[feature]/[page]_screen.dart`
- Mobile → `lib/features/[feature]/layouts/mobile/[page]_screen_mobile.dart`
- Tablet → `lib/features/[feature]/layouts/tablet/[page]_screen_tablet.dart`
- Web → `lib/features/[feature]/layouts/web/[page]_screen_web.dart`

> Update the Code Map whenever a function is added, moved, or renamed.
