import SwiftUI

/// Add deposit, Log withdrawal, and Edit, in one sheet.
struct EntrySheet: View {
    let config: EntrySheetConfig
    @Environment(VaultStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var kind: Entry.Kind = .deposit
    @State private var cents = 0
    @State private var goalID: Goal.ID?
    @State private var personID: Person.ID?
    @State private var date = Date.now
    @State private var note = ""
    @State private var confirmDelete = false

    private var isEditing: Bool { config.editing != nil }
    private var goal: Goal? { store.goal(goalID) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Picker("Type", selection: $kind) {
                        ForEach(Entry.Kind.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    VStack(spacing: 12) {
                        Text("Amount").font(.subheadline).foregroundStyle(VaultColor.textSecondary)
                        CurrencyField(cents: $cents, autofocus: !isEditing)
                        HStack(spacing: 8) {
                            ForEach([5_000, 10_000, 50_000], id: \.self) { step in
                                Button("+\(Money.format(cents: step, fraction: .never))") { cents += step }
                                    .font(.subheadline.weight(.medium))
                                    .padding(.horizontal, 14).frame(minHeight: 36)
                                    .background(VaultColor.raised, in: Capsule())
                                    .foregroundStyle(VaultColor.accent)
                            }
                        }
                    }
                    .padding(.top, 4)

                    details

                    if let preview { Text(preview).font(.footnote).foregroundStyle(VaultColor.textSecondary) }

                    Button(action: save) { Text(saveTitle) }
                        .buttonStyle(.vaultPrimary)
                        .disabled(cents == 0 || personID == nil)

                    if isEditing {
                        Button("Delete entry", role: .destructive) { confirmDelete = true }
                            .frame(minHeight: 44)
                    }
                }
                .padding(.horizontal, VaultSpace.page)
                .padding(.bottom, 24)
            }
            .background(VaultColor.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .confirmationDialog("Delete this entry?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let entry = config.editing { store.deleteEntry(entry.id) }
                    dismiss()
                }
            } message: {
                Text("It will be removed from both phones.")
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear(perform: load)
    }

    private var details: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Goal")
                Spacer()
                Picker("Goal", selection: $goalID) {
                    Text("No goal").tag(Goal.ID?.none)
                    ForEach(store.sortedGoals) { Text($0.name).tag(Goal.ID?.some($0.id)) }
                }
                .labelsHidden()
                .tint(VaultColor.textSecondary)
            }
            .frame(minHeight: 48)
            Divider()
            HStack {
                Text(kind == .deposit ? "Added by" : "Taken by")
                Spacer()
                HStack(spacing: 6) {
                    ForEach(store.people) { person in
                        Button { personID = person.id } label: {
                            PersonChip(person: person, title: person.id == store.owner?.id ? "Me" : nil,
                                       selected: personID == person.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(minHeight: 52)
            Divider()
            DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                .frame(minHeight: 48)
            Divider()
            HStack {
                Text("Note")
                TextField("Optional", text: $note)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(VaultColor.textSecondary)
            }
            .frame(minHeight: 48)
        }
        .font(.body)
        .foregroundStyle(VaultColor.textPrimary)
        .padding(.horizontal, 16)
        .background(VaultColor.raised, in: RoundedRectangle(cornerRadius: VaultRadius.list, style: .continuous))
    }

    private var title: String {
        if isEditing { return kind == .deposit ? "Edit deposit" : "Edit withdrawal" }
        return kind == .deposit ? "Add deposit" : "Log withdrawal"
    }

    private var saveTitle: String {
        let amount = Money.format(cents: cents, fraction: .auto)
        if isEditing { return "Save changes" }
        switch (kind, goal) {
        case (.deposit, .some(let goal)): return "Add \(amount) to \(goal.name)"
        case (.deposit, .none): return "Add \(amount)"
        case (.withdrawal, .some(let goal)): return "Log \(amount) withdrawal from \(goal.name)"
        case (.withdrawal, .none): return "Log \(amount) withdrawal"
        }
    }

    /// "Vacation goes from 78% to 81%".
    private var preview: String? {
        guard let goal, cents > 0 else { return nil }
        let current = store.saved(goal) - (config.editing?.signedCents ?? 0)
        let after = current + (kind == .deposit ? cents : -cents)
        let from = VaultMath.progress(saved: current, target: goal.targetCents)
        let to = VaultMath.progress(saved: after, target: goal.targetCents)
        return "\(goal.name) goes from \(Self.percent(from)) to \(Self.percent(to))"
    }

    static func percent(_ value: Double) -> String {
        let pct = value * 100
        return pct.rounded() == pct ? "\(Int(pct))%" : String(format: "%.1f%%", pct)
    }

    private func load() {
        if let entry = config.editing {
            kind = entry.kind
            cents = entry.amountCents
            goalID = entry.goalID
            personID = entry.personID
            date = entry.date
            note = entry.note
        } else {
            kind = config.kind
            goalID = config.goalID ?? store.sortedGoals.first(where: { store.progress($0) < 1 })?.id
            personID = store.owner?.id
        }
    }

    private func save() {
        guard let personID else { return }
        var entry = config.editing ?? Entry(amountCents: cents, date: date, personID: personID, createdAt: .now)
        entry.amountCents = cents
        entry.kind = kind
        entry.goalID = goalID
        entry.personID = personID
        entry.date = date
        entry.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let celebration = isEditing ? nil : store.saveEntry(entry)
        if isEditing { store.saveEntry(entry) }
        dismiss()
        if let celebration {
            // Let the sheet finish closing before the celebration covers the screen.
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(450))
                store.present(celebration)
            }
        }
    }
}
