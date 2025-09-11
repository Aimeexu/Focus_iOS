import SwiftUI

struct NewTagPopupView: View {
    let title: String = "New Achievement!"
    let message: String = "You have a new achievement available."
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // 弹窗内容
            VStack(spacing: 20) {
                Text(title)
                    .font(.appLargeTitle(size: 20))
                    .foregroundColor(AppColors.Text.primary)

                Text(message)
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // 确定按钮
                Button(action: {
                    isPresented = false
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
}
