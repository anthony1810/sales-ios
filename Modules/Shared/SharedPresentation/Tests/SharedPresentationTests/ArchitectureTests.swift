import Foundation
import Testing

struct ArchitectureTests {

    @Test func presentationTargets_everySourceFile_importsNoUIFramework() throws {
        let presentationSources = try presentationSourceFiles(under: modulesDirectory())
        try #require(presentationSources.isEmpty == false)

        for file in presentationSources {
            let source = try String(contentsOf: file, encoding: .utf8)
            let forbidden = source.split(separator: "\n").filter {
                $0.hasPrefix("import SwiftUI") || $0.hasPrefix("import UIKit")
            }
            #expect(
                forbidden.isEmpty,
                "\(file.lastPathComponent) imports a UI framework: \(forbidden)"
            )
        }
    }

    // MARK: - Helpers

    private func modulesDirectory() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func presentationSourceFiles(under modules: URL) throws -> [URL] {
        let enumerator = FileManager.default.enumerator(
            at: modules,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        var files: [URL] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            let components = url.pathComponents
            guard let sourcesIndex = components.firstIndex(of: "Sources"),
                components.indices.contains(sourcesIndex + 1),
                components[sourcesIndex + 1].hasSuffix("Presentation")
            else { continue }
            files.append(url)
        }
        return files
    }
}
