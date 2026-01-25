import SwiftData
import SwiftUI

@Model
final class EisenTask {
    var id: UUID
    var title: String
    var taskDescription: String
    var deadline: Date?
    var createdAt: Date
    var isCompleted: Bool

    // Position in matrix (nil = inbox)
    var matrixX: Double?
    var matrixY: Double?

    init(
        title: String,
        description: String = "",
        deadline: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.deadline = deadline
        self.createdAt = Date()
        self.isCompleted = false
        self.matrixX = nil
        self.matrixY = nil
    }

    // MARK: - Computed Properties

    /// Check if task is in the matrix (not inbox)
    var isInMatrix: Bool {
        matrixX != nil && matrixY != nil
    }

    /// Get the quadrant based on position
    var quadrant: Quadrant? {
        guard let x = matrixX, let y = matrixY else { return nil }
        return Quadrant.from(x: x, y: y)
    }

    /// Calculate priority score (higher = more important)
    var priorityScore: Double {
        guard let x = matrixX, let y = matrixY else { return 0 }
        // Y weighs 60% (importance), X weighs 40% (urgency)
        // Lower coordinates = higher priority
        var score = (1 - y) * 0.6 + (1 - x) * 0.4

        // Deadline bonus (up to 20% extra)
        if let deadline = deadline {
            let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 365
            if daysUntil <= 0 {
                score += 0.2 // Overdue: maximum bonus
            } else if daysUntil <= 7 {
                score += 0.2 * (1 - Double(daysUntil) / 7)
            }
        }

        return min(1.0, score)
    }

    /// Visual scale factor based on Y position
    var scaleFactor: CGFloat {
        guard let y = matrixY else { return 1.0 }
        let normalizedY = 1 - y
        return 0.95 + (normalizedY * 0.10) // Range: 0.95 - 1.05
    }

    /// Shadow radius based on Y position
    var shadowRadius: CGFloat {
        guard let y = matrixY else { return 6 }
        let normalizedY = 1 - y
        return 4 + (normalizedY * 8) // Range: 4 - 12
    }
}
