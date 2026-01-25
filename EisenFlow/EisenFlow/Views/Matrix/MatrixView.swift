import SwiftUI
import SwiftData

struct MatrixView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [EisenTask]

    @State private var hoveredQuadrant: Quadrant?
    @State private var horizontalRipple = false
    @State private var verticalRipple = false
    @State private var previousQuadrant: Quadrant?

    private var matrixTasks: [EisenTask] {
        tasks.filter { $0.isInMatrix && !$0.isCompleted }
    }

    var body: some View {
        GeometryReader { geometry in
            let matrixSize = geometry.size
            let padding: CGFloat = 16

            ZStack {
                // Quadrant backgrounds
                ForEach(Quadrant.allCases) { quadrant in
                    let frame = quadrant.frame(in: CGSize(
                        width: matrixSize.width - padding * 2,
                        height: matrixSize.height - padding * 2
                    ))
                    let adjustedFrame = CGRect(
                        x: frame.origin.x + padding,
                        y: frame.origin.y + padding,
                        width: frame.width - 4,
                        height: frame.height - 4
                    )

                    QuadrantView(
                        quadrant: quadrant,
                        isHighlighted: hoveredQuadrant == quadrant,
                        frame: adjustedFrame
                    )
                }

                // Axis lines
                AxisLines(
                    size: matrixSize,
                    horizontalRipple: $horizontalRipple,
                    verticalRipple: $verticalRipple
                )

                // Tasks on matrix
                ForEach(matrixTasks) { task in
                    DraggableTaskCard(task: task, matrixSize: matrixSize)
                }
            }
            .onDrop(of: [.text], delegate: MatrixDropDelegate(
                matrixSize: matrixSize,
                modelContext: modelContext,
                tasks: tasks,
                hoveredQuadrant: $hoveredQuadrant,
                previousQuadrant: $previousQuadrant,
                onHorizontalCrossing: {
                    horizontalRipple = true
                    HapticManager.shared.axisCrossed()
                },
                onVerticalCrossing: {
                    verticalRipple = true
                    HapticManager.shared.axisCrossed()
                }
            ))
        }
    }
}

// MARK: - Drop Delegate

struct MatrixDropDelegate: DropDelegate {
    let matrixSize: CGSize
    let modelContext: ModelContext
    let tasks: [EisenTask]
    @Binding var hoveredQuadrant: Quadrant?
    @Binding var previousQuadrant: Quadrant?
    let onHorizontalCrossing: () -> Void
    let onVerticalCrossing: () -> Void

    func dropEntered(info: DropInfo) {
        updateHoverState(at: info.location)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        let location = info.location
        let newQuadrant = quadrantAt(location)

        // Detect axis crossing
        if let prev = previousQuadrant, prev != newQuadrant {
            let crossedVertical = (prev.isUrgent != newQuadrant.isUrgent)
            let crossedHorizontal = (prev.isImportant != newQuadrant.isImportant)

            if crossedVertical {
                onVerticalCrossing()
            }
            if crossedHorizontal {
                onHorizontalCrossing()
            }
        }

        previousQuadrant = newQuadrant
        updateHoverState(at: location)

        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }

        itemProvider.loadObject(ofClass: NSString.self) { object, error in
            guard let idString = object as? String,
                  let taskId = UUID(uuidString: idString) else { return }

            DispatchQueue.main.async {
                // Normalize coordinates to 0-1 range
                let normalizedX = info.location.x / matrixSize.width
                let normalizedY = info.location.y / matrixSize.height

                // Clamp to valid range
                let clampedX = max(0.05, min(0.95, normalizedX))
                let clampedY = max(0.05, min(0.95, normalizedY))

                // Find and update task
                if let task = tasks.first(where: { $0.id == taskId }) {
                    withAnimation(EisenFlowAnimation.drop) {
                        task.matrixX = clampedX
                        task.matrixY = clampedY
                    }
                    HapticManager.shared.taskDropped()
                }
            }
        }

        hoveredQuadrant = nil
        previousQuadrant = nil
        return true
    }

    func dropExited(info: DropInfo) {
        hoveredQuadrant = nil
        previousQuadrant = nil
    }

    private func updateHoverState(at location: CGPoint) {
        hoveredQuadrant = quadrantAt(location)
    }

    private func quadrantAt(_ point: CGPoint) -> Quadrant {
        let x = point.x / matrixSize.width
        let y = point.y / matrixSize.height
        return Quadrant.from(x: x, y: y)
    }
}

#Preview {
    MatrixView()
        .background(MeshGradientBackground())
        .modelContainer(for: EisenTask.self, inMemory: true)
}
