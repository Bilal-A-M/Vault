import SwiftUI

/// First launch, three quick steps: welcome → the two of you → whose phone.
/// No accounts: the names and colours are all the app needs.
struct OnboardingView: View {
    @Environment(VaultStore.self) private var store

    enum Step: Int { case welcome, people, owner }
    @State private var step: Step = .welcome
    @State private var firstName = ""
    @State private var secondName = ""
    @State private var firstColor: PersonColor = .sky
    @State private var secondColor: PersonColor = .rose
    @State private var ownerIndex: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var people: [Person] {
        [Person(name: firstName.trimmingCharacters(in: .whitespaces), color: firstColor),
         Person(name: secondName.trimmingCharacters(in: .whitespaces), color: secondColor)]
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch step {
                case .welcome: welcome
                case .people: peopleStep
                case .owner: ownerStep
                }
            }
            .frame(maxHeight: .infinity)
            .transition(reduceMotion ? .opacity : .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                              removal: .move(edge: .leading).combined(with: .opacity)))

            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Capsule()
                        .fill(index == step.rawValue ? VaultColor.accent : VaultColor.separator)
                        .frame(width: index == step.rawValue ? 20 : 6, height: 6)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Step \(step.rawValue + 1) of 3")
            .padding(.vertical, 18)

            footerButton
        }
        .padding(.horizontal, VaultSpace.page)
        .padding(.bottom, 12)
        .background(VaultColor.background.ignoresSafeArea())
        .animation(reduceMotion ? nil : .snappy, value: step)
    }

    // MARK: Steps

    private var welcome: some View {
        VStack(spacing: 36) {
            VaultDial().frame(width: 190, height: 190)
            VStack(spacing: 14) {
                Text("VAULT")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .tracking(11)
                    .foregroundStyle(VaultColor.textPrimary)
                Text("One place for the two of you to see what you've saved, and how close your goals are.")
                    .font(.body).foregroundStyle(VaultColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            Text("No sign-up and no passwords. Just the two of you.")
                .font(.footnote).foregroundStyle(VaultColor.textSecondary)
        }
    }

    private var peopleStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Who's saving?").font(.largeTitle.bold())
                    Text("Add both names and pick a colour for each of you.")
                        .foregroundStyle(VaultColor.textSecondary)
                }
                personCard(label: "First person", name: $firstName, color: $firstColor, other: secondColor)
                personCard(label: "Second person", name: $secondName, color: $secondColor, other: firstColor)
            }
            .foregroundStyle(VaultColor.textPrimary)
            .padding(.top, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func personCard(label: String, name: Binding<String>, color: Binding<PersonColor>, other: PersonColor) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                PersonAvatar(person: Person(name: name.wrappedValue.isEmpty ? "?" : name.wrappedValue, color: color.wrappedValue),
                             size: 52, filled: true)
                VStack(alignment: .leading, spacing: 6) {
                    Text(label).font(.footnote).foregroundStyle(VaultColor.textSecondary)
                    TextField("Name", text: name)
                        .textContentType(.givenName)
                        .font(.title3)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background(VaultColor.raised, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            ColorSwatches(selection: color, takenBy: Person(name: "the other person", color: other))
        }
        .vaultCard(padding: 16)
    }

    private var ownerStep: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Whose phone is this?").font(.largeTitle.bold())
                Text("Deposits you add here are yours by default. You can change this later in Settings.")
                    .foregroundStyle(VaultColor.textSecondary)
            }
            HStack(spacing: 12) {
                ForEach(Array(people.enumerated()), id: \.offset) { index, person in
                    Button { ownerIndex = index } label: {
                        VStack(spacing: 14) {
                            PersonAvatar(person: person, size: 80, filled: true)
                            Text(person.name).font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 26)
                        .background(ownerIndex == index ? person.color.solid.opacity(0.12) : VaultColor.card,
                                    in: RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous)
                            .strokeBorder(ownerIndex == index ? person.color.solid : VaultColor.hairline,
                                          lineWidth: ownerIndex == index ? 1.5 : 1))
                        .overlay(alignment: .topTrailing) {
                            if ownerIndex == index {
                                Image(systemName: "checkmark.circle.fill").font(.title3)
                                    .foregroundStyle(person.color.solid).padding(10)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(ownerIndex == index ? .isSelected : [])
                }
            }
            if let ownerIndex {
                HStack(spacing: 14) {
                    Image(systemName: "checkmark").font(.headline)
                        .foregroundStyle(VaultColor.progress)
                        .frame(width: 44, height: 44).background(VaultColor.progress.opacity(0.14), in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text("You're all set, \(people[ownerIndex].name)").font(.headline)
                        Text("Next, you'll invite \(people[1 - ownerIndex].name) through iCloud sharing.")
                            .font(.footnote).foregroundStyle(VaultColor.textSecondary)
                    }
                }
                .vaultCard(padding: 16)
                .transition(.opacity)
            }
        }
        .foregroundStyle(VaultColor.textPrimary)
        .padding(.top, 24)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: Footer

    @ViewBuilder private var footerButton: some View {
        switch step {
        case .welcome:
            Button("Get started") { step = .people }.buttonStyle(.vaultPrimary)
        case .people:
            HStack(spacing: 10) {
                Button("Back") { step = .welcome }.buttonStyle(.vaultSecondary).frame(width: 110)
                Button("Continue") { step = .owner }
                    .buttonStyle(.vaultPrimary)
                    .disabled(people.contains { $0.name.isEmpty })
            }
        case .owner:
            HStack(spacing: 10) {
                Button("Back") { step = .people }.buttonStyle(.vaultSecondary).frame(width: 110)
                Button("Open Vault") {
                    guard let ownerIndex else { return }
                    let finalPeople = people
                    store.completeSetup(people: finalPeople, ownerID: finalPeople[ownerIndex].id)
                }
                .buttonStyle(.vaultPrimary)
                .disabled(ownerIndex == nil)
            }
        }
    }
}

/// The logo: a platinum vault dial with tick marks and a notch at 12 o'clock.
struct VaultDial: View {
    var body: some View {
        ZStack {
            Circle().stroke(VaultColor.accent.opacity(0.14), lineWidth: 1)
            ForEach(0..<48, id: \.self) { tick in
                Capsule()
                    .fill(VaultColor.accent.opacity(tick % 8 == 0 ? 0.6 : 0.28))
                    .frame(width: tick % 8 == 0 ? 2 : 1, height: tick % 8 == 0 ? 12 : 7)
                    .offset(y: -80)
                    .rotationEffect(.degrees(Double(tick) * 7.5))
            }
            Circle().fill(VaultColor.card).padding(34)
                .overlay(Circle().stroke(VaultColor.accent.opacity(0.35), lineWidth: 1).padding(34))
            Circle()
                .trim(from: 0.03, to: 0.95)
                .stroke(VaultColor.accent, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(56)
            Capsule().fill(VaultColor.accent).frame(width: 3, height: 18).offset(y: -88)
        }
        .accessibilityLabel("Vault logo")
    }
}

#Preview {
    OnboardingView()
        .environment(VaultStore(scenario: .firstLaunch))
        .preferredColorScheme(.dark)
}
