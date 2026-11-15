import SwiftUI

struct GoalsView: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if store.goals.isEmpty {
                    EmptyStateView(icon: "target", title: "No goals yet",
                                   message: "A goal gives your deposits somewhere to go: a trip, a home, a safety net.",
                                   actionTitle: "Create a goal") { router.newGoal() }
                        .padding(.top, 40)
                } else {
                    HStack(spacing: 4) {
                        MoneyText(cents: store.goals.reduce(0) { $0 + max(0, store.saved($1)) }, style: .caption, fraction: .never)
                            .foregroundStyle(VaultColor.textPrimary)
                        Text("of")
                        MoneyText(cents: store.goals.reduce(0) { $0 + $1.targetCents }, style: .caption, fraction: .never)
                        Text("across \(store.goals.count) goals")
                    }
                    .font(.subheadline)
                    .foregroundStyle(VaultColor.textSecondary)
                    .padding(.bottom, 4)

                    ForEach(store.sortedGoals) { goal in
                        NavigationLink(value: Route.goal(goal.id)) {
                            GoalRowCard(goal: goal, saved: store.saved(goal), fresh: store.freshMilestone(for: goal))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, VaultSpace.page)
            .padding(.bottom, 24)
        }
        .background(VaultColor.background)
        .navigationTitle("Goals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { router.newGoal() } label: { Image(systemName: "plus") }
                    .accessibilityLabel("New goal")
            }
        }
    }
}

#Preview {
    NavigationStack { GoalsView().routes() }
        .environment(VaultStore())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
