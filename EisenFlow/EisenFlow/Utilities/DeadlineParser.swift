import Foundation

struct DeadlineParser {
    /// Parse flexible date input into a Date
    /// Supports formats like:
    /// - "vandaag", "morgen", "overmorgen"
    /// - "1-12-2025", "01-12-2025"
    /// - "1-12-25", "01-12-25"
    /// - "1/12/2025", "1/12/25"
    /// - "maandag", "dinsdag", etc. (next occurrence)
    static func parse(_ input: String) -> Date? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Handle relative dates
        let calendar = Calendar.current
        let today = Date()

        switch trimmed {
        case "vandaag", "today":
            return calendar.startOfDay(for: today)
        case "morgen", "tomorrow":
            return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))
        case "overmorgen":
            return calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: today))
        case "volgende week", "next week":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: calendar.startOfDay(for: today))
        default:
            break
        }

        // Handle weekday names (Dutch and English)
        let weekdays = [
            "zondag": 1, "sunday": 1,
            "maandag": 2, "monday": 2,
            "dinsdag": 3, "tuesday": 3,
            "woensdag": 4, "wednesday": 4,
            "donderdag": 5, "thursday": 5,
            "vrijdag": 6, "friday": 6,
            "zaterdag": 7, "saturday": 7
        ]

        if let targetWeekday = weekdays[trimmed] {
            let currentWeekday = calendar.component(.weekday, from: today)
            var daysToAdd = targetWeekday - currentWeekday
            if daysToAdd <= 0 {
                daysToAdd += 7 // Next week
            }
            return calendar.date(byAdding: .day, value: daysToAdd, to: calendar.startOfDay(for: today))
        }

        // Try parsing date formats
        let dateFormatters = createDateFormatters()

        for formatter in dateFormatters {
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        // Try with original case
        for formatter in dateFormatters {
            if let date = formatter.date(from: input.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return date
            }
        }

        return nil
    }

    private static func createDateFormatters() -> [DateFormatter] {
        let formats = [
            "d-M-yyyy",
            "dd-MM-yyyy",
            "d-M-yy",
            "dd-MM-yy",
            "d/M/yyyy",
            "dd/MM/yyyy",
            "d/M/yy",
            "dd/MM/yy",
            "yyyy-MM-dd",
            "d MMM yyyy",
            "d MMMM yyyy",
            "d MMM",
            "d MMMM"
        ]

        return formats.flatMap { format -> [DateFormatter] in
            let nlFormatter = DateFormatter()
            nlFormatter.dateFormat = format
            nlFormatter.locale = Locale(identifier: "nl_NL")

            let enFormatter = DateFormatter()
            enFormatter.dateFormat = format
            enFormatter.locale = Locale(identifier: "en_US")

            return [nlFormatter, enFormatter]
        }
    }

    /// Format a date for display
    static func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "nl_NL")
        return formatter.string(from: date)
    }

    /// Get relative description (e.g., "Vandaag", "Morgen", "Over 3 dagen")
    static func relativeDescription(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: today, to: targetDay)
        guard let days = components.day else { return format(date) }

        switch days {
        case ..<0:
            return "Verlopen"
        case 0:
            return "Vandaag"
        case 1:
            return "Morgen"
        case 2:
            return "Overmorgen"
        case 3...7:
            return "Over \(days) dagen"
        default:
            return format(date)
        }
    }
}
