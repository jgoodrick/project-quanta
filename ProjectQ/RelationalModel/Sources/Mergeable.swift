
import Foundation

protocol Mergeable {
    mutating func merge(with incoming: Self)
}

extension Mergeable {
    func merged(with incoming: Self) -> Self {
        var copy = self
        copy.merge(with: incoming)
        return copy
    }
}

extension String: Mergeable {
    mutating func merge(with incoming: String) {
        if isEmpty { self = incoming }
    }
}

extension Optional: Mergeable {
    mutating func merge(with merging: Optional<Wrapped>) where Wrapped: Mergeable {
        switch (self, merging) {
        case (.none, .none), (.some, .none): 
            break
        case (.none, .some):
            self = merging
        case (.some(var existing), .some(let incoming)):
            existing.merge(with: incoming)
            self = .some(existing)
        }
    }
    mutating func merge(with merging: Optional<Wrapped>) {
        switch (self, merging) {
        case (.none, .none), (.some, .none), (.some, .some): 
            break
        case (.none, .some): 
            self = merging
        }
    }
}

extension Array: Mergeable {
    mutating func merge(with merging: Self) where Element: Identifiable & Mergeable {
        for incoming in merging {
            var foundMatch: Bool = false
            for index in indices {
                if incoming.id == self[index].id {
                    self[index].merge(with: incoming)
                    foundMatch = true
                }
            }
            if !foundMatch {
                append(incoming)
            }
        }
    }
    mutating func merge(with merging: Self) where Element: Equatable {
        for incoming in merging {
            if first(where: { $0 == incoming }) == nil {
                append(incoming)
            }
        }
    }
    mutating func merge(with merging: Self) {
        append(contentsOf: merging)
    }
}

extension Set: Mergeable {
    mutating func merge(with merging: Self) {
        for element in merging {
            if !contains(element) {
                insert(element)
            }
        }
    }
}

extension Dictionary: Mergeable {
    mutating func merge(with merging: Self) where Value: Mergeable {
        for (key, value) in merging {
            if var existing = self[key] {
                existing.merge(with: value)
                self[key] = existing
            } else {
                self[key] = value
            }
        }
    }
    mutating func merge(with merging: Self) {
        for (key, value) in merging {
            if self[key] != nil {
                continue
            } else {
                self[key] = value
            }
        }
    }
}
