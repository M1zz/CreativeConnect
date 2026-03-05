import Foundation
import Combine

class AppStore: ObservableObject {

    // MARK: - Published State
    @Published var records: [SessionRecord] = []
    @Published var streak: Int = 0
    @Published var totalSessions: Int = 0

    // MARK: - Persistence
    private let recordsKey = "session_records"
    private let lastDateKey = "last_session_date"

    init() {
        load()
        computeStreak()
    }

    func save(record: SessionRecord) {
        records.insert(record, at: 0)
        totalSessions += 1
        persist()
        computeStreak()
    }

    func delete(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        persist()
    }

    // MARK: - Private

    private func persist() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
        UserDefaults.standard.set(Date(), forKey: lastDateKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            records = decoded
            totalSessions = decoded.count
        }
    }

    private func computeStreak() {
        guard !records.isEmpty else { streak = 0; return }

        let calendar = Calendar.current
        var current = Date()
        var count = 0

        for record in records {
            if calendar.isDate(record.date, inSameDayAs: current) {
                count += 1
                current = calendar.date(byAdding: .day, value: -1, to: current) ?? current
            } else if calendar.isDate(record.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: current) ?? current) {
                current = record.date
                count += 1
                current = calendar.date(byAdding: .day, value: -1, to: current) ?? current
            } else {
                break
            }
        }

        streak = count
    }

    // MARK: - Stats
    var averageTime: Double {
        guard !records.isEmpty else { return 0 }
        return Double(records.map(\.elapsedTime).reduce(0, +)) / Double(records.count)
    }

    var mostUsedDifficulty: Difficulty? {
        let counts = Dictionary(grouping: records, by: \.difficulty).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }
}
