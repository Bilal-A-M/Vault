import SwiftUI

struct SettingsView: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var store = store
        List {
            Section("People") {
                ForEach(store.people) { person in
                    NavigationLink(value: Route.person(person.id)) {
                        HStack(spacing: 12) {
                            PersonAvatar(person: person, size: 36, filled: true)
                            Text(person.name)
                            Spacer()
                            Text(person.color.displayName).foregroundStyle(VaultColor.textSecondary)
                        }
                    }
                }
            }

            Section {
                Picker("This phone belongs to", selection: Binding(
                    get: { store.owner?.id },
                    set: { if let id = $0 { store.setPhoneOwner(id) } })) {
                    ForEach(store.people) { Text($0.name).tag(Person.ID?.some($0.id)) }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            } header: {
                Text("This phone belongs to")
            } footer: {
                Text("New deposits on this phone are added by this person, and you're notified about the other one's.")
            }

            Section {
                Toggle("When \(store.partner?.name ?? "your partner") adds money", isOn: $store.depositAlerts)
                Toggle("Milestones", isOn: $store.milestoneAlerts)
                NavigationLink("Preview notifications", value: Route.notificationPreview)
            } header: {
                Text("Notifications")
            } footer: {
                Text("Milestones are 25, 50, 75 and 100% of a goal.")
            }

            Section("Appearance") {
                Picker("Appearance", selection: $store.appearance) {
                    ForEach(Appearance.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            Section("Privacy") {
                Toggle("Hide amounts", isOn: $store.hideAmounts)
            }

            Section {
                LabeledContent("iCloud sync") {
                    Text(syncText).foregroundStyle(VaultColor.textSecondary)
                }
            } header: {
                Text("Sharing")
            } footer: {
                Text("Design phase: sync is simulated. Real iCloud sharing with \(store.partner?.name ?? "your partner") comes later.")
            }

            DebugSection()

            Section {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.2")
            } header: {
                Text("About Vault")
            } footer: {
                Text("Made for two. No accounts, no ads, no tracking.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(VaultColor.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var syncText: String {
        switch store.syncStatus {
        case .synced: "Up to date"
        case .syncing: "Syncing…"
        case .offline: "Offline"
        }
    }
}

struct PersonEditorView: View {
    let personID: Person.ID
    @Environment(VaultStore.self) private var store
    @State private var name = ""
    @State private var color: PersonColor = .sky

    var body: some View {
        let other = store.people.first { $0.id != personID }
        Form {
            Section("Name") {
                TextField("Name", text: $name)
                    .textContentType(.givenName)
            }
            Section {
                ColorSwatches(selection: $color, takenBy: other)
                    .padding(.vertical, 6)
            } header: {
                Text("Colour")
            } footer: {
                Text("Used for your avatar and your share of every chart.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(VaultColor.background)
        .navigationTitle(name.isEmpty ? "Person" : name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard let person = store.person(personID) else { return }
            name = person.name
            color = person.color
        }
        .onDisappear {
            guard var person = store.person(personID) else { return }
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty { person.name = trimmed }
            person.color = color
            store.updatePerson(person)
        }
    }
}

/// Six person colours; the partner's colour is disabled.
struct ColorSwatches: View {
    @Binding var selection: PersonColor
    var takenBy: Person?

    var body: some View {
        HStack {
            ForEach(PersonColor.allCases) { option in
                let taken = takenBy?.color == option
                Button { selection = option } label: {
                    Circle()
                        .fill(option.gradient)
                        .frame(width: 40, height: 40)
                        .overlay(Circle().strokeBorder(VaultColor.textPrimary, lineWidth: selection == option ? 2.5 : 0).padding(-4))
                        .opacity(taken ? 0.25 : 1)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .disabled(taken)
                .accessibilityLabel(taken ? "\(option.displayName), taken by \(takenBy?.name ?? "")" : option.displayName)
                .accessibilityAddTraits(selection == option ? .isSelected : [])
                if option != PersonColor.allCases.last { Spacer(minLength: 0) }
            }
        }
    }
}
