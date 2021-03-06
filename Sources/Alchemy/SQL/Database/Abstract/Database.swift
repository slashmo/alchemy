import Foundation
import PostgresKit

/// A generic type to represent any database you might be interacting
/// with. Currently, the only two implementations are
/// `PostgresDatabase` and `MySQLDatabase`. The QueryBuilder and Rune
/// ORM are built on top of this abstraction.
public protocol Database {
    /// Any migrations associated with this database, whether applied
    /// yet or not.
    var migrations: [Migration] { get set }
    
    /// Functions around compiling SQL statments for this database's
    /// SQL dialect when using the QueryBuilder or Rune.
    var grammar: Grammar { get }
    
    /// Start a QueryBuilder query on this database. See `Query` or
    /// QueryBuilder guides.
    ///
    /// Usage:
    /// ```swift
    /// database.query()
    ///     .from(table: "users")
    ///     .where("id" == 1)
    ///     .first()
    ///     .whenSuccess { row in
    ///         guard let row = row else {
    ///             return print("No row found :(")
    ///         }
    ///
    ///         print("Got a row with fields: \(row.allColumns)")
    ///     }
    /// ```
    ///
    /// - Returns: The start of a QueryBuilder `Query`.
    func query() -> Query
    
    /// Run a parameterized query on the database. Parameterization
    /// helps protect against SQL injection.
    ///
    /// Usage:
    /// ```swift
    /// // No bindings
    /// db.runRawQuery("SELECT * FROM users where id = 1")
    ///     .whenSuccess { rows
    ///         guard let first = rows.first else {
    ///             return print("No rows found :(")
    ///         }
    ///
    ///         print("Got a user row with columns \(rows.allColumns)!")
    ///     }
    ///
    /// // Bindings, to protect against SQL injection.
    /// db.runRawQuery("SELECT * FROM users where id = ?", values = [.int(1)])
    ///     .whenSuccess { rows
    ///         ...
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - sql: The SQL string with '?'s denoting variables that
    ///     should be parameterized.
    ///   - values: An array, `[DatabaseValue]`, that will replace the
    ///     '?'s in `sql`. Ensure there are the same amnount of values
    ///     as there are '?'s in `sql`.
    /// - Returns: An `EventLoopFuture` of the rows returned by the
    ///   query.
    func runRawQuery(_ sql: String, values: [DatabaseValue]) -> EventLoopFuture<[DatabaseRow]>
    
    /// Called when the database connection will shut down.
    ///
    /// - Throws: Any error that occurred when shutting down.
    func shutdown() throws
}

// Extensions for default data. Docs above.
extension Database {
    public func query() -> Query {
        Query(database: self)
    }
    
    public func runRawQuery(_ sql: String, values: [DatabaseValue] = []) -> EventLoopFuture<[DatabaseRow]> {
        self.runRawQuery(sql, values: values)
    }
}
