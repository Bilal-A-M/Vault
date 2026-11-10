import SwiftUI
import UIKit

// MARK: - Obsidian color tokens
//
// Direction: near-black surfaces, warm off-white text, one champagne-gold accent.
// The two person colors are the only saturated hues in the app, so "who
// contributed what" always reads at a glance.
//
// Colors are defined in code (not an asset catalog) so the same file can be
// shared with the widget extension and every token has its light + dark value
// side by side.

enum VaultColor {
    // Surfaces
    /// Page background.
    static let background = Color(light: 0xF7F5F0, dark: 0x0B0B0D)
    /// Cards and sheets.
    static let surface = Color(light: 0xFFFFFF, dark: 0x16161A)
    /// Controls sitting on a surface: inputs, chips, secondary buttons.
    static let surfaceRaised = Color(light: 0xEFECE4, dark: 0x1F1F25)
    /// Hairline card border. In dark mode this replaces shadows.
    static let border = Color(light: Color.black.opacity(0.07), dark: Color.white.opacity(0.08))
    /// Empty part of progress rings and bars.
    static let track = Color(light: Color.black.opacity(0.08), dark: Color.white.opacity(0.10))

    // Brand
    /// "Ink": the strongest neutral, for high-emphasis fills that are not gold.
    static let primary = Color(light: 0x121214, dark: 0xF5F3EE)
    /// Text/icons placed on `primary`.
    static let onPrimary = Color(light: 0xF7F5F0, dark: 0x0B0B0D)
    /// Champagne gold. Darkened in light mode so white text on it passes 4.5:1.
    static let accent = Color(light: 0x8A6D25, dark: 0xD4B36A)
    /// Text/icons placed on `accent`.
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x0B0B0D)
    /// Tinted gold wash for badges and highlights.
    static let accentSoft = Color(light: Color(hex: 0x8A6D25, opacity: 0.12),
                                  dark: Color(hex: 0xD4B36A, opacity: 0.16))

    // Text
    static let textPrimary = Color(light: 0x121214, dark: 0xF5F3EE)
    static let textSecondary = Color(light: 0x5C5B57, dark: 0xA09E98)
    /// Low emphasis only (placeholders, disabled, decorative). Not for body copy.
    static let textTertiary = Color(light: 0x8E8C86, dark: 0x6B6A66)

    // Semantic
    static let success = Color(light: 0x2E8F58, dark: 0x5FCB8B)
    static let warning = Color(light: 0xB0741A, dark: 0xE8A94A)
    /// Withdrawals and destructive actions.
    static let danger = Color(light: 0xC4472F, dark: 0xF0705A)
}

// MARK: - Person colors

extension PersonColor {
    /// The solid color for this person: avatars, chart series, split bars.
    var color: Color {
        switch self {
        case .teal: Color(light: 0x1F9E8C, dark: 0x4FC3B0)
        case .coral: Color(light: 0xD9603F, dark: 0xF0866B)
        case .lavender: Color(light: 0x7765D6, dark: 0xA698F5)
        case .sky: Color(light: 0x2F86D1, dark: 0x6DB6F2)
        case .rose: Color(light: 0xC94A7C, dark: 0xEE86AE)
        case .sage: Color(light: 0x5E8F4A, dark: 0x9CC98A)
        }
    }

    /// A quiet wash of the color, for avatar backgrounds and selected chips.
    var softColor: Color { color.opacity(0.18) }
}

// MARK: - Helpers

extension Color {
    /// A color that resolves differently in light and dark mode.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    init(light: UInt32, dark: UInt32) {
        self.init(light: Color(hex: light), dark: Color(hex: dark))
    }

    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}
