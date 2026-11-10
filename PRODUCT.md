# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Users

Two people only: a married couple, Bilal and his wife, who share a joint bank
account. Each uses Vault on their own iPhone. They open it to log money they
have just moved into savings, to see how much each of them has put in, and to
check how close they are to their goals.

There is no other audience. Vault is never shown to, or used by, anyone else.

## Product Purpose

One shared place where the couple can see their total savings, each
person's contribution, and progress toward named goals (for example a
vacation, a house deposit, an emergency fund). Success means both of them
trust the numbers, log deposits without effort, and feel a small sense of
achievement when a goal crosses a milestone.

## Positioning

Built for exactly two people and nothing else. There is no sign-up, sign-in,
password, invite code or account anywhere. The app knows two people and
remembers, per phone, which of them is holding it. It is a shared ledger of
intent between partners, not a banking app or a budgeting tool.

## Operating Context

- Deposits are **logged by hand**. After moving money into the joint
  account, one of them opens Vault and records the amount, date, goal, an
  optional note and who made it. Withdrawals are logged the same way.
- The person using the phone is the default "who made it".
- The two phones share one vault through **iCloud (CloudKit sharing)**
  between their two Apple IDs. This is the only sync mechanism and requires
  no Vault account.
- Each partner should be told when the other adds money ("Sara added $200 to
  Vacation") and when a goal reaches 25, 50, 75 or 100%.
- Home Screen widgets show the total saved, a goal's progress, and the
  latest deposit.

## Capabilities and Constraints

- Native iOS app in SwiftUI, iOS 17+, with WidgetKit widgets and Swift Charts.
- Currency is **US dollars**. Amounts are stored as integer cents and
  formatted through one helper.
- Core areas: first-launch setup (names, colour/avatar, whose phone),
  Dashboard, Add/edit deposit, History, Goals and goal detail, Insights,
  milestone celebrations, Settings, widgets, notifications.
- No bank connection or automatic import is planned.
- Current phase is design only: screens run on mock data, with no backend,
  networking or persistence yet. The code is structured so real data can be
  swapped in later.
- **Open:** the wife's real name. The mockups use "Sara" as a placeholder;
  the user said the real name is different but has not yet given it.

## Brand Commitments

- The name is **Vault**. It should feel secure, credible and premium, with a
  little celebration when goals are hit. It handles money, so it must never
  feel gimmicky.
- Mockups live in the "Vault app mockups" design canvas; earlier SwiftUI
  design-system code is on branch `claude/trusting-hopper-ajgqej`.

## Evidence on Hand

- No real savings data, goals or history exist yet. All figures in mockups
  are invented mock data and must stay labelled as such.
- No logo or icon files exist yet.

## Product Principles

1. **Two people, zero friction.** Nothing should ever ask who you are; the
   phone already knows.
2. **Trustworthy numbers first.** Totals, splits and progress must be
   unambiguous and consistent everywhere they appear.
3. **Fairness without scorekeeping.** Show who contributed what clearly, but
   frame it as "together", never as a competition.
4. **Celebrate milestones, stay calm otherwise.** Delight is reserved for
   real progress; everyday screens are quiet and precise.

## Accessibility & Inclusion

Required: full dark mode, Dynamic Type, VoiceOver labels on charts and
progress rings, minimum 44pt tap targets, and Reduce Motion support for every
animation.
