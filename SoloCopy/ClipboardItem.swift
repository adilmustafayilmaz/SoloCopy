import Foundation

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var createdAt: Date
    var isStarred: Bool
    
    init(id: UUID = UUID(), text: String, createdAt: Date = Date(), isStarred: Bool = false) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.isStarred = isStarred
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.text == rhs.text &&
               lhs.createdAt == rhs.createdAt &&
               lhs.isStarred == rhs.isStarred
    }
} 