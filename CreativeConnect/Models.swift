import Foundation
import SwiftUI

// MARK: - Difficulty

enum Difficulty: String, CaseIterable, Codable {
    case easy = "쉬움"
    case medium = "보통"
    case hard = "어려움"
    case expert = "전문가"

    var description: String {
        switch self {
        case .easy:   return "구체적 명사 2개"
        case .medium: return "추상 + 구체 2개"
        case .hard:   return "추상 개념 2개"
        case .expert: return "랜덤 3개"
        }
    }

    var keywordCount: Int {
        switch self {
        case .easy, .medium, .hard: return 2
        case .expert: return 3
        }
    }

    var timeLimit: Int {
        switch self {
        case .easy:   return 300  // 5분
        case .medium: return 180  // 3분
        case .hard:   return 120  // 2분
        case .expert: return 60   // 1분
        }
    }

    var color: Color {
        switch self {
        case .easy:   return .green
        case .medium: return .blue
        case .hard:   return .orange
        case .expert: return .red
        }
    }

    var emoji: String {
        switch self {
        case .easy:   return "🌱"
        case .medium: return "🔥"
        case .hard:   return "⚡️"
        case .expert: return "💎"
        }
    }
}

// MARK: - Session Record

struct SessionRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var keywords: [String]
    var difficulty: Difficulty
    var answer: String
    var elapsedTime: Int  // seconds
    var connectionTypes: [String]  // 사용자가 선택한 연결 방식들

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var formattedElapsed: String {
        let m = elapsedTime / 60
        let s = elapsedTime % 60
        return m > 0 ? "\(m)분 \(s)초" : "\(s)초"
    }
}

// MARK: - Connection Types

struct ConnectionType: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let description: String
}

extension ConnectionType {
    static let all: [ConnectionType] = [
        ConnectionType(name: "은유", emoji: "🎭", description: "A는 B다"),
        ConnectionType(name: "서사", emoji: "📖", description: "이야기로 연결"),
        ConnectionType(name: "속성", emoji: "🔍", description: "공통점 찾기"),
        ConnectionType(name: "아이디어", emoji: "💡", description: "제품/서비스로"),
        ConnectionType(name: "감각", emoji: "🎨", description: "느낌으로 연결"),
        ConnectionType(name: "논리", emoji: "🧠", description: "인과관계"),
    ]
}
