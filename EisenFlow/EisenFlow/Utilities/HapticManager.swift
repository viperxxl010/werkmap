import AppKit

/// Manages haptic feedback for trackpad interactions
final class HapticManager {
    static let shared = HapticManager()

    private let feedbackManager = NSHapticFeedbackManager.defaultPerformer

    private init() {}

    /// Perform haptic feedback with specified pattern
    func perform(_ pattern: NSHapticFeedbackManager.FeedbackPattern) {
        feedbackManager.perform(pattern, performanceTime: .default)
    }

    // MARK: - Convenience Methods

    /// For task drop onto matrix
    func taskDropped() {
        perform(.levelChange)
    }

    /// For crossing axis lines
    func axisCrossed() {
        perform(.alignment)
    }

    /// For task completion
    func taskCompleted() {
        perform(.generic)
    }

    /// For drag start
    func dragStarted() {
        perform(.generic)
    }

    /// For entering a new quadrant
    func quadrantEntered() {
        perform(.alignment)
    }
}
