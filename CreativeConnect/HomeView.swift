import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var showTraining = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: - 헤더 스탯
                    HStack(spacing: 20) {
                        StatBadge(
                            emoji: "🔥",
                            value: "\(store.streak)",
                            label: "연속"
                        )
                        StatBadge(
                            emoji: "✅",
                            value: "\(store.totalSessions)",
                            label: "총 세션"
                        )
                        StatBadge(
                            emoji: "⏱",
                            value: store.totalSessions > 0 ? "\(Int(store.averageTime))초" : "-",
                            label: "평균 시간"
                        )
                    }
                    .padding(.top, 8)

                    // MARK: - 난이도 선택
                    VStack(alignment: .leading, spacing: 14) {
                        Text("난이도 선택")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(Difficulty.allCases, id: \.self) { diff in
                            DifficultyCard(
                                difficulty: diff,
                                isSelected: selectedDifficulty == diff
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedDifficulty = diff
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - 시작 버튼
                    Button {
                        showTraining = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                            Text("훈련 시작")
                                .fontWeight(.bold)
                            Image(systemName: "sparkles")
                        }
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .purple.opacity(0.4), radius: 12, y: 6)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("CreativeConnect")
            .navigationBarTitleDisplayMode(.large)
        }
        .fullScreenCover(isPresented: $showTraining) {
            TrainingView(difficulty: selectedDifficulty)
        }
    }
}

// MARK: - Subviews

struct StatBadge: View {
    let emoji: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title2)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct DifficultyCard: View {
    let difficulty: Difficulty
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(difficulty.emoji)
                .font(.title)
                .frame(width: 50, height: 50)
                .background(difficulty.color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(difficulty.rawValue)
                    .font(.headline)
                Text(difficulty.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                let mins = difficulty.timeLimit / 60
                let secs = difficulty.timeLimit % 60
                Text(mins > 0 ? "\(mins)분" : "\(secs)초")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(difficulty.color)
                Text("제한시간")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(difficulty.color)
                    .font(.title2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? difficulty.color : .clear, lineWidth: 2)
                )
        )
    }
}
