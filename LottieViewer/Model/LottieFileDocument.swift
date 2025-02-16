//
//  LottieFileDocument.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI
import UniformTypeIdentifiers
@preconcurrency import Lottie
import LottieViewerCore

struct LottieFileDocument: FileDocument {

    struct Animation: Sendable {
        let data: Data
        let configuration: DotLottieConfiguration?
        let animation: LottieAnimation
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
            animations = [Animation(data: data, configuration: nil, animation: animation)]
        } else if configuration.contentType == .dotLottie {
            let file = try LottieFileDocument.loadDotLottie(configuration: configuration, data: data)
            animations = file.animations.map { animation in
                Animation(data: data, configuration: animation.configuration, animation: animation.animation)
            }
        } else {
            throw FileWrapperError.unknownContentType
        }
    }

    private static func loadDotLottie(configuration: ReadConfiguration, data: Data) throws -> DotLottieFile {
        guard let filename = configuration.file.filename else {
            throw FileWrapperError.noFilename
        }
        return try DotLottieFile.SynchronouslyBlockingCurrentThread.loadedFrom(data: data, filename: filename).get()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw FileWrapperError.writeNotSupported
    }
}
