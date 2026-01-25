import SwiftUI
import SwiftData

struct DraggableTaskCard: View {
    @Bindable var task: EisenTask
    let matrixSize: CGSize

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isHovered = false

    private var position: CGPoint {
        CGPoint(
            x: (task.matrixX ?? 0.5) * matrixSize.width,
            y: (task.matrixY ?? 0.5) * matrixSize.height
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)
                .foregroundStyle(.primary)

            if let deadline = task.deadline {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(DeadlineParser.relativeDescription(deadline))
                        .font(.caption)
                }
                .foregroundStyle(deadlineColor(deadline))
            }
        }
        .padding(10)
        .frame(width: 120, alignment: .leading)
        .background(
            ZStack {
                SuperellipseShape(cornerRadius: 10)
                    .fill(task.pastelColor.opacity(0.5))

                SuperellipseShape(cornerRadius: 10)
                    .fill(.ultraThinMaterial.opacity(0.4))
            }
        )
        .overlay(
            SuperellipseShape(cornerRadius: 10)
                .stroke(task.accentColor.opacity(0.4), lineWidth: 1)
        )
        .scaleEffect(task.scaleFactor * (isDragging ? 1.1 : (isHovered ? 1.03 : 1.0)))
        .shadow(
            color: task.pastelColor.opacity(isDragging ? 0.5 : 0.3),
            radius: task.shadowRadius * (isDragging ? 1.5 : 1),
            y: isDragging ? 8 : 4
        )
        .position(
            x: position.x + dragOffset.width,
            y: position.y + dragOffset.height
        )
        .animation(isDragging ? nil : EisenFlowAnimation.drop, value: position)
        .animation(EisenFlowAnimation.hover, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        HapticManager.shared.dragStarted()
                    }
                    dragOffset = value.translation
                }
                .onEnded { value in
                    isDragging = false

                    let newX = (position.x + value.translation.width) / matrixSize.width
                    let newY = (position.y + value.translation.height) / matrixSize.height

                    // Clamp to matrix bounds
                    let clampedX = max(0.05, min(0.95, newX))
                    let clampedY = max(0.05, min(0.95, newY))

                    withAnimation(EisenFlowAnimation.drop) {
                        task.matrixX = clampedX
                        task.matrixY = clampedY
                        dragOffset = .zero
                    }

                    HapticManager.shared.taskDropped()
                }
        )
        .contextMenu {
            Button("Remove from Matrix") {
                withAnimation {
                    task.matrixX = nil
                    task.matrixY = nil
                }
            }

            if !task.isCompleted {
                Button("Mark as Completed") {
                    withAnimation {
                        task.isCompleted = true
                    }
                    HapticManager.shared.taskCompleted()
                }
            }

            Divider()

            Button("Delete Task", role: .destructive) {
                // Note: Deletion should be handled by parent view with modelContext
            }
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
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            MeshGradientBackground()

            DraggableTaskCard(
                task: {
                    let task = EisenTask(title: "Important Task", deadline: Date())
                    task.matrixX = 0.25
                    task.matrixY = 0.25
                    return task
                }(),
                matrixSize: geometry.size
            )
        }
    }
    .modelContainer(for: EisenTask.self, inMemory: true)
}
