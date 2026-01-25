import Foundation

struct PrioritizationEngine {
    /// Sort tasks by priority (highest first)
    /// Only includes tasks that are in the matrix and not completed
    static func sortedByPriority(_ tasks: [EisenTask]) -> [EisenTask] {
        tasks
            .filter { $0.isInMatrix && !$0.isCompleted }
            .sorted { $0.priorityScore > $1.priorityScore }
    }

    /// Get priority rank for a task (1 = highest priority)
    static func priorityRank(for task: EisenTask, in tasks: [EisenTask]) -> Int? {
        let sorted = sortedByPriority(tasks)
        guard let index = sorted.firstIndex(where: { $0.id == task.id }) else {
            return nil
        }
        return index + 1
    }

    /// Get tasks grouped by quadrant
    static func groupedByQuadrant(_ tasks: [EisenTask]) -> [Quadrant: [EisenTask]] {
        var grouped: [Quadrant: [EisenTask]] = [:]

        for quadrant in Quadrant.allCases {
            grouped[quadrant] = []
        }

        for task in tasks where task.isInMatrix && !task.isCompleted {
            if let quadrant = task.quadrant {
                grouped[quadrant]?.append(task)
            }
        }

        // Sort each quadrant by priority
        for quadrant in Quadrant.allCases {
            grouped[quadrant]?.sort { $0.priorityScore > $1.priorityScore }
        }

        return grouped
    }

    /// Calculate completion percentage
    static func completionPercentage(_ tasks: [EisenTask]) -> Double {
        let matrixTasks = tasks.filter { $0.isInMatrix }
        guard !matrixTasks.isEmpty else { return 0 }

        let completed = matrixTasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(matrixTasks.count)
    }

    /// Get summary statistics
    static func statistics(_ tasks: [EisenTask]) -> Statistics {
        let matrixTasks = tasks.filter { $0.isInMatrix }
        let grouped = groupedByQuadrant(tasks)

        return Statistics(
            totalTasks: matrixTasks.count,
            completedTasks: matrixTasks.filter { $0.isCompleted }.count,
            urgentImportantCount: grouped[.urgentImportant]?.count ?? 0,
            overdueTasks: matrixTasks.filter { task in
                guard let deadline = task.deadline else { return false }
                return deadline < Date() && !task.isCompleted
            }.count
        )
    }

    struct Statistics {
        let totalTasks: Int
        let completedTasks: Int
        let urgentImportantCount: Int
        let overdueTasks: Int

        var pendingTasks: Int {
            totalTasks - completedTasks
        }

        var completionPercentage: Double {
            guard totalTasks > 0 else { return 0 }
            return Double(completedTasks) / Double(totalTasks) * 100
        }
    }
}
