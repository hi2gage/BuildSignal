// MARK: - Schema - Mixed Warnings

import Foundation

@available(*, deprecated, message: "Use SchemaBuilder instead")
public class LegacySchema {
    public var tables: [String] = []
    public init() {}

    @available(*, deprecated)
    public func createTable(_ name: String) {
        tables.append(name)
    }
}

public class schema_builder {
    // Naming issues
    public var TABLE_PREFIX = "app_"
    public var Column_Types = ["INT", "VARCHAR", "BOOL"]
    private var _migrations: [String] = []

    // Unused
    private var unusedVersion = 1
    private var unusedTimestamp: Date?

    public init() {}

    public func migrate() async {
        // Deprecated usage
        let schema = LegacySchema()
        schema.createTable("users")
        schema.createTable("items")
        schema.createTable("orders")

        // Unused locals
        let sql1 = "CREATE TABLE"
        let sql2 = "ALTER TABLE"
        let sql3 = "DROP TABLE"
        let sql4 = "INSERT INTO"
        let sql5 = "UPDATE"

        // Never mutated
        var currentSchema = ["users", "items"]
        print(currentSchema)

        // Conditional cast
        let tables: [String] = ["a", "b"]
        if let _ = tables as? [String] {
            print("always")
        }

        // Empty catch
        do {
            try someThrowingOperation()
        } catch {
            // Warning: empty catch
        }
    }

    private func someThrowingOperation() throws {
        throw NSError(domain: "test", code: 1)
    }

    // Unused parameters
    public func addColumn(table: String, name: String, type: String, nullable: Bool, default: Any?) {
        print("adding column")
    }
}
