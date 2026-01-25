import SwiftUI

struct InboxTaskCard: View {
    let task: EisenTask

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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

            if !task.taskDescription.isEmpty {
                Text(task.taskDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(width: 140, alignment: .leading)
        .background(
            ZStack {
                // Pastel color background
                SuperellipseShape(cornerRadius: 12)
                    .fill(task.pastelColor.opacity(0.4))

                // Glass overlay
                SuperellipseShape(cornerRadius: 12)
                    .fill(.ultraThinMaterial.opacity(0.5))
            }
        )
        .overlay(
            SuperellipseShape(cornerRadius: 12)
                .stroke(task.accentColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(
            color: task.pastelColor.opacity(isHovered ? 0.4 : 0.2),
            radius: isHovered ? 8 : 4,
            y: isHovered ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(EisenFlowAnimation.hover, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .draggable(task.id.uuidString) {
            // Drag preview
            InboxTaskCardPreview(task: task)
        }
        .onDrag {
            HapticManager.shared.dragStarted()
            return NSItemProvider(object: task.id.uuidString as NSString)
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

/// Simplified preview for drag operation
struct InboxTaskCardPreview: View {
    let task: EisenTask

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)

            if let deadline = task.deadline {
                Text(DeadlineParser.relativeDescription(deadline))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .frame(width: 130)
        .background(
            SuperellipseShape(cornerRadius: 10)
                .fill(task.pastelColor.opacity(0.6))
        )
        .overlay(
            SuperellipseShape(cornerRadius: 10)
                .stroke(task.accentColor.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

#Preview {
    HStack {
        InboxTaskCard(task: {
            let task = EisenTask(title: "Design new feature", description: "Work on the UI mockups", deadline: Date())
            return task
        }())

        InboxTaskCard(task: {
            let task = EisenTask(title: "Review PR", deadline: Calendar.current.date(byAdding: .day, value: 2, to: Date()))
            return task
        }())
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
