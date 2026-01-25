import SwiftUI
import SwiftData

struct InboxPanel: View {
    @Query(filter: #Predicate<EisenTask> { $0.matrixX == nil })
    private var inboxTasks: [EisenTask]

    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            // Divider line
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)

            VStack(spacing: 12) {
                // Header with expand/collapse
                HStack {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "tray.fill")
                            Text("Inbox")
                                .font(.headline)
                            Text("(\(inboxTasks.count))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.semibold))
                                .rotationEffect(.degrees(isExpanded ? 0 : -90))
                        }
                        .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    if !inboxTasks.isEmpty {
                        Text("Drag tasks to the matrix to prioritize")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if isExpanded {
                    // Input form
                    GlassCard(cornerRadius: 12, padding: 0) {
                        TaskInputForm()
                    }
                    .padding(.horizontal, 16)

                    // Inbox tasks scroll view
                    if inboxTasks.isEmpty {
                        emptyState
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(inboxTasks.sorted { $0.createdAt > $1.createdAt }) { task in
                                    InboxTaskCard(task: task)
                                        .transition(.asymmetric(
                                            insertion: .scale.combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .animation(.spring(duration: 0.3), value: inboxTasks.count)
                    }
                }
            }
            .background(
                // Subtle glass background for the panel
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.5))
            )
        }
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                Text("No tasks in inbox")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Add a task above to get started")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 24)
            Spacer()
        }
    }
}

#Preview {
    VStack {
        Spacer()
        InboxPanel()
    }
    .background(MeshGradientBackground())
    .modelContainer(for: EisenTask.self, inMemory: true)
}
