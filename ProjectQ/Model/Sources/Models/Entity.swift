//
//import Combine
//import ComposableArchitecture
//import SwiftUI
//
//final class Entity<Value: Identifiable>: Observable, @unchecked Sendable {
//    
//    private let lock = NSRecursiveLock()
//    private var _value: Value {
//        willSet {
//            do {
//                try setter(_value.id, newValue)
//            } catch {
//                @Dependency(\.logger) var log
//                log.error("\(error.localizedDescription)")
//            }
//        }
//    }
//    private var setter: (Value.ID, Value?) throws -> Void
//    private let registrar = ObservationRegistrar()
//    
//    var value: Value {
//        get {
//            self.registrar.access(self, keyPath: \.value)
//            return self.lock.withLock { self._value }
//        }
//        set {
//            self.registrar.willSet(self, keyPath: \.value)
//            defer { self.registrar.didSet(self, keyPath: \.value) }
//            self.lock.withLock {
//                self._value = newValue
//            }
//        }
//    }
//
//    init(
//        initialValue: Value,
//        setter: @escaping (Value.ID, Value?) throws -> Void
//    ) {
//        self._value = initialValue
//        self.setter = setter
//    }
//            
//}
