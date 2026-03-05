import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedRecord: SessionRecord?

    var body: some View {
        NavigationStack {
            Group {
                if store.records.isEmpty {
                    ContentUnavailableView(
                        "아직 기록이 없어요",
                        systemImage: "clock.badge.questionmark",
                        description: Text("첫 훈련을 시작해보세요!\n창의력은 꾸준함에서 나옵니다 💪")
                    )
                } else {
                    List {
                        ForEach(store.records) { record in
                            HistoryRow(record: record)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedRecord = record
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: store.delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("훈련 기록")
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
        }
    }
}

// MARK: - History Row

struct HistoryRow: View {
    let record: SessionRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // 키워드들
                HStack(spacing: 6) {
                    ForEach(Array(record.keywords.enumerated()), id: \.offset) { index, kw in
                        Text(kw)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(record.difficulty.color)
                        if index < record.keywords.count - 1 {
                            Text("+")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                // 난이도 뱃지
                Text("\(record.difficulty.emoji) \(record.difficulty.rawValue)")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(record.difficulty.color.opacity(0.15))
                    .foregroundStyle(record.difficulty.color)
                    .clipShape(Capsule())
            }

            // 답변 미리보기
            if !record.answer.isEmpty {
                Text(record.answer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else {
                Text("(기록 없음)")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .italic()
            }

            HStack {
                Label(record.formattedDate, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
                Label(record.formattedElapsed, systemImage: "timer")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Record Detail

struct RecordDetailView: View {
    @Environment(\.dismiss) var dismiss
    let record: SessionRecord

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // 키워드
                    HStack(spacing: 12) {
                        ForEach(Array(record.keywords.enumerated()), id: \.offset) { index, kw in
                            KeywordPill(keyword: kw, difficulty: record.difficulty)
                            if index < record.keywords.count - 1 {
                                Image(systemName: "plus")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 16)

                    // 메타 정보
                    VStack(spacing: 14) {
                        SummaryRow(icon: "calendar", label: "날짜", value: record.formattedDate, color: .blue)
                        SummaryRow(icon: "timer", label: "소요 시간", value: record.formattedElapsed, color: .green)
                        SummaryRow(icon: "chart.bar", label: "난이도", value: "\(record.difficulty.emoji) \(record.difficulty.rawValue)", color: record.difficulty.color)
                        if !record.connectionTypes.isEmpty {
                            SummaryRow(icon: "link", label: "연결 방식", value: record.connectionTypes.joined(separator: ", "), color: .purple)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

                    // 답변 전문
                    if !record.answer.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("내 아이디어", systemImage: "quote.bubble.fill")
                                .font(.headline)
                            Text(record.answer)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(20)
                        .background(record.difficulty.color.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(record.difficulty.color.opacity(0.25), lineWidth: 1.5))
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("세션 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}
