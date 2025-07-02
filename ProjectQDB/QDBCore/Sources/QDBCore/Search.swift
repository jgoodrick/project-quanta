//
//  Search.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import StructuredQueries

extension TableColumn where Value == String {
    public func fuzzy(match: String) -> any QueryExpression<Bool> {
        contains(options: .fuzzy(), searchTerms: match.map(String.init))
    }
    public func contains(options: ContainsSearchOptions, searchTerms: some Collection<String>) -> any QueryExpression<Bool> {
        func expression(for term: String) -> any QueryExpression<Bool> {
            options.collation.map { self.collate($0).contains(term) } ?? self.contains(term)
        }
        switch options.match {
        case .any, .all(.unordered):
            guard let firstExpression = searchTerms.first.map(expression(for:)) else {
                return SQLQueryExpression(options.includeEmpty)
            }

            return searchTerms
                .dropFirst()
                .reduce(firstExpression) {
                    switch options.match {
                    case .any:
                        $0.or(expression(for: $1))
                    case .all:
                        $0.and(expression(for: $1))
                    }
                }
        case .all(.ordered):
            let fuzzyPattern = "%\(searchTerms.joined(separator: "%"))%"
            return expression(for: fuzzyPattern)
        }
    }
}

public struct ContainsSearchOptions {
    public let collation: Collation?
    public let includeEmpty: Bool
    public let match: Match

    public enum Match {
        case any
        case all(All)
        public enum All {
            case ordered
            case unordered
        }
    }

    public init(
        collation: Collation? = nil,
        includeEmpty: Bool = true,
        match: Match = .any
    ) {
        self.collation = collation
        self.includeEmpty = includeEmpty
        self.match = match
    }

    public static func fuzzy(includeEmpty: Bool = true) -> ContainsSearchOptions {
        .init(collation: .nocase, includeEmpty: includeEmpty, match: .all(.ordered))
    }
}
