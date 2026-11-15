import SwiftUI

/// Initial inside a ring of the person's gradient (or filled, for pickers).
struct PersonAvatar: View {
    let person: Person
    var size: CGFloat = 40
    var filled = false

    var body: some View {
        ZStack {
            if filled {
                Circle().fill(person.color.gradient)
                Text(person.initial).foregroundStyle(Color(hex: 0x0E0F12))
            } else {
                Circle().fill(person.color.gradient)
                Circle().fill(VaultColor.card).padding(1.5)
                Text(person.initial).foregroundStyle(person.color.solid)
            }
        }
        .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(person.name)
    }
}

/// The overlapping pair shown top-left on Home.
struct AvatarPair: View {
    let people: [Person]
    var size: CGFloat = 32

    var body: some View {
        HStack(spacing: -size * 0.25) {
            ForEach(people) { PersonAvatar(person: $0, size: size) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(people.map(\.name).joined(separator: " and "))
    }
}

/// A selectable person chip (filters, "Added by").
struct PersonChip: View {
    let person: Person
    var title: String? = nil
    var selected: Bool

    var body: some View {
        HStack(spacing: 6) {
            PersonAvatar(person: person, size: 28, filled: true)
            Text(title ?? person.name)
        }
        .font(.subheadline.weight(selected ? .semibold : .regular))
        .foregroundStyle(selected ? VaultColor.textPrimary : VaultColor.textSecondary)
        .padding(.leading, 4)
        .padding(.trailing, 12)
        .frame(minHeight: 36)
        .background(selected ? person.color.solid.opacity(0.14) : VaultColor.raised, in: Capsule())
        .overlay(Capsule().strokeBorder(selected ? person.color.solid : VaultColor.hairline, lineWidth: selected ? 1.5 : 1))
        .contentShape(Capsule().inset(by: -4))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Plain text chip for filters.
struct FilterChip: View {
    let title: String
    var selected: Bool
    var trailingIcon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            if let trailingIcon { Image(systemName: trailingIcon).font(.caption.weight(.bold)) }
        }
        .font(.subheadline.weight(selected ? .semibold : .regular))
        .foregroundStyle(selected ? VaultColor.background : VaultColor.textPrimary)
        .padding(.horizontal, 14)
        .frame(minHeight: 36)
        .background(selected ? VaultColor.textPrimary : VaultColor.raised, in: Capsule())
        .contentShape(Capsule().inset(by: -4))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
