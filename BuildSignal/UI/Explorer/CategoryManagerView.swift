import SwiftUI
import UniformTypeIdentifiers

/// View for managing custom warning categories.
struct CategoryManagerView: View {
    @ObservedObject var categoryManager: CategoryManager
    @Environment(\.dismiss) private var dismiss
    @State private var editingCategory: WarningCategory?
    @State private var showingNewCategory = false
    @State private var showingImporter = false
    @State private var showingExporter = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            List {
                // Built-in categories (read-only)
                Section("Built-in Categories") {
                    ForEach(WarningCategory.builtInCategories) { category in
                        CategoryRowView(category: category, isBuiltIn: true)
                    }
                }

                // Custom categories
                Section("Custom Categories") {
                    if categoryManager.customCategories.isEmpty {
                        Text("No custom categories yet")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(categoryManager.customCategories) { category in
                            CategoryRowView(category: category, isBuiltIn: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingCategory = category
                                }
                                .contextMenu {
                                    Button {
                                        editingCategory = category
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }

                                    Button {
                                        _ = categoryManager.duplicateCategory(category)
                                    } label: {
                                        Label("Duplicate", systemImage: "doc.on.doc")
                                    }

                                    Divider()

                                    Button(role: .destructive) {
                                        categoryManager.deleteCategory(category)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .onDelete { offsets in
                            categoryManager.deleteCategories(at: offsets)
                        }
                        .onMove { source, destination in
                            categoryManager.moveCategories(from: source, to: destination)
                        }
                    }
                }
            }
            .navigationTitle("Warning Categories")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingNewCategory = true
                        } label: {
                            Label("New Category", systemImage: "plus")
                        }

                        Divider()

                        Button {
                            showingImporter = true
                        } label: {
                            Label("Import...", systemImage: "square.and.arrow.down")
                        }

                        Button {
                            exportCategories()
                        } label: {
                            Label("Export All...", systemImage: "square.and.arrow.up")
                        }
                        .disabled(categoryManager.customCategories.isEmpty)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewCategory) {
                CategoryEditorView(
                    category: categoryManager.createNewCategory(),
                    isNew: true
                ) { newCategory in
                    categoryManager.addCategory(newCategory)
                }
            }
            .sheet(item: $editingCategory) { category in
                CategoryEditorView(
                    category: category,
                    isNew: false
                ) { updatedCategory in
                    categoryManager.updateCategory(updatedCategory)
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: CategoryDocument(categories: categoryManager.customCategories),
                contentType: .json,
                defaultFilename: "BuildSignal-Categories"
            ) { result in
                if case .failure(let error) = result {
                    print("Export failed: \(error)")
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    private func exportCategories() {
        showingExporter = true
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let imported = try categoryManager.importCategories(from: url)
                categoryManager.addImportedCategories(imported)
            } catch {
                print("Import failed: \(error)")
            }
        case .failure(let error):
            print("File selection failed: \(error)")
        }
    }
}

// MARK: - Category Row View

private struct CategoryRowView: View {
    let category: WarningCategory
    let isBuiltIn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(category.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(category.name)
                        .font(.headline)

                    if isBuiltIn {
                        Text("Built-in")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary)
                            .cornerRadius(4)
                    }
                }

                Text("\(category.patterns.count) pattern\(category.patterns.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Category Editor View

struct CategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var category: WarningCategory
    @State private var patternsText: String
    let isNew: Bool
    let onSave: (WarningCategory) -> Void

    init(category: WarningCategory, isNew: Bool, onSave: @escaping (WarningCategory) -> Void) {
        self._category = State(initialValue: category)
        self._patternsText = State(initialValue: category.patterns.joined(separator: "\n"))
        self.isNew = isNew
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $category.name)

                    Picker("Icon", selection: $category.icon) {
                        ForEach(WarningCategory.availableIcons, id: \.self) { icon in
                            Label(icon, systemImage: icon)
                                .tag(icon)
                        }
                    }

                    Picker("Color", selection: $category.colorName) {
                        ForEach(WarningCategory.availableColors, id: \.name) { item in
                            HStack {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 16, height: 16)
                                Text(item.name.capitalized)
                            }
                            .tag(item.name)
                        }
                    }
                }

                Section {
                    TextEditor(text: $patternsText)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 150)
                } header: {
                    Text("Patterns (one per line)")
                } footer: {
                    Text("Patterns are matched against warning messages. Supports regex.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Preview") {
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundStyle(category.color)

                        Text(category.name)
                            .font(.headline)

                        Spacer()

                        Text("\(parsePatterns().count) patterns")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isNew ? "New Category" : "Edit Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isNew ? "Add" : "Save") {
                        saveCategory()
                    }
                    .disabled(category.name.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }

    private func parsePatterns() -> [String] {
        patternsText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func saveCategory() {
        category.patterns = parsePatterns()
        onSave(category)
        dismiss()
    }
}

// MARK: - Category Document for Export

struct CategoryDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let categories: [WarningCategory]

    init(categories: [WarningCategory]) {
        self.categories = categories
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        categories = try WarningCategory.importFromJSON(data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try WarningCategory.exportToJSON(categories)
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    CategoryManagerView(categoryManager: CategoryManager.shared)
}
