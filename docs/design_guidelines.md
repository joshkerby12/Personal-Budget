# Design Guidelines

> Every agent references this before building any UI. These rules apply to all layouts: mobile, tablet, and web.

---

## Typography

System fonts only — no custom fonts loaded.

```dart
fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif'
```

Flutter equivalent: `ThemeData` with no custom `fontFamily` set → uses platform default.

| Role | Size | Weight |
|---|---|---|
| Page title | 22px | Bold (700) |
| Card title | 15px | Bold (700) |
| Body | 14px | Regular (400) |
| Label / caption | 11–12px | SemiBold (600) |
| Amount (large) | 24px | Bold (700) |

---

## Color Palette

Carried forward from the existing HTML prototype.

```dart
// AppColors
navy        = #1F3864   // primary brand, headers, page titles
teal        = #2E75B6   // primary action, active states, links
tealLight   = #D6E4F0   // teal tinted backgrounds, hover states
green       = #1E8449   // income, positive, success
greenFill   = #D5F5E3   // green tinted background
amber       = #D4AC0D   // warnings, net/savings indicators
amberFill   = #FEF9E7   // amber tinted background
red         = #C0392B   // expenses, negative, error, over-budget
redFill     = #FADBD8   // red tinted background
white       = #FFFFFF
lightGray   = #F5F7FA   // page background
midGray     = #E8ECF0   // dividers, borders, card separators
text        = #2C3E50   // primary text
textMuted   = #7F8C8D   // secondary text, labels, captions
border      = #D5DCE6   // input borders, card borders
```

Semantic use:
- Income amounts → green
- Expense amounts → red
- Net positive → green, net negative → red
- Amber → warnings, budget alerts
- Navy → headers, page titles, nav backgrounds
- Teal → primary buttons, active nav items, links

---

## Spacing

Base unit: **4px**

| Token | Value |
|---|---|
| xs | 4px |
| sm | 8px |
| md | 12px |
| lg | 16px |
| xl | 20px |
| xxl | 24px |
| page padding | 16px (mobile), 24px (desktop) |

---

## Component Rules

### Buttons
- Primary: teal background, white text, 6px radius, 8–16px padding
- Ghost: transparent, teal border (1.5px), teal text
- Danger: red background, white text
- All buttons: 13px, SemiBold (600)
- Small buttons: 5–10px padding, 12px font

### Inputs / Form Fields
- Border: `border` color (#D5DCE6), 6px radius
- Focus: teal border
- Error state: red border + red helper text below
- Label above field, 11–12px SemiBold, uppercase, letter-spacing 0.5px

### Cards
- White background, 8px radius, subtle shadow (`0 2px 8px rgba(31,56,100,.12)`)
- 20px internal padding
- Card title: 15px Bold, navy

### Summary / Stat Cards
- Left accent border (4px) colored by semantic type (green=income, teal=expense, amber=net)
- Large amount: 24px Bold, navy (or green/red if signed)
- Sub-label: 11px muted

### Navigation
- **Mobile** (< 600px): bottom navigation bar, white background, teal for active item
- **Desktop** (> 1200px): horizontal tab bar, navy background, white text, teal underline for active tab
- FAB for primary action on mobile (add transaction)

### Bottom Sheets vs Dialogs
- Always prefer bottom sheets over dialogs for forms and confirmations on mobile
- On desktop, use dialogs only for destructive confirmations; use inline panels for forms

---

## Layout Rules

| Breakpoint | Width | Layout |
|---|---|---|
| Mobile | < 600px | Single column, bottom nav, full-width cards |
| Tablet | 600–1200px | Two-column where appropriate, bottom nav |
| Desktop | > 1200px | Max content width 1400px, centered, horizontal tab nav |

Page padding: 16px mobile, 24px desktop. Never let content touch screen edges.

---

## Navigation Patterns

- **Mobile:** `BottomNavigationBar` — 5 tabs max: Dashboard, Transactions, Budget, Reports, Receipts
- **Desktop:** Horizontal tab row below header — same tabs
- FAB on mobile for "Add Transaction" action
- No drawer navigation

---

## Animations

Keep transitions minimal and fast:
- Page transitions: fade or slide, 200ms max
- Button press: 150ms color transition only
- No bouncing, no excessive spring animations
- Charts may animate on first load but must complete within 400ms

---

## Tone and Copy

- Friendly, plain English — no jargon
- Labels: Title Case for nav items and card titles; Sentence case for body copy and helper text
- Error messages: tell the user what to do, not just what went wrong
  - Bad: "Invalid input"
  - Good: "Please enter an amount greater than zero"
- Empty states: always explain what goes here and how to add the first item

---

## Do / Don't

| Do | Don't |
|---|---|
| Use bottom sheets for forms on mobile | Use dialogs for forms |
| Use left accent border on stat cards | Use heavy backgrounds on every card |
| Use semantic colors consistently (green=income, red=expense) | Mix semantic colors arbitrarily |
| Keep layouts data-dense but approachable | Bury numbers in unnecessary whitespace |
| Show clear empty states | Leave blank white space with no explanation |
| Highlight over-budget categories in red | Use only text to indicate budget status |

---

## Reference Apps

- **Existing HTML prototype** (`budget_app.html`, `budget_mobile.html`) — carry forward the color palette, card structure, and tab navigation patterns
- Feel: friendly and approachable, not sterile/corporate, but also not toy-like

---

## Maintenance Rule

Update this file whenever the director expresses a new UI preference, approves a pattern, or rejects something. It is a living document.
