import SwiftUI

/// A person's round avatar: their emoji (or initial) on a wash of their color.
struct PersonAvatar: View {
    let person: Person
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle().fill(person.color.softColor)
            if person.avatar.isEmpty {
                Text(person.initial)
                    .font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
                    .foregroundStyle(person.color.color)
            } else {
                Text(person.avatar)
                    .font(.system(size: size * 0.5))
            }
        }
        .frame(width: size, height: size)
        .overlay(Circle().strokeBorder(person.color.color.opacity(0.5), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(person.name)
    }
}

/// Avatar plus name in a capsule. Used for "who made it" pickers and filters.
struct AvatarChip: View {
    let person: Person
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: VaultSpacing.sm) {
            PersonAvatar(person: person, size: 28)
                .accessibilityHidden(true)
            Text(person.name)
                .font(VaultFont.subheadline.weight(.medium))
                .foregroundStyle(VaultColor.textPrimary)
        }
        .padding(.leading, VaultSpacing.xs + 2)
        .padding(.trailing, VaultSpacing.md)
        .frame(minHeight: 40)
        .background(isSelected ? person.color.softColor : VaultColor.surfaceRaised, in: Capsule())
        .overlay(
            Capsule().strokeBorder(isSelected ? person.color.color : VaultColor.border,
                                   lineWidth: isSelected ? 1.5 : 1)
        )
        // The row is 40pt tall; extend the hit area to the 44pt minimum.
        .contentShape(Capsule().inset(by: -2))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
