# Vault

A shared savings tracker for two people, built in SwiftUI for iOS 26.
Design reference: [DESIGN.md](DESIGN.md) · Product context: [PRODUCT.md](PRODUCT.md) ·
Screen mockups: `mockups/` (open on the design canvas).

## Current state

Every screen runs on **mock data** (in memory). Nothing is saved between
launches and there is no sync yet. Next steps: local storage (Core Data), then
iCloud sharing between two Apple IDs.

## Run it on your iPhone

You need a Mac with **Xcode 26** and your normal Apple ID (a free account is
enough for now).

1. Install XcodeGen once: `brew install xcodegen`
2. In this folder: `xcodegen generate`, then `open Vault.xcodeproj`
3. In Xcode, select the **Vault** target → *Signing & Capabilities* → tick
   *Automatically manage signing* and pick your Apple ID as the Team. Do the
   same for the **VaultWidgets** target. If Xcode says a bundle ID is taken,
   change `com.vault.app` in `project.yml` to something unique, e.g.
   `com.yourname.vault`, and run `xcodegen generate` again.
4. Plug in your iPhone, pick it as the run destination, press **Run** (⌘R).
   The first time, the iPhone asks you to trust the developer: Settings →
   General → VPN & Device Management.

With a free Apple ID, apps stop opening after 7 days; press Run again to
refresh. Optional: add the Sora font (see `Vault/Resources/Fonts/README.md`).

## Jump to any screen or state

Settings (top-right on Home) → **Preview & debug**: switch mock data
(populated, near a milestone, sparse, empty, first launch), simulate "can't
sync" and loading, show each milestone celebration, open the notification
previews and permission prompt, open the design-system gallery, or replay
first-launch setup.

Tip: with **Near a milestone** selected, add $20 or more to Vacation to see the
75% celebration triggered for real.

## Code map

| Folder | Contents |
|---|---|
| `Vault/App` | App entry, root view, floating tab bar, router |
| `Vault/Models` | `Person`, `Goal`, `Entry`, `Milestone`, preferences |
| `Vault/Domain` | `VaultMath`: every total, progress, split and milestone |
| `Vault/Data` | `VaultStore` (what screens read) and `VaultPersistence` (swap point for real storage) |
| `Vault/MockData` | The only source of mock data, plus debug scenarios |
| `Vault/DesignSystem` | Tokens (colour, type, layout) and shared components |
| `Vault/Features` | One folder per screen |
| `VaultWidgets` | Home Screen widgets (mock data for now) |
