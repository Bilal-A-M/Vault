import SwiftUI
import UserNotifications

/// Mockups of the two notifications, worded around the other person.
struct NotificationPreviewView: View {
    @Environment(VaultStore.self) private var store

    var body: some View {
        let partner = store.partner?.name ?? "Hiba"
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("How Vault's notifications will look on the Lock Screen. These are previews, not real notifications.")
                    .font(.subheadline).foregroundStyle(VaultColor.textSecondary)
                NotificationBanner(title: "\(partner) added $200 to Vacation", message: "You're at $4,680 of $6,000.", time: "now")
                NotificationBanner(title: "Vacation passed 75%", message: "\(partner)'s deposit took you past three quarters.", time: "now")
                NotificationBanner(title: "Emergency fund is fully funded", message: "$10,000 saved together. Open Vault to celebrate.", time: "2m ago")
            }
            .padding(VaultSpace.page)
        }
        .background(
            LinearGradient(colors: [Color(hex: 0x1B1D24), Color(hex: 0x0B0C10)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct NotificationBanner: View {
    let title: String
    let message: String
    let time: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AppIconMark().frame(width: 38, height: 38)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(time).font(.footnote).foregroundStyle(.secondary)
                }
                Text(message).font(.subheadline)
            }
        }
        .foregroundStyle(.white)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .combine)
    }
}

/// The app icon idea: a platinum vault dial on black.
struct AppIconMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color(hex: 0x0E0E11))
            Circle()
                .trim(from: 0.04, to: 0.96)
                .stroke(Color(hex: 0xD9DDE3), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(9)
        }
        .accessibilityHidden(true)
    }
}

/// Shown before iOS's own permission alert, so the ask makes sense.
struct NotificationPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(VaultStore.self) private var store
    @State private var result: String?

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: "bell.badge")
                .font(.system(size: 44))
                .foregroundStyle(VaultColor.accent)
                .frame(width: 96, height: 96)
                .background(VaultColor.raised, in: Circle())
            Text("Know when \(store.partner?.name ?? "your partner") saves").font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Vault can tell you when money is added and when a goal passes a milestone. Nothing else, ever.")
                .font(.body).foregroundStyle(VaultColor.textSecondary).multilineTextAlignment(.center)
            if let result { Text(result).font(.footnote).foregroundStyle(VaultColor.textSecondary) }
            Spacer()
            Button("Turn on notifications") {
                Task {
                    let granted = (try? await UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge])) ?? false
                    result = granted ? "Notifications are on." : "No problem. You can turn them on later in Settings."
                }
            }
            .buttonStyle(.vaultPrimary)
            Button("Not now") { dismiss() }.frame(minHeight: 44)
        }
        .foregroundStyle(VaultColor.textPrimary)
        .padding(.horizontal, 28)
        .padding(.bottom, 20)
        .background(VaultColor.background)
    }
}
