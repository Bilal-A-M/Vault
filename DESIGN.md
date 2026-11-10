---
name: Vault
description: A shared savings tracker for two, finished like a black metal card.
colors:
  platinum: "#D9DDE3"
  platinum-bright: "#F5F6F8"
  platinum-deep: "#C6CBD3"
  on-platinum: "#0E0F12"
  vault-black: "#09090B"
  graphite-card: "#121215"
  graphite-raised: "#1C1C21"
  text-primary: "#F3F4F6"
  text-secondary: "#A3A7AE"
  text-tertiary: "#8B8F97"
  bilal-sky: "#8FD3E0"
  bilal-sky-deep: "#5B8FD9"
  hiba-rose: "#E9B3B9"
  hiba-rose-deep: "#C9789A"
  light-paper: "#F4F5F7"
  light-ink: "#141416"
  light-secondary: "#5A5F68"
  light-graphite: "#4A5260"
  system-green: "#30D158"
  system-red: "#FF453A"
typography:
  money-hero:
    fontFamily: "Sora, Inter, sans-serif"
    fontSize: "50px"
    fontWeight: 500
    lineHeight: 1.05
    letterSpacing: "-1.8px"
    fontFeature: "tnum"
  money-row:
    fontFamily: "Sora, Inter, sans-serif"
    fontSize: "17px"
    fontWeight: 500
    fontFeature: "tnum"
  large-title:
    fontFamily: "SF Pro Display, -apple-system, sans-serif"
    fontSize: "34px"
    fontWeight: 700
    lineHeight: 1.15
  title:
    fontFamily: "SF Pro Display, -apple-system, sans-serif"
    fontSize: "22px"
    fontWeight: 700
  headline:
    fontFamily: "SF Pro Text, -apple-system, sans-serif"
    fontSize: "17px"
    fontWeight: 600
  body:
    fontFamily: "SF Pro Text, -apple-system, sans-serif"
    fontSize: "17px"
    fontWeight: 400
  subhead:
    fontFamily: "SF Pro Text, -apple-system, sans-serif"
    fontSize: "15px"
    fontWeight: 400
  footnote:
    fontFamily: "SF Pro Text, -apple-system, sans-serif"
    fontSize: "13px"
    fontWeight: 400
  label:
    fontFamily: "SF Pro Text, -apple-system, sans-serif"
    fontSize: "11px"
    fontWeight: 500
rounded:
  tag: "6px"
  segmented: "9px"
  grouped-list: "12px"
  button: "15px"
  pill: "18px"
  card: "22px"
  hero: "26px"
  full: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  card: "18px"
  page: "20px"
  hero: "22px"
  section: "24px"
components:
  button-primary:
    backgroundColor: "{colors.platinum}"
    textColor: "{colors.on-platinum}"
    typography: "{typography.headline}"
    rounded: "{rounded.button}"
    height: "54px"
  button-icon-add:
    backgroundColor: "{colors.platinum}"
    textColor: "{colors.on-platinum}"
    rounded: "{rounded.full}"
    size: "36px"
  card:
    backgroundColor: "{colors.graphite-card}"
    rounded: "{rounded.card}"
    padding: "{spacing.card}"
  hero-card:
    backgroundColor: "{colors.graphite-card}"
    rounded: "{rounded.hero}"
    padding: "{spacing.hero}"
  list-row:
    backgroundColor: "{colors.graphite-card}"
    textColor: "{colors.text-primary}"
    typography: "{typography.body}"
    padding: "12px 0"
  chip:
    backgroundColor: "{colors.graphite-raised}"
    textColor: "{colors.text-primary}"
    typography: "{typography.subhead}"
    rounded: "{rounded.pill}"
    height: "36px"
  chip-selected:
    backgroundColor: "{colors.text-primary}"
    textColor: "{colors.vault-black}"
    rounded: "{rounded.pill}"
    height: "36px"
  milestone-badge:
    backgroundColor: "{colors.platinum}"
    textColor: "{colors.on-platinum}"
    typography: "{typography.footnote}"
    rounded: "{rounded.full}"
  tab-bar-item:
    textColor: "{colors.text-tertiary}"
    typography: "{typography.label}"
  tab-bar-item-selected:
    textColor: "{colors.text-primary}"
    typography: "{typography.label}"
---

# Design System: Vault

## Overview

**Creative North Star: "The Black Card"**

Vault is finished like a premium black metal card: brushed graphite, a fine
platinum edge, and nothing on it that does not need to be there. It is a
private ledger for two people, so the tone is calm, exact and quietly
confident. The interface is dark first, built from standard iPhone parts
(large titles, a labelled tab bar, grouped lists, segmented controls,
switches, swipe actions), and lets the material and the numbers carry the
character instead of decoration.

Colour is rationed. The app itself is black, white and platinum; the only
saturated colours belong to the two people who use it, sky for Bilal and rose
for Hiba, so who contributed what is readable at a glance. Moments of
progress (a milestone passed, a goal reached) are marked quietly in place and
celebrated in full only once.

Rejected along the way, by the user: champagne gold as the accent, ambient
colour glows, glass/frosted cards, gradient text, a custom floating tab bar,
and the vault-dial pattern inside the hero card.

**Key Characteristics:**
- Dark-first, near-black ground with graphite cards and hairline edges.
- One neutral accent (platinum) for actions and progress; graphite in light mode.
- Two person colours, used only for people and their data.
- Money set in Sora with tabular figures; everything else in SF Pro.
- Native iOS structure; brand lives in the material and the restraint.

## Colors

A cool, metallic neutral palette with one platinum accent and two soft person colours.

### Primary
- **Platinum** (`platinum`): the accent. Primary buttons, the filled add button, progress arcs on every ring and bar, chart lines, milestone badges and links. Primary buttons use a brushed gradient from **Bright Platinum** (`platinum-bright`) to **Deep Platinum** (`platinum-deep`). Text on platinum is **Ink** (`on-platinum`).

### Secondary
- **Bilal Sky** (`bilal-sky`, gradient to `bilal-sky-deep`): Bilal's avatar ring, his share of every split bar and stacked chart, his legend dot.
- **Hiba Rose** (`hiba-rose`, gradient to `hiba-rose-deep`): the same roles for Hiba. Users can pick other colours at setup (lavender, sage, coral, slate); these are the defaults.

### Neutral
- **Vault Black** (`vault-black`): screen background.
- **Graphite Card** (`graphite-card`): cards and list groups.
- **Raised Graphite** (`graphite-raised`): chips, inputs and grouped lists inside sheets.
- **Primary Text** (`text-primary`), **Secondary Text** (`text-secondary`), **Tertiary Text** (`text-tertiary`): titles and values; supporting lines and labels; tab labels and chart axes only. Tertiary is the floor; nothing dimmer carries text.
- Hairlines are white at 7% on cards and 10–12% for row separators and bars.
- **Light mode:** **Paper** (`light-paper`) ground, white cards, **Light Ink** (`light-ink`) text, **Light Secondary** (`light-secondary`), and **Light Graphite** (`light-graphite`) replacing platinum as the accent (platinum vanishes on white). The light primary button is a graphite gradient with white text.
- **System colours:** iOS green (`system-green`) for switches that are on, iOS red (`system-red`) for Delete only.

### Named Rules
**The Two Voices Rule.** Only Bilal and Hiba get colour. Goals, states and charts that are not about a person are platinum or neutral.

**The Platinum Is a Promise Rule.** Platinum means "you can act on this" or "this is progress". It never decorates.

**The No Gold, No Glow Rule.** No warm metallic accent, no coloured halos, no ambient colour blobs. A single faint neutral haze at the top of a screen is the maximum.

## Typography

**Display Font:** Sora (with Inter, then the system sans)
**Body Font:** SF Pro (the iOS system font)

**Character:** SF Pro keeps every screen native and readable under Dynamic Type; Sora's round geometric figures give money its own voice, so amounts never look like labels.

### Hierarchy
- **Money hero** (Sora 500, 50pt, -1.8pt tracking): the total on the Dashboard. Cents are dropped when zero.
- **Large title** (SF Pro 700, 34pt): the top of each tab ("Hi, Bilal", "Goals", "History").
- **Title** (SF Pro 700, 22pt): section headers ("Goals", "Recent activity").
- **Headline** (SF Pro 600, 17pt): card titles, buttons, navigation titles.
- **Body** (SF Pro 400, 17pt): list rows and settings rows.
- **Subhead** (SF Pro 400, 15pt): labels above figures, links, chips.
- **Footnote** (SF Pro 400, 13pt): row subtitles, sync status, section labels.
- **Label** (SF Pro 500, 11pt): tab bar labels only; 700 when selected.
- **Money in rows** (Sora 500, 17pt, tabular): every amount outside the hero.

### Named Rules
**The Money Has Its Own Voice Rule.** Every dollar figure uses Sora with tabular figures; nothing else does.

**The 11pt Floor Rule.** No text below 11pt, and 11pt is reserved for tab labels.

## Layout

A single-column iPhone layout at 390pt wide with a 20pt page margin. Sections are separated by 24pt; cards pad 18pt (the hero 22pt); list rows are at least 44pt tall with 12pt vertical padding. Top-level tabs open with a 34pt large title that collapses to an inline title on scroll. The Goals row on the Dashboard is a horizontal scroller with 156pt cards that bleed off the right edge to signal more. A standard tab bar sits at the bottom with a translucent system material behind it.

## Elevation & Depth

Depth comes from tonal layering (black ground, graphite cards, raised graphite controls) and hairline edges, not from shadows. The one exception is the hero card, which is treated as a physical object.

### Shadow Vocabulary
- **Hero card** (`inset 0 1px 0 rgba(255,255,255,.16), inset 0 -1px 0 rgba(0,0,0,.6), 0 30px 50px -24px rgba(0,0,0,1)`): a bright top edge, a dark lower edge and a long soft drop, so the card reads as a slab of metal.
- **Primary button** (`inset 0 1px 0 rgba(255,255,255,.6), 0 8px 18px -10px rgba(0,0,0,.9)`): a lit top bevel on the platinum gradient.

### The Black Card material (build notes)
The hero card is three layers, top to bottom: a diagonal sheen (`linear-gradient(118deg, transparent 28%, white 5.5% at 44%, transparent 58%)`), a faint horizontal brushed grain (1pt lines at about 1.4% white every 3pt), and a base gradient from `#1D1E23` to `#0F1013`. The grain is too faint to survive on a real display: in SwiftUI, rely on the sheen gradient and the 1pt top highlight, and add a subtle noise image only if testing on device shows the card reading as flat. In light mode the same card is brushed silver (`#FBFBFC` to `#E6E8EC` with a white sheen).

### Named Rules
**The One Object Rule.** Only the hero card gets material and a drop shadow. Every other surface is flat graphite.

## Shapes

Soft, continuous corners throughout, larger for bigger surfaces: 26pt for the hero card, 22pt for cards, 15pt for primary buttons, 12pt for grouped lists, 9pt for segmented controls, and full pills for chips, badges and the add button. Progress is always a ring with round caps, drawn clockwise from 12 o'clock, on a 7% white track. Avatars are circles with a 1.5pt gradient ring in the person's colour.

## Components

### Buttons
- **Shape:** gently rounded (15pt), 54pt tall, full width.
- **Primary:** brushed platinum gradient with ink text and a plus icon where it adds; one per screen.
- **Add (icon):** a 36pt filled platinum circle with an ink plus. Appears in the navigation bar only after the hero card has scrolled away, so the screen never shows two add buttons at once.
- **Text buttons and links:** platinum, 600 weight, with a chevron when they navigate ("See all 4 ›").

### Chips
- **Style:** raised graphite pills, 36pt tall; person chips lead with a 28pt avatar.
- **State:** the selected chip inverts to primary text on a white fill.

### Cards / Containers
- **Corner Style:** 22pt (hero 26pt).
- **Background:** graphite card with a 7% white hairline.
- **Shadow Strategy:** none, except the hero card (see Elevation & Depth).
- **Internal Padding:** 18pt (hero 22pt).

### Inputs / Fields
- **Style:** grouped list rows on raised graphite, label left and value right, as in iOS Settings. The amount field is a centred Sora number at 64pt with quick +$50 / +$100 / +$500 chips.
- **Focus:** a 1.5pt platinum border on text fields.
- **Segmented controls:** the standard iOS style (grey track, lifted grey thumb) for Deposit/Withdrawal, time ranges and appearance.

### Navigation
- **Tab bar:** five labelled tabs (Home, History, Goals, Insights, Settings) on a translucent material with a top hairline. Unselected items are tertiary grey; the selected one is white, with a filled icon and a bold label.
- **Navigation bar:** large title at rest; inline title plus the add button once scrolled. Back buttons are the standard chevron and the previous title.

### Activity row (signature)
A 40pt person avatar, a 17pt title, a 13pt subtitle (who · when · goal), and the amount in Sora on the right. Deposits show "+$200"; withdrawals show "−$125.50" in the same colour, with "Withdrawal from …" in the subtitle. A deposit from the other person since you last opened the app carries an outlined "New" tag, and its subtitle states the effect ("Vacation passed 75%").

### Milestone badge (signature)
A platinum pill with a star and the percentage ("★ 75%"), shown on a goal card until the new milestone has been seen. Earned milestones on goal screens are tinted platinum pills; unearned ones are outlined.

## Do's and Don'ts

### Do:
- **Do** keep the accent platinum (`#D9DDE3`) in dark mode and graphite (`#4A5260`) in light mode.
- **Do** use the standard iOS tab bar, grouped lists, segmented controls, switches and swipe actions.
- **Do** set every amount in Sora with tabular figures, and drop ".00" on whole-dollar totals.
- **Do** show sync status ("Synced with Hiba · just now") wherever totals appear, and design the empty, can't-sync and loading states.
- **Do** mark a crossed milestone quietly in place, and save the full celebration for the first time it happens.

### Don't:
- **Don't** use gold or any warm metallic accent.
- **Don't** add ambient colour glows, glow filters, glass/frosted cards or gradient text.
- **Don't** bring back the vault-dial pattern inside the hero card; the dial lives only in the logo, widgets and notification icon.
- **Don't** give goals their own colours; goals are told apart by icon.
- **Don't** show two add buttons at the same time, or put a custom floating tab bar in place of the system one.

## Code map

The mockups for every screen live in `mockups/` (open them on the design canvas). The SwiftUI project in `Vault/` was written earlier, before the redesign: its tokens in `Vault/DesignSystem/Tokens` still use the old gold accent and must be updated to this file when the coding phase starts.

| Folder | Contents |
|---|---|
| `Vault/App` | App entry point |
| `Vault/Models` | `Person`, `Goal`, `Milestone`, `Deposit`, `ContributionShare` |
| `Vault/MockData` | The only source of mock data |
| `Vault/Utilities` | `Money`, the single money-formatting helper (integer cents) |
| `Vault/DesignSystem` | Tokens, components and the component gallery (pre-redesign) |
| `mockups/` | The 18 screen mockups this file was derived from |
