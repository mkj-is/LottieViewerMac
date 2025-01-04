//
//  LottieFileDocument.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI
import UniformTypeIdentifiers
import Lottie

extension UTType {
    static var dotLottie: UTType {
        UTType(importedAs: "io.dotlottie.lottie")
    }

    static var lottie: UTType {
        UTType(importedAs: "com.airbnb.lottie")
    }
}

struct LottieFileDocument: FileDocument {

    struct Animation: Identifiable {
        let id: String
        let animation: LottieAnimation

        init(id: String?, animation: LottieAnimation) {
            self.id = id ?? "Animation"
            self.animation = animation
        }
    }

    enum FileWrapperError: Error {
        case writeNotSupported
        case noFilename
        case unknownContentType
    }

    let animations: [Animation]

    static let readableContentTypes: [UTType] = [.lottie, .dotLottie]
    static let writableContentTypes: [UTType] = []

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        if configuration.contentType == .lottie {
            let animation = try LottieAnimation.from(data: data)
            animations = [Animation(id: configuration.file.filename, animation: animation)]
        } else if configuration.contentType == .dotLottie {
            animations = try LottieFileDocument.loadDotLottie(configuration: configuration, data: data)
        } else {
            throw FileWrapperError.unknownContentType
        }
    }

    private static func loadDotLottie(configuration: ReadConfiguration, data: Data) throws -> [Animation] {
        guard let filename = configuration.file.filename else {
            throw FileWrapperError.noFilename
        }
        let dotLottieFile = try DotLottieFile.SynchronouslyBlockingCurrentThread.loadedFrom(data: data, filename: filename).get()
        return dotLottieFile.animations.map { animation in
            Animation(id: animation.configuration.id, animation: animation.animation)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw FileWrapperError.writeNotSupported
    }
}
