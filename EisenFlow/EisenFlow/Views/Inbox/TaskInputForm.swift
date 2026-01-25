import SwiftUI
import SwiftData

struct TaskInputForm: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [EisenTask]

    @State private var title: String = ""
    @State private var deadlineText: String = ""
    @State private var description: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @FocusState private var focusedField: Field?

    enum Field {
        case title, deadline, description
    }

    private var inboxTasks: [EisenTask] {
        tasks.filter { !$0.isInMatrix }
    }

    private var canAddTask: Bool {
        inboxTasks.count < 10 && !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        HStack(spacing: 12) {
            // Title field
            VStack(alignment: .leading, spacing: 4) {
                Text("Task")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("What needs to be done?", text: $title)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .focused($focusedField, equals: .title)
                    .onSubmit {
                        focusedField = .deadline
                    }
            }
            .frame(minWidth: 200)

            Divider()
                .frame(height: 40)

            // Deadline field
            VStack(alignment: .leading, spacing: 4) {
                Text("Deadline")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("e.g., morgen, 15-2-25", text: $deadlineText)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .focused($focusedField, equals: .deadline)
                    .onSubmit {
                        focusedField = .description
                    }
            }
            .frame(width: 150)

            Divider()
                .frame(height: 40)

            // Description field
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Optional details...", text: $description)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .focused($focusedField, equals: .description)
                    .onSubmit {
                        addTask()
                    }
            }
            .frame(minWidth: 150)

            Spacer()

            // Add button
            Button(action: addTask) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add")
                }
                .font(.body.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(canAddTask ? Color.accentColor : Color.gray)
                )
            }
            .buttonStyle(.plain)
            .disabled(!canAddTask)
            .keyboardShortcut(.return, modifiers: .command)

            // Task counter
            Text("\(inboxTasks.count)/10")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .alert("Cannot Add Task", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func addTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)

        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please enter a task title."
            showError = true
            return
        }

        guard inboxTasks.count < 10 else {
            errorMessage = "Maximum of 10 tasks in inbox. Move some tasks to the matrix first."
            showError = true
            return
        }

        // Parse deadline
        let deadline: Date? = deadlineText.isEmpty ? nil : DeadlineParser.parse(deadlineText)

        // Create task
        let task = EisenTask(
            title: trimmedTitle,
            description: description.trimmingCharacters(in: .whitespaces),
            deadline: deadline
        )

        modelContext.insert(task)
        HapticManager.shared.perform(.generic)

        // Reset form
        title = ""
        deadlineText = ""
        description = ""
        focusedField = .title
    }
}

#Preview {
    TaskInputForm()
        .modelContainer(for: EisenTask.self, inMemory: true)
        .frame(height: 80)
        .background(Color.gray.opacity(0.1))
}
