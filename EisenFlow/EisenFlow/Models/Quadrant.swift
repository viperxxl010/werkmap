import SwiftUI

enum Quadrant: String, CaseIterable, Identifiable {
    case urgentImportant       // Q1: Do First (top-left)
    case notUrgentImportant    // Q2: Schedule (top-right)
    case urgentNotImportant    // Q3: Delegate (bottom-left)
    case notUrgentNotImportant // Q4: Eliminate (bottom-right)

    var id: String { rawValue }

    var title: String {
        switch self {
        case .urgentImportant: return "DO FIRST"
        case .notUrgentImportant: return "SCHEDULE"
        case .urgentNotImportant: return "DELEGATE"
        case .notUrgentNotImportant: return "ELIMINATE"
        }
    }

    var subtitle: String {
        switch self {
        case .urgentImportant: return "Urgent & Important"
        case .notUrgentImportant: return "Not Urgent & Important"
        case .urgentNotImportant: return "Urgent & Not Important"
        case .notUrgentNotImportant: return "Not Urgent & Not Important"
        }
    }

    var accentColor: Color {
        switch self {
        case .urgentImportant: return Color.red
        case .notUrgentImportant: return Color.blue
        case .urgentNotImportant: return Color.orange
        case .notUrgentNotImportant: return Color.gray
        }
    }

    var glowColor: Color {
        accentColor.opacity(0.3)
    }

    var isUrgent: Bool {
        self == .urgentImportant || self == .urgentNotImportant
    }

    var isImportant: Bool {
        self == .urgentImportant || self == .notUrgentImportant
    }

    /// Determine quadrant from normalized coordinates (0-1)
    static func from(x: Double, y: Double) -> Quadrant {
        let isUrgent = x < 0.5
        let isImportant = y < 0.5

        switch (isUrgent, isImportant) {
        case (true, true): return .urgentImportant
        case (false, true): return .notUrgentImportant
        case (true, false): return .urgentNotImportant
        case (false, false): return .notUrgentNotImportant
        }
    }

    /// Get the frame rect for this quadrant within a given size
    func frame(in size: CGSize) -> CGRect {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        switch self {
        case .urgentImportant:
            return CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight)
        case .notUrgentImportant:
            return CGRect(x: halfWidth, y: 0, width: halfWidth, height: halfHeight)
        case .urgentNotImportant:
            return CGRect(x: 0, y: halfHeight, width: halfWidth, height: halfHeight)
        case .notUrgentNotImportant:
            return CGRect(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight)
        }
    }
}
