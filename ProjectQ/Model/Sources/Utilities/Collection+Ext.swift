
public extension Collection {
    
    func maxBy<T: Comparable>(_ closure: (Element) -> T) -> Element? {
        self.max(by: { closure($0) < closure($1) })
    }
    
    func minBy<T: Comparable>(_ closure: (Element) -> T) -> Element? {
        self.max(by: { closure($0) < closure($1) })
    }

    func maxValue<T: Comparable>(of keyPath: KeyPath<Element, T>) -> T? {
        self.max(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })?[keyPath: keyPath]
    }
    
    func minValue<T: Comparable>(of keyPath: KeyPath<Element, T>) -> T? {
        self.min(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })?[keyPath: keyPath]
    }
    
    func sorted<T: Comparable>(
        by propertyOf: (Element) -> T,
        _ algorithm: (T, T) -> Bool = { $0 < $1 }
    ) -> [Element] {
        sorted(
            by: {
                algorithm(propertyOf($0), propertyOf($1))
            }
        )
    }
    
    func sorted<T: Comparable>(
        byKeyPath keyPath: KeyPath<Element, T>?,
        reversed: Bool = false
    ) -> [Element] {
        sorted(
            by: {
                guard let keyPath else { return true }
                if reversed {
                    return $0[keyPath: keyPath] < $1[keyPath: keyPath]
                } else {
                    return $0[keyPath: keyPath] > $1[keyPath: keyPath]
                }
            }
        )
    }

}

