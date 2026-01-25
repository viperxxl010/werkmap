import SwiftUI
import SwiftData

struct PriorityListView: View {
    @Query private var tasks: [EisenTask]
    @Environment(\.modelContext) private var modelContext

    @State private var showConfetti = false

    private var sortedTasks: [EisenTask] {
        PrioritizationEngine.sortedByPriority(tasks)
    }

    private var completedTasks: [EisenTask] {
        tasks.filter { $0.isInMatrix && $0.isCompleted }
    }

    private var statistics: PrioritizationEngine.Statistics {
        PrioritizationEngine.statistics(tasks)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()
                .background(Color.white.opacity(0.1))

            // Content
            if sortedTasks.isEmpty && completedTasks.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // Active tasks
                        if !sortedTasks.isEmpty {
                            Section {
                                ForEach(Array(sortedTasks.enumerated()), id: \.element.id) { index, task in
                                    CheckableTaskRow(
                                        task: task,
                                        rank: index + 1,
                                        score: task.priorityScore
                                    )
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                                }
                            } header: {
                                sectionHeader("To Do", count: sortedTasks.count)
                            }
                        }

                        // Completed tasks
                        if !completedTasks.isEmpty {
                            Section {
                                ForEach(completedTasks.sorted { $0.createdAt > $1.createdAt }) { task in
                                    CompletedTaskRow(task: task)
                                }
                            } header: {
                                sectionHeader("Completed", count: completedTasks.count)
                            }
                        }
                    }
                    .padding(16)
                    .animation(.spring(duration: 0.3), value: sortedTasks.count)
                }
            }
        }
        .background(
            SuperellipseShape(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.5))
        )
        .overlay(
            SuperellipseShape(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .overlay(alignment: .top) {
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: sortedTasks.isEmpty) { _, isEmpty in
            if isEmpty && !completedTasks.isEmpty {
                // All tasks completed!
                showConfetti = true
                HapticManager.shared.perform(.levelChange)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showConfetti = false
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "list.bullet.rectangle.portrait")
                    .font(.title3)
                Text("Priority List")
                    .font(.headline)
                Spacer()

                // Progress indicator
                if statistics.totalTasks > 0 {
                    HStack(spacing: 6) {
                        Text("\(statistics.completedTasks)/\(statistics.totalTasks)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)

                        CircularProgressView(progress: statistics.completionPercentage / 100)
                            .frame(width: 20, height: 20)
                    }
                }
            }

            // Statistics row
            if statistics.totalTasks > 0 {
                HStack(spacing: 16) {
                    StatBadge(
                        icon: "exclamationmark.triangle",
                        value: "\(statistics.urgentImportantCount)",
                        label: "Urgent",
                        color: .red
                    )

                    if statistics.overdueTasks > 0 {
                        StatBadge(
                            icon: "clock.badge.exclamationmark",
                            value: "\(statistics.overdueTasks)",
                            label: "Overdue",
                            color: .orange
                        )
                    }

                    Spacer()
                }
            }
        }
        .padding(16)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text("No tasks to prioritize")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Drag tasks from the inbox to the matrix")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("(\(count))")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Supporting Views

struct CompletedTaskRow: View {
    let task: EisenTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text(task.title)
                .font(.subheadline)
                .strikethrough()
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            SuperellipseShape(cornerRadius: 8)
                .fill(Color.green.opacity(0.05))
        )
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.caption.bold())
            Text(label)
                .font(.caption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct ConfettiView: View {
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, color: Color, rotation: Double)] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles, id: \.id) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .position(x: particle.x, y: particle.y)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]

        for i in 0..<30 {
            let startX = size.width / 2
            let startY = size.height / 2

            particles.append((
                id: i,
                x: startX,
                y: startY,
                color: colors.randomElement()!,
                rotation: 0
            ))
        }

        // Animate particles
        withAnimation(EisenFlowAnimation.confetti) {
            for i in 0..<particles.count {
                particles[i].x += CGFloat.random(in: -150...150)
                particles[i].y += CGFloat.random(in: -200...100)
                particles[i].rotation = Double.random(in: 0...360)
            }
        }
    }
}

#Preview {
    HStack {
        Spacer()
        PriorityListView()
            .frame(width: 350)
    }
    .padding()
    .background(MeshGradientBackground())
    .modelContainer(for: EisenTask.self, inMemory: true)
}
