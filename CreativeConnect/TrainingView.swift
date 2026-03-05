import SwiftUI
import Combine

struct TrainingView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    let difficulty: Difficulty

    @State private var keywords: [String] = []
    @State private var answer: String = ""
    @State private var selectedConnectionTypes: Set<String> = []
    @State private var timeRemaining: Int = 0
    @State private var elapsedTime: Int = 0
    @State private var isRunning: Bool = false
    @State private var isFinished: Bool = false
    @State private var showResult = false
    @State private var timer: AnyCancellable?
    @FocusState private var isInputFocused: Bool

    var progress: Double {
        guard difficulty.timeLimit > 0 else { return 0 }
        return Double(timeRemaining) / Double(difficulty.timeLimit)
    }

    var timerColor: Color {
        if progress > 0.5 { return .green }
        if progress > 0.25 { return .orange }
        return .red
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - 타이머 링
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(timerColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timeRemaining)
                        VStack(spacing: 2) {
                            Text(timeString(timeRemaining))
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundStyle(timerColor)
                            Text(isRunning ? "남은 시간" : "준비됨")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 140, height: 140)
                    .padding(.top, 8)

                    // MARK: - 키워드 카드들
                    VStack(spacing: 8) {
                        Text("이 두 키워드를 연결하세요")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            ForEach(Array(keywords.enumerated()), id: \.offset) { index, keyword in
                                KeywordPill(keyword: keyword, difficulty: difficulty)

                                if index < keywords.count - 1 {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - 연결 방식 태그
                    VStack(alignment: .leading, spacing: 10) {
                        Text("연결 방식 선택 (선택사항)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ConnectionType.all) { type in
                                    let isSelected = selectedConnectionTypes.contains(type.name)
                                    Button {
                                        if isSelected {
                                            selectedConnectionTypes.remove(type.name)
                                        } else {
                                            selectedConnectionTypes.insert(type.name)
                                        }
                                    } label: {
                                        HStack(spacing: 5) {
                                            Text(type.emoji)
                                            Text(type.name)
                                                .font(.subheadline)
                                                .fontWeight(isSelected ? .semibold : .regular)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            isSelected
                                            ? difficulty.color.opacity(0.2)
                                            : Color(.secondarySystemBackground)
                                        )
                                        .foregroundStyle(isSelected ? difficulty.color : .primary)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule().stroke(
                                                isSelected ? difficulty.color : .clear,
                                                lineWidth: 1.5
                                            )
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - 입력창
                    VStack(alignment: .leading, spacing: 8) {
                        Text("내 아이디어")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ZStack(alignment: .topLeading) {
                            if answer.isEmpty {
                                Text("두 키워드의 연결고리를 자유롭게 써보세요...\n제약 없이 마음껏!")
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                            }
                            TextEditor(text: $answer)
                                .frame(minHeight: 140)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .focused($isInputFocused)
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }

                    // MARK: - 완료 버튼
                    Button {
                        finishSession()
                    } label: {
                        Text(answer.isEmpty ? "건너뛰기" : "완료하기")
                            .fontWeight(.bold)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                answer.isEmpty
                                ? LinearGradient(colors: [Color.gray, Color.gray], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(
                                    colors: [difficulty.color, difficulty.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("\(difficulty.emoji) \(difficulty.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        stopTimer()
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isRunning ? "일시정지" : "시작") {
                        isRunning ? pauseTimer() : startTimer()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(difficulty.color)
                }
            }
        }
        .onAppear {
            setupSession()
        }
        .sheet(isPresented: $showResult) {
            ResultView(
                keywords: keywords,
                answer: answer,
                difficulty: difficulty,
                elapsedTime: elapsedTime,
                connectionTypes: Array(selectedConnectionTypes)
            )
            .environmentObject(store)
        }
    }

    // MARK: - Logic

    private func setupSession() {
        keywords = KeywordBank.keywords(for: difficulty)
        timeRemaining = difficulty.timeLimit
        startTimer()
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    elapsedTime += 1
                } else {
                    finishSession()
                }
            }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.cancel()
    }

    private func stopTimer() {
        isRunning = false
        timer?.cancel()
    }

    private func finishSession() {
        stopTimer()
        showResult = true
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Keyword Pill

struct KeywordPill: View {
    let keyword: String
    let difficulty: Difficulty

    var body: some View {
        Text(keyword)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(difficulty.color.opacity(0.15))
            .foregroundStyle(difficulty.color)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(difficulty.color.opacity(0.3), lineWidth: 1.5)
            )
    }
}
