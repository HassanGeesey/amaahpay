# Soft NeoBank Green Theme

## Overview

A modern fintech design system with soft neutrals and a fresh green accent. Focused on clarity, financial readability, and friendly interactions. Combines light surfaces with subtle shadows and rounded UI elements for a mobile-first banking experience.

## Design Philosophy

- **Soft neutral base**: Light grays and off-whites for calm financial UI
- **Single accent color**: Green for actions and highlights
- **Card-driven layout**: Information grouped into elevated containers
- **Friendly rounded UI**: Generous `rounded-2xl` (16px–20px)
- **Clear financial hierarchy**: Emphasis on balances and transactions
- **Subtle elevation**: Light shadows instead of heavy borders

## Color Palette

| Token | Value | Usage |
|-------|-------|-------|
| `--bg-primary` | `bg-stone-100` | App background |
| `--bg-card` | `bg-white` | Cards, panels |
| `--border` | `border-stone-200` | Dividers, subtle outlines |
| `--text-primary` | `text-stone-900` | Main text |
| `--text-secondary` | `text-stone-500` | Labels, metadata |
| `--text-muted` | `text-stone-400` | Hints, timestamps |
| `--accent` | `bg-lime-400` | Primary actions, highlights |
| `--accent-soft` | `bg-lime-100` | Soft highlight backgrounds |

### ⚠️ Controlled Status Colors

- Positive values: `text-green-500`
- Negative values: `text-red-500`
- Use sparingly, only for financial meaning (income vs expense)

## Typography

### Font Family
- **Primary**: System fonts (San Francisco / Inter style)

### Hierarchy

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Balance | `text-2xl` | `font-bold` | `text-stone-900` |
| Section Header | `text-lg` | `font-semibold` | `text-stone-900` |
| Card Title | `text-base` | `font-medium` | `text-stone-900` |
| Body Text | `text-sm` | `font-normal` | `text-stone-900` |
| Labels | `text-xs` | `font-medium` | `text-stone-500` |
| Captions | `text-xs` | `font-normal` | `text-stone-400` |

### Uppercase Labels
```css
text-xs font-medium text-stone-400 uppercase tracking-wide
```

## Spacing

### Page Layout

```css
min-h-screen bg-stone-100 p-4 pb-24
max-w-md mx-auto
```

### Card Spacing

```css
p-5 or p-6
gap-3
space-y-4
```

### Component Spacing

```css
py-3 px-4
p-3
mb-1
```

## Components

### Cards

```jsx
<div className="bg-white p-5 rounded-2xl shadow-sm border border-stone-100">
  {/* Content */}
</div>
```

### Buttons

**Primary (Green CTA)**

```jsx
<button className="bg-lime-400 text-stone-900 px-4 py-3 rounded-xl font-medium">
  Button Text
</button>
```

**Secondary (Soft)**

```jsx
<button className="bg-lime-100 text-lime-700 px-4 py-2 rounded-xl font-medium">
  Button Text
</button>
```

**Ghost**

```jsx
<button className="text-stone-500 hover:bg-stone-100 px-3 py-2 rounded-xl">
  Button Text
</button>
```

### Form Inputs

```jsx
<input
  className="w-full px-4 py-3 rounded-xl border border-stone-200
             bg-stone-50 focus:ring-2 focus:ring-lime-300 outline-none"
/>
```

### Keypad Button

```jsx
<button className="bg-stone-100 text-stone-900 rounded-xl py-4 text-lg font-medium">
  1
</button>
```

### Transaction Item

```jsx
<div className="flex items-center justify-between py-3">
  <div>
    <p className="text-sm font-medium text-stone-900">Name</p>
    <p className="text-xs text-stone-400">Date & Time</p>
  </div>
  <p className="text-sm font-medium text-green-500">+ $100</p>
</div>
```

### Avatar

```jsx
<div className="w-8 h-8 rounded-full bg-stone-200 flex items-center justify-center text-xs font-medium">
  AB
</div>
```

### Bottom Navigation

```jsx
<div className="fixed bottom-0 left-0 right-0 bg-white border-t border-stone-200 flex justify-around py-3">
  {/* Icons */}
</div>
```

## Layout Patterns

### Balance Card

```jsx
<div className="bg-white p-6 rounded-2xl shadow-sm">
  <p className="text-xs text-stone-500 mb-1">Available Balance</p>
  <h1 className="text-2xl font-bold text-stone-900">1,503.00</h1>
</div>
```

### Quick Actions Row

```jsx
<div className="flex justify-between">
  <button className="flex flex-col items-center gap-1 text-stone-500">
    <div className="p-3 bg-stone-100 rounded-xl">...</div>
    <span className="text-xs">Send</span>
  </button>
</div>
```

### Transaction List

```jsx
<div className="space-y-2">
  {/* Transaction items */}
</div>
```

### Amount Input Panel

```jsx
<div className="bg-white p-5 rounded-2xl">
  <input className="text-xl font-semibold w-full outline-none" />
</div>
```

## Icon Guidelines

### Style

- Rounded outline icons
- Soft stroke
- Minimal detail

### Colors

- Default: `text-stone-400`
- Active: `text-lime-500`
- Background: `bg-stone-100` or `bg-lime-100`

## Responsive Considerations

- **Mobile-first only**
- **Max width**: `max-w-md`
- **Touch targets**: Minimum 48px
- **Bottom nav spacing**: `pb-24`

## Design Notes

- Use **green only for actions and key highlights**
- Keep **financial data readable and uncluttered**
- Avoid heavy borders—prefer **soft shadows + spacing**
- Maintain **consistent rounded-2xl across UI**
- Ensure **clear contrast for money values**

## Before vs After

### Before (Harsh UI)

```jsx
<div className="bg-white border border-gray-300 rounded-md">
  <p className="text-green-700">+$100</p>
</div>
```

### After (Soft NeoBank)

```jsx
<div className="bg-white rounded-2xl shadow-sm p-5">
  <p className="text-green-500 font-medium">+ $100</p>
</div>
```

## Files Using This Theme

- `HomeScreen.tsx`
- `TransactionScreen.tsx`
- `TransferScreen.tsx`
- `Keypad.tsx`
- `BottomNav.tsx`
- `ProfileScreen.tsx`

## Build Output

1. Consistent green accent across actions
2. Soft rounded UI (`rounded-2xl`)
3. Clean card-based layout
4. Clear financial typography hierarchy
5. Minimal borders, soft shadows only