//
//  Logger.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
import Logging

let logger: Logger = {
    var logger = Logger(
        label: "com.nuomi1.bus.mock",
        factory: { label in BusMockLogHandler(label: label) }
    )

    logger.logLevel = .debug
    return logger
}()

struct BusMockLogHandler: LogHandler {

    let label: String

    init(label: String) {
        self.label = label
    }

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }

    private var prettyMetadata: String?
    var metadata: Logger.Metadata = [:] {
        didSet {
            prettyMetadata = prettify(metadata)
        }
    }

    var logLevel: Logger.Level = .info

    // swiftlint:disable function_parameter_count

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        #if DEBUG
        let prettyMetadata = metadata?.isEmpty ?? true
            ? self.prettyMetadata
            : prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

        let fileName = file.split(separator: "/").last ?? ""

        print("\(timestamp()) \(level) \(label) :\(prettyMetadata.map { " \($0)" } ?? "") [\(fileName):\(line)] \(function) > \(message)")
        #endif
    }

    // swiftlint:enable function_parameter_count

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
    }

    private func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }
}
