import SwiftUI

struct CheckableTaskRow: View {
    @Bindable var task: EisenTask
    let rank: Int
    let score: Double

    @State private var isCompleting = false
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(task.pastelColor)
                    .frame(width: 28, height: 28)

                Text("\(rank)")
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(.white)
            }

            // Checkbox
            Button {
                completeTask()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            // Task info
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    if let deadline = task.deadline {
                        Label(DeadlineParser.relativeDescription(deadline), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(deadlineColor(deadline))
                    }

                    if let quadrant = task.quadrant {
                        Text(quadrant.title)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(quadrant.accentColor.opacity(0.2))
                            )
                            .foregroundStyle(quadrant.accentColor)
                    }
                }
            }

            Spacer()

            // Score indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f%%", score * 100))
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(.secondary)

                // Mini progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))

                        Capsule()
                            .fill(priorityColor)
                            .frame(width: geometry.size.width * score)
                    }
                }
                .frame(width: 40, height: 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            SuperellipseShape(cornerRadius: 10)
                .fill(task.pastelColor.opacity(isHovered ? 0.15 : 0.08))
        )
        .overlay(
            SuperellipseShape(cornerRadius: 10)
                .stroke(task.accentColor.opacity(isHovered ? 0.3 : 0.1), lineWidth: 1)
        )
        .opacity(isCompleting ? 0 : 1)
        .scaleEffect(isCompleting ? 0.8 : 1)
        .offset(x: isCompleting ? -20 : 0)
        .animation(EisenFlowAnimation.hover, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var priorityColor: Color {
        if score > 0.7 {
            return .red
        } else if score > 0.4 {
            return .orange
        } else {
            return .green
        }
    }

    private func deadlineColor(_ date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0

        if days < 0 {
            return .red
        } else if days == 0 {
            return .orange
        } else if days <= 2 {
            return .yellow
        } else {
            return .secondary
        }
    }

    private func completeTask() {
        HapticManager.shared.taskCompleted()

        withAnimation(EisenFlowAnimation.fadeOut) {
            isCompleting = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation {
                task.isCompleted = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        CheckableTaskRow(
            task: {
                let task = EisenTask(title: "High priority task", deadline: Date())
                task.matrixX = 0.2
                task.matrixY = 0.2
                return task
            }(),
            rank: 1,
            score: 0.85
        )

        CheckableTaskRow(
            task: {
                let task = EisenTask(title: "Medium priority task")
                task.matrixX = 0.6
                task.matrixY = 0.4
                return task
            }(),
            rank: 2,
            score: 0.5
        )

        CheckableTaskRow(
            task: {
                let task = EisenTask(title: "Completed task")
                task.matrixX = 0.8
                task.matrixY = 0.8
                task.isCompleted = true
                return task
            }(),
            rank: 3,
            score: 0.2
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
    .modelContainer(for: EisenTask.self, inMemory: true)
}
