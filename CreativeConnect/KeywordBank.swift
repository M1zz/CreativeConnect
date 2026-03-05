import Foundation

struct KeywordBank {

    // MARK: - 구체적 명사
    static let concreteNouns: [String] = [
        "사과", "망치", "거울", "시계", "나침반", "우산", "열쇠", "등대",
        "피아노", "나비", "산호", "지도", "뼈대", "모래시계", "퍼즐",
        "그물", "잠망경", "도자기", "풍선", "저울", "텐트", "낙하산",
        "돋보기", "나팔", "온도계", "로켓", "빗자루", "나무", "구름",
        "다리", "성냥", "실", "바늘", "벽돌", "깃털", "조각배",
        "종", "가면", "뿌리", "씨앗", "화석", "격자", "동전",
        "문", "창문", "계단", "철조망", "모닥불", "수레바퀴"
    ]

    // MARK: - 추상 개념
    static let abstractConcepts: [String] = [
        "외로움", "자유", "시간", "기억", "용기", "침묵", "변화",
        "경계", "균형", "성장", "상실", "연결", "신뢰", "혼돈",
        "규칙", "본능", "상상력", "책임감", "두려움", "호기심",
        "정의", "모순", "집착", "포기", "시작", "끝", "반복",
        "우연", "필연", "공백", "무게", "방향", "속도", "리듬"
    ]

    // MARK: - 자연 현상 / 장소
    static let naturalPlaces: [String] = [
        "블랙홀", "번개", "조류", "빙하", "사막", "심해", "화산",
        "오로라", "폭풍", "동굴", "절벽", "습지", "안개", "해류",
        "지층", "협곡", "온천", "소용돌이", "빛", "어둠"
    ]

    // MARK: - 키워드 선택 로직

    static func keywords(for difficulty: Difficulty) -> [String] {
        switch difficulty {
        case .easy:
            // 구체적 명사 2개
            return pick(from: concreteNouns, count: 2)

        case .medium:
            // 추상 1 + 구체 1
            let abstract = pick(from: abstractConcepts, count: 1)
            let concrete = pick(from: concreteNouns, count: 1)
            return (abstract + concrete).shuffled()

        case .hard:
            // 추상 2개
            return pick(from: abstractConcepts, count: 2)

        case .expert:
            // 3가지 카테고리에서 1개씩
            let all = concreteNouns + abstractConcepts + naturalPlaces
            return pick(from: all, count: 3)
        }
    }

    private static func pick(from array: [String], count: Int) -> [String] {
        Array(array.shuffled().prefix(count))
    }
}
