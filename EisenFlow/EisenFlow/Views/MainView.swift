import SwiftUI
import SwiftData

struct MainView: View {
    @Query private var tasks: [EisenTask]
    @State private var showPriorityList = true

    private var matrixTasks: [EisenTask] {
        tasks.filter { $0.isInMatrix }
    }

    var body: some View {
        ZStack {
            // Background
            MeshGradientBackground()

            // Main content
            VStack(spacing: 0) {
                // Top toolbar
                toolbar

                // Main area
                HStack(spacing: 0) {
                    // Matrix (main area)
                    MatrixView()
                        .padding(20)

                    // Priority list sidebar
                    if showPriorityList {
                        PriorityListView()
                            .frame(width: 320)
                            .padding(.trailing, 20)
                            .padding(.vertical, 20)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }

                // Inbox panel (bottom)
                InboxPanel()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var toolbar: some View {
        HStack {
            // App title
            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))

                Text("EisenFlow")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Stats
            if !matrixTasks.isEmpty {
                let stats = PrioritizationEngine.statistics(tasks)
                HStack(spacing: 16) {
                    Label("\(stats.pendingTasks) pending", systemImage: "clock")
                    Label("\(stats.completedTasks) done", systemImage: "checkmark.circle")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            // Toggle priority list
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    showPriorityList.toggle()
                }
            } label: {
                Label(
                    showPriorityList ? "Hide List" : "Show List",
                    systemImage: showPriorityList ? "sidebar.right" : "sidebar.left"
                )
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
            .keyboardShortcut("l", modifiers: .command)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.3))
        )
    }
}

#Preview {
    MainView()
        .modelContainer(for: EisenTask.self, inMemory: true)
        .frame(width: 1200, height: 800)
}
