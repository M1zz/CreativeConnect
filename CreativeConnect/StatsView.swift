import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: AppStore

    var difficultyBreakdown: [(Difficulty, Int)] {
        Difficulty.allCases.map { diff in
            (diff, store.records.filter { $0.difficulty == diff }.count)
        }
    }

    var topConnectionTypes: [(String, Int)] {
        var counts: [String: Int] = [:]
        for record in store.records {
            for type_ in record.connectionTypes {
                counts[type_, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - 핵심 지표
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        StatCard(
                            title: "총 세션",
                            value: "\(store.totalSessions)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        StatCard(
                            title: "연속 훈련",
                            value: "\(store.streak)일",
                            icon: "flame.fill",
                            color: .orange
                        )
                        StatCard(
                            title: "평균 시간",
                            value: store.totalSessions > 0 ? "\(Int(store.averageTime))초" : "-",
                            icon: "timer",
                            color: .blue
                        )
                        StatCard(
                            title: "주요 난이도",
                            value: store.mostUsedDifficulty.map { "\($0.emoji) \($0.rawValue)" } ?? "-",
                            icon: "star.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)

                    // MARK: - 난이도 분포
                    VStack(alignment: .leading, spacing: 14) {
                        Text("난이도별 분포")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            ForEach(difficultyBreakdown, id: \.0) { diff, count in
                                HStack(spacing: 12) {
                                    Text("\(diff.emoji) \(diff.rawValue)")
                                        .font(.subheadline)
                                        .frame(width: 80, alignment: .leading)

                                    GeometryReader { geo in
                                        let maxCount = max(difficultyBreakdown.map(\.1).max() ?? 1, 1)
                                        let barWidth = store.totalSessions > 0
                                        ? geo.size.width * CGFloat(count) / CGFloat(maxCount)
                                        : 0

                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color(.systemGray5))
                                                .frame(height: 12)
                                            Capsule()
                                                .fill(diff.color)
                                                .frame(width: barWidth, height: 12)
                                                .animation(.spring(response: 0.6), value: count)
                                        }
                                    }
                                    .frame(height: 12)

                                    Text("\(count)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 24, alignment: .trailing)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                    }

                    // MARK: - 자주 쓴 연결 방식
                    if !topConnectionTypes.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("즐겨 쓰는 연결 방식")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 8) {
                                ForEach(topConnectionTypes, id: \.0) { name, count in
                                    let typeInfo = ConnectionType.all.first { $0.name == name }
                                    HStack {
                                        Text(typeInfo?.emoji ?? "🔗")
                                        Text(name)
                                            .font(.subheadline)
                                        Spacer()
                                        Text("\(count)회")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.purple)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - 동기부여 메시지
                    if store.totalSessions > 0 {
                        motivationView
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("나의 통계")
        }
    }

    @ViewBuilder
    var motivationView: some View {
        let message: (String, String) = {
            switch store.totalSessions {
            case 1...5:   return ("🌱", "시작이 반! 꾸준히 해봐요.")
            case 6...20:  return ("🔥", "감이 잡혀가고 있어요!")
            case 21...50: return ("⚡️", "창의적인 뇌로 진화 중!")
            default:       return ("💎", "창의력 마스터의 경지!")
            }
        }()

        HStack(spacing: 14) {
            Text(message.0).font(.largeTitle)
            Text(message.1)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(LinearGradient(colors: [.purple.opacity(0.1), .pink.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title2)
                Spacer()
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
