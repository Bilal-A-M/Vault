import SwiftUI

struct HistoryView: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router
    @State private var personFilter: Person.ID?
    @State private var goalFilter: Goal.ID?
    @State private var pendingDelete: Entry?

    private var filtered: [Entry] {
        store.sortedEntries.filter {
            (personFilter == nil || $0.personID == personFilter) && (goalFilter == nil || $0.goalID == goalFilter)
        }
    }

    struct MonthGroup: Identifiable {
        let month: Date
        let entries: [Entry]
        var id: Date { month }
    }

    /// Entries grouped by calendar month, newest first.
    private var months: [MonthGroup] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filtered) { calendar.dateInterval(of: .month, for: $0.date)?.start ?? $0.date }
        return groups.keys.sorted(by: >).map { MonthGroup(month: $0, entries: groups[$0] ?? []) }
    }

    var body: some View {
        List {
            Section {
                filters.listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
            }
            if store.entries.isEmpty {
                Section {
                    EmptyStateView(icon: "clock.arrow.circlepath", title: "Nothing logged yet",
                                   message: "Every deposit and withdrawal you two log will show up here, newest first.",
                                   actionTitle: "Add deposit") { router.addDeposit() }
                        .listRowBackground(Color.clear)
                }
            } else if filtered.isEmpty {
                Section {
                    EmptyStateView(icon: "line.3.horizontal.decrease.circle", title: "No matches",
                                   message: "Nothing matches these filters.", actionTitle: "Clear filters") {
                        personFilter = nil
                        goalFilter = nil
                    }
                    .listRowBackground(Color.clear)
                }
            } else {
                ForEach(months) { group in
                    Section {
                        ForEach(group.entries) { entry in
                            Button { router.edit(entry) } label: {
                                ActivityRow(entry: entry, person: store.person(entry.personID), goal: store.goal(entry.goalID),
                                            isNew: store.isNew(entry), ownerID: store.owner?.id)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(VaultColor.card)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) { pendingDelete = entry } label: { Label("Delete", systemImage: "trash") }
                                Button { router.edit(entry) } label: { Label("Edit", systemImage: "pencil") }
                                    .tint(Color(hex: 0x636366))
                            }
                        }
                    } header: {
                        HStack {
                            Text(group.month.formatted(.dateTime.month(.wide).year()))
                            Spacer()
                            MoneyText(cents: VaultMath.total(group.entries), style: .caption, signed: true)
                        }
                        .font(.footnote)
                        .foregroundStyle(VaultColor.textSecondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(VaultColor.background)
        .navigationTitle("History")
        .confirmationDialog("Delete this entry?", isPresented: Binding(get: { pendingDelete != nil },
                                                                     set: { if !$0 { pendingDelete = nil } }),
                            titleVisibility: .visible, presenting: pendingDelete) { entry in
            Button("Delete", role: .destructive) { store.deleteEntry(entry.id) }
        } message: { _ in
            Text("It will be removed from both phones.")
        }
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button { personFilter = nil } label: { FilterChip(title: "Everyone", selected: personFilter == nil) }
                ForEach(store.people) { person in
                    Button { personFilter = personFilter == person.id ? nil : person.id } label: {
                        PersonChip(person: person, selected: personFilter == person.id)
                    }
                }
                Menu {
                    Button("All goals") { goalFilter = nil }
                    ForEach(store.sortedGoals) { goal in
                        Button(goal.name) { goalFilter = goal.id }
                    }
                } label: {
                    FilterChip(title: store.goal(goalFilter)?.name ?? "All goals", selected: goalFilter != nil,
                               trailingIcon: "chevron.down")
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack { HistoryView().routes() }
        .environment(VaultStore())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
