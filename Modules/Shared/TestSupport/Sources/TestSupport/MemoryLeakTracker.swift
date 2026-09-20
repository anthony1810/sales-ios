import Foundation
import Testing

public final class MemoryLeakTracker: @unchecked Sendable {
    private weak var instance: AnyObject?
    private let sourceLocation: SourceLocation

    public init(instance: AnyObject, sourceLocation: SourceLocation) {
        self.instance = instance
        self.sourceLocation = sourceLocation
    }

    public func verify() {
        #expect(
            instance == nil,
            "Potential memory leak: instance was not deallocated.",
            sourceLocation: sourceLocation
        )
    }
}
