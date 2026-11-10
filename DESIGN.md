# Vault design reference

Vault is a shared savings tracker for two people. This document describes the
chosen visual direction and the design system the screens are built from.

## Status

| Step | State |
|---|---|
| 1. Design direction | Chosen: **Obsidian** |
| 2. Design system and gallery | Built (not yet compiled, see "Running it") |
| 3. Screens | Not started |

## Running it

The project file is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

    brew install xcodegen
    xcodegen generate
    open Vault.xcodeproj

To see the design system, open `Vault/DesignSystem/Gallery/DesignGalleryView.swift`
and use the canvas previews (Dark, Light, Large type), or run the app: for now
it launches straight into the gallery, with an appearance switch in the toolbar.

## Direction: Obsidian

Private-bank minimalism. Near-black surfaces, warm off-white text, and a single
champagne-gold accent. The two person colors are the only saturated hues, so
"who contributed what" is readable at a glance. Restrained by default, so
milestone celebrations stand out.

- **Icon concept:** a gold dial ring on black with a notch at 12 o'clock. The
  same ring is the app's progress ring.
- **Wordmark:** "VAULT" in wide-tracked semibold capitals.
- **Elevation:** soft, wide shadows in light mode; no shadows in dark mode,
  where a hairline border separates surfaces instead.

## Folder map

| Folder | Contents |
|---|---|
| `Vault/App` | App entry point |
| `Vault/Models` | Plain structs: `Person`, `Goal`, `Milestone`, `Deposit`, `ContributionShare` |
| `Vault/MockData` | The only source of mock data. Replace this to plug in real data |
| `Vault/Utilities` | `Money`, the single money-formatting helper |
| `Vault/DesignSystem/Tokens` | Colors, typography, spacing, radius, shadow, motion |
| `Vault/DesignSystem/Components` | Reusable views |
| `Vault/DesignSystem/Gallery` | The component gallery |

## Tokens

### Color (`VaultColor`)

| Token | Light | Dark | Use |
|---|---|---|---|
| `background` | `#F7F5F0` | `#0B0B0D` | Page background |
| `surface` | `#FFFFFF` | `#16161A` | Cards, sheets |
| `surfaceRaised` | `#EFECE4` | `#1F1F25` | Inputs, chips, secondary buttons |
| `border` | black 7% | white 8% | Hairline card border |
| `track` | black 8% | white 10% | Empty part of rings and bars |
| `primary` / `onPrimary` | `#121214` / `#F7F5F0` | `#F5F3EE` / `#0B0B0D` | Strong neutral fills |
| `accent` / `onAccent` | `#8A6D25` / `#FFFFFF` | `#D4B36A` / `#0B0B0D` | Gold: main actions, progress |
| `accentSoft` | gold 12% | gold 16% | Badge and highlight wash |
| `textPrimary` | `#121214` | `#F5F3EE` | |
| `textSecondary` | `#5C5B57` | `#A09E98` | |
| `textTertiary` | `#8E8C86` | `#6B6A66` | Placeholders and disabled only |
| `success` | `#2E8F58` | `#5FCB8B` | Deposits |
| `warning` | `#B0741A` | `#E8A94A` | |
| `danger` | `#C4472F` | `#F0705A` | Withdrawals, destructive actions |

Person colors (`PersonColor`, each with `.color` and `.softColor`):
teal, coral, lavender, sky, rose, sage. The defaults are teal and coral.

### Typography

- UI text: SF Pro via `VaultFont` (`largeTitle`, `title`, `headline`, `body`,
  `callout`, `subheadline`, `footnote`, `caption`, `overline`). All map to
  system text styles and scale with Dynamic Type.
- Money: SF Pro Rounded with monospaced digits via `.vaultMoney(_:)` or
  `MoneyText`. Sizes: `hero` 56, `large` 34, `medium` 22, `small` 17, each
  scaled with `@ScaledMetric` and allowed to shrink rather than wrap.

### Layout

- `VaultSpacing`: xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48, page margin 20, min tap target 44.
- `VaultRadius`: small 8, control 14, card 20, sheet 28. Always continuous corners.
- `VaultShadow`: `card`, `floating`, `none`. Apply with `.vaultShadow(_:)` or `.vaultSurface()`.
- `VaultMotion`: `standard` (state changes), `fill` (rings, bars, charts).

## Components

| Component | File | Notes |
|---|---|---|
| `VaultCard` | `VaultCard.swift` | Standard container |
| `.vaultPrimary`, `.vaultSecondary` (+ `Compact`) | `VaultButtons.swift` | Button styles, 52pt tall |
| `ProgressRing` | `ProgressRing.swift` | Animated fill, optional center content, VoiceOver label and value |
| `ProgressBar`, `ContributionSplitBar` | `ProgressBar.swift` | Linear progress; two-person split |
| `PersonAvatar`, `AvatarChip` | `AvatarChip.swift` | Emoji or initial on the person's color |
| `MilestoneBadge` | `MilestoneBadge.swift` | 25 / 50 / 75 / 100%, earned or locked |
| `GoalTile` | `GoalTile.swift` | Ring, saved of target, earned badges |
| `DepositRow` | `DepositRow.swift` | Signed amount; green deposit, red withdrawal |
| `SectionHeader` | `SectionHeader.swift` | Title with optional action |
| `EmptyStateView` | `EmptyStateView.swift` | Also used for error states |
| `StatTile` | `StatTile.swift` | Labelled figure |
| `VaultTextField`, `CurrencyInput` | `VaultInputs.swift` | Currency input fills from the right, in cents |

## Conventions

- **Money is integer cents.** Format only through `Money.format(cents:fraction:signed:)`.
- **Views take plain model structs**, never a data store, so a view model can
  feed them later without changes.
- **Derived values are passed in.** A goal's saved amount comes from deposits,
  so `GoalTile` takes `savedCents` rather than reading it from `Goal`.
- **Accessibility:** rings and bars expose a label and a percent value;
  animations check Reduce Motion; interactive elements are at least 44pt.
