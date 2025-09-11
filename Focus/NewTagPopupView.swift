import SwiftUI

struct NewTagPopupView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 20) {
                Text("New Achievement!")
                    .font(.appLargeTitle(size: 20))
                    .foregroundColor(AppColors.Text.primary)

                Text("You have a new achievement available.")
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Button(action: {
                    Task {
                        await confirmNewPopup()
                    }
                }) {
                    Text("确定")
                        .font(.appButton(size: 18))
                        .foregroundColor(AppColors.Text.inverse)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.Brand.primary)
                        .cornerRadius(10)
                }
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .background(AppColors.Background.card)
            .cornerRadius(20)
            .shadow(color: AppColors.Neutral.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .frame(maxWidth: 300)
        }
    }

    // MARK: - API 调用
    private func confirmNewPopup() async {
        do {
            let response = try await NetworkManager.shared.exchangePosterWithJSON()
            print("✅ 弹框确认调用接口成功")
            await MainActor.run {
                isPresented = false
                let userDefaults = UserDefaults.standard

                if let userAchievement = try? JSONEncoder().encode(response.data.userStuffMap) {
                    userDefaults.set(userAchievement, forKey: UserManager.Keys.userAchievement)
                    NotificationCenter.default.post(
                        name: .didUpdateAchievement,
                        object: nil,
                        userInfo: ["message": "更新成功"]
                    )
                }
            }
        } catch {
            print("❌ 弹框确认调用接口失败: \(error)")
        }
    }
}
