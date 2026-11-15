import SwiftUI
import UIKit

// MARK: - "The Black Card" colour tokens (see DESIGN.md)
//
// Three colours mean something: sky is Bilal, rose is Hiba, lime is progress.
// Platinum is for actions. Everything else is black, graphite and grey.
// Shared with the widget extension, so keep this file free of app-only types.

enum VaultColor {
    // Surfaces
    static let background = Color(light: 0xF4F5F7, dark: 0x09090B)
    static let card = Color(light: 0xFFFFFF, dark: 0x121215)
    static let raised = Color(light: 0xECEEF1, dark: 0x1C1C21)
    static let hairline = Color(light: Color.black.opacity(0.07), dark: Color.white.opacity(0.07))
    static let separator = Color(light: Color.black.opacity(0.10), dark: Color.white.opacity(0.10))
    static let track = Color(light: Color.black.opacity(0.08), dark: Color.white.opacity(0.08))

    // Text
    static let textPrimary = Color(light: 0x141416, dark: 0xF3F4F6)
    static let textSecondary = Color(light: 0x5A5F68, dark: 0xA3A7AE)
    static let textTertiary = Color(light: 0x6B7079, dark: 0x8B8F97)

    // Action accent: platinum in dark mode, graphite in light mode.
    static let accent = Color(light: 0x4A5260, dark: 0xD9DDE3)
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x0E0F12)
    static let accentTop = Color(light: 0x2C3038, dark: 0xF5F6F8)
    static let accentBottom = Color(light: 0x16181C, dark: 0xC6CBD3)

    // Progress: electric lime in dark mode; deep olive in light mode, because
    // lime fails contrast on white.
    static let progress = Color(light: 0x5E8C0F, dark: 0xC8F06A)
    static let onProgress = Color(light: 0xFFFFFF, dark: 0x0E0F12)

    // The black metal hero card (same in both modes).
    static let metalTop = Color(hex: 0x3A3D44)
    static let metalMid = Color(hex: 0x282A30)
    static let metalBottom = Color(hex: 0x1D1F23)
    static let metalStrip = Color(hex: 0x141519)
    static let metalLabel = Color(hex: 0xD5D8DE)

    // System
    static let destructive = Color(hex: 0xFF453A)
}

extension PersonColor {
    /// Light end of the person's gradient (dark mode text, dots, bars).
    var light: Color {
        switch self {
        case .sky: Color(hex: 0x8FD3E0)
        case .rose: Color(hex: 0xE9B3B9)
        case .lavender: Color(hex: 0xC9C1EC)
        case .sage: Color(hex: 0xC3D8B2)
        case .coral: Color(hex: 0xF2C0A8)
        case .slate: Color(hex: 0xC4C9D2)
        }
    }

    /// Deep end of the gradient.
    var deep: Color {
        switch self {
        case .sky: Color(hex: 0x5B8FD9)
        case .rose: Color(hex: 0xC9789A)
        case .lavender: Color(hex: 0x8F82CF)
        case .sage: Color(hex: 0x82A96E)
        case .coral: Color(hex: 0xD98767)
        case .slate: Color(hex: 0x7F8796)
        }
    }

    /// The single colour used for charts and dots: light in dark mode, deep in light mode.
    var solid: Color { Color(light: deep, dark: light) }

    var gradient: LinearGradient {
        LinearGradient(colors: [light, deep], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Helpers

extension Color {
    /// A colour that resolves differently in light and dark mode.
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
