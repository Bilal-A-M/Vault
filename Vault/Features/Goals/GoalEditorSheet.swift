import SwiftUI

/// Create or edit a goal: name, target, optional date, icon.
struct GoalEditorSheet: View {
    let config: GoalSheetConfig
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var targetCents = 0
    @State private var hasDate = true
    @State private var targetDate = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    @State private var icon: GoalIcon = .star
    @State private var confirmDelete = false

    private var isEditing: Bool { config.editing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name, e.g. Vacation", text: $name)
                }
                Section("Target") {
                    CurrencyField(cents: $targetCents, autofocus: false)
                        .listRowBackground(Color.clear)
                }
                Section {
                    Toggle("Target date", isOn: $hasDate.animation())
                    if hasDate {
                        DatePicker("Reach it by", selection: $targetDate, in: Date.now..., displayedComponents: .date)
                    }
                } footer: {
                    if hasDate, let needed = VaultMath.monthlyNeeded(
                        remaining: targetCents - (config.editing.map { store.saved($0) } ?? 0),
                        targetDate: targetDate) {
                        Text("About \(Money.format(cents: needed, fraction: .never)) a month to get there.")
                    }
                }
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
                        ForEach(GoalIcon.allCases) { option in
                            Button { icon = option } label: {
                                Image(systemName: option.symbol)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(icon == option ? VaultColor.onAccent : VaultColor.textPrimary)
                                    .background(icon == option ? VaultColor.accent : VaultColor.raised, in: Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option.label)
                            .accessibilityAddTraits(icon == option ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 6)
                }
                if isEditing {
                    Section {
                        Button("Delete goal", role: .destructive) { confirmDelete = true }
                    } footer: {
                        Text("Its deposits stay in your total, just without a goal.")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(VaultColor.background)
            .navigationTitle(isEditing ? "Edit goal" : "New goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || targetCents == 0)
                }
            }
            .confirmationDialog("Delete \(name)?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete goal", role: .destructive) {
                    if let goal = config.editing {
                        store.deleteGoal(goal.id)
                        router.goalsPath.removeAll()
                        router.homePath.removeAll()
                    }
                    dismiss()
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let goal = config.editing else { return }
        name = goal.name
        targetCents = goal.targetCents
        hasDate = goal.targetDate != nil
        if let date = goal.targetDate { targetDate = date }
        icon = goal.icon
    }

    private func save() {
        var goal = config.editing ?? Goal(name: name, icon: icon, targetCents: targetCents)
        goal.name = name.trimmingCharacters(in: .whitespaces)
        goal.targetCents = targetCents
        goal.targetDate = hasDate ? targetDate : nil
        goal.icon = icon
        store.saveGoal(goal)
        dismiss()
    }
}
