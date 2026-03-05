import SwiftUI

struct ResultView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    let keywords: [String]
    let answer: String
    let difficulty: Difficulty
    let elapsedTime: Int
    let connectionTypes: [String]

    @State private var saved = false
    @State private var showCelebration = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: - 완료 배너
                    VStack(spacing: 8) {
                        Text(answer.isEmpty ? "⏭️" : "🎉")
                            .font(.system(size: 60))
                        Text(answer.isEmpty ? "건너뛰었어요" : "훈련 완료!")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("뇌가 조금 더 유연해졌어요")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    // MARK: - 세션 요약
                    VStack(spacing: 16) {
                        SummaryRow(
                            icon: "tag.fill",
                            label: "키워드",
                            value: keywords.joined(separator: " + "),
                            color: difficulty.color
                        )
                        SummaryRow(
                            icon: "timer",
                            label: "소요 시간",
                            value: formatTime(elapsedTime),
                            color: .blue
                        )
                        SummaryRow(
                            icon: "chart.bar.fill",
                            label: "난이도",
                            value: "\(difficulty.emoji) \(difficulty.rawValue)",
                            color: difficulty.color
                        )
                        if !connectionTypes.isEmpty {
                            SummaryRow(
                                icon: "link",
                                label: "연결 방식",
                                value: connectionTypes.joined(separator: ", "),
                                color: .purple
                            )
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

                    // MARK: - 내 답변
                    if !answer.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("내 아이디어", systemImage: "quote.bubble.fill")
                                .font(.headline)

                            Text(answer)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(20)
                        .background(difficulty.color.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(difficulty.color.opacity(0.25), lineWidth: 1.5)
                        )
                        .padding(.horizontal)
                    }

                    // MARK: - 힌트 (답이 없을 때)
                    if answer.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("연결 힌트", systemImage: "lightbulb.fill")
                                .font(.headline)
                                .foregroundStyle(.orange)
                            Text("다음에는 이런 관점으로 시작해보세요:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(ConnectionType.all.prefix(3)) { type in
                                    Text("• \(type.emoji) \(type.name): \(type.description)")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.orange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                    }

                    // MARK: - 저장 / 다음 버튼
                    VStack(spacing: 12) {
                        if !saved && !answer.isEmpty {
                            Button {
                                saveRecord()
                            } label: {
                                Label("기록 저장", systemImage: "square.and.arrow.down")
                                    .fontWeight(.bold)
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
                            }
                        }

                        if saved {
                            Label("저장됨!", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .fontWeight(.semibold)
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("닫기")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("세션 결과")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveRecord() {
        let record = SessionRecord(
            date: Date(),
            keywords: keywords,
            difficulty: difficulty,
            answer: answer,
            elapsedTime: elapsedTime,
            connectionTypes: connectionTypes
        )
        store.save(record: record)
        withAnimation { saved = true }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)분 \(s)초" : "\(s)초"
    }
}

// MARK: - Summary Row

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
    }
}
