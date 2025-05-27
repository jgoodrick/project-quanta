//
//  Schema+Utilities.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import StructuredQueries

struct CreateJoinTable<T: Table, U: Table & Identifiable, V: Table & Identifiable> where U.ID: QueryBindable, U.ID.QueryOutput: Sendable, V.ID: QueryBindable & Sendable, V.ID.QueryOutput: Sendable {
    let table: T.Type
    let tableBaseKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, U.ID>>
    let baseIDKeyPath: KeyPath<U.TableColumns, TableColumn<U.TableColumns.QueryValue, U.ID>>
    let tableTargetKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, V.ID>>
    let targetIDKeyPath: KeyPath<V.TableColumns, TableColumn<V.TableColumns.QueryValue, V.ID>>

    init(
        _ table: T.Type,
        _ base: U.Type,
        _ target: V.Type,
        of tableBaseKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, U.ID>>,
        on baseIDKeyPath: KeyPath<U.TableColumns, TableColumn<U.TableColumns.QueryValue, U.ID>>,
        to tableTargetKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, V.ID>>,
        id targetIDKeyPath: KeyPath<V.TableColumns, TableColumn<V.TableColumns.QueryValue, V.ID>>
    ) {
        self.table = table
        self.tableBaseKeyPath = tableBaseKeyPath
        self.baseIDKeyPath = baseIDKeyPath
        self.tableTargetKeyPath = tableTargetKeyPath
        self.targetIDKeyPath = targetIDKeyPath
    }

    var baseRefField: String {
        table.columns[keyPath: tableBaseKeyPath].name
    }

    var targetRefField: String {
        table.columns[keyPath: tableTargetKeyPath].name
    }

    var baseTableName: String {
        U.tableName
    }

    var baseField: String {
        U.columns[keyPath: baseIDKeyPath].name
    }

    var targetTableName: String {
        V.tableName
    }

    var targetField: String {
        V.columns[keyPath: targetIDKeyPath].name
    }

    var statement: String {
        """
        CREATE TABLE "\(table.tableName)" (
          "\(baseRefField)" INTEGER NOT NULL
            REFERENCES "\(baseTableName)"("\(baseField)")
            ON DELETE CASCADE,
          "\(targetRefField)" INTEGER NOT NULL
            REFERENCES "\(targetTableName)"("\(targetField)")
            ON DELETE CASCADE
        )
        """
    }
}

struct CreateIndex<T: Table, IndexID: Hashable & QueryBindable> where IndexID.QueryOutput: Sendable {
    let table: T.Type
    let tableBaseKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, IndexID>>

    init(
        _ table: T.Type,
        of tableBaseKeyPath: KeyPath<T.TableColumns, TableColumn<T.TableColumns.QueryValue, IndexID>>
    ) {
        self.table = table
        self.tableBaseKeyPath = tableBaseKeyPath
    }

    var field: String {
        table.columns[keyPath: tableBaseKeyPath].name
    }

    var tableName: String {
        table.tableName
    }

    var statement: String {
        """
        CREATE INDEX "index_\(tableName)_on_\(field)"
        ON "\(tableName)"("\(field)")
        """
    }
}
