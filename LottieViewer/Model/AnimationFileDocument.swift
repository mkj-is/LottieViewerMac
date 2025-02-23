//
//  AnimationFileDocument.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI
import UniformTypeIdentifiers
@preconcurrency import Lottie
import LottieViewerCore
@preconcurrency import RiveRuntime

struct AnimationFileDocument: FileDocument {

    enum FileWrapperError: Error {
        case writeNotSupported
        case noFilename
        case unknownContentType
    }

    let animationFile: AnimationFile
    let parseTime: TimeInterval

    static let readableContentTypes: [UTType] = [.lottie, .dotLottie, .rive]

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let parsingTimeStart: Date = .now

        if configuration.contentType == .lottie {
            let animation = try LottieAnimation.from(data: data)
            animationFile = LottieAnimationFile(animation: animation)
        } else if configuration.contentType == .dotLottie {
            let file = try AnimationFileDocument.loadDotLottie(configuration: configuration, data: data)
            animationFile = DotLottieAnimationFile(file: file)
        } else if configuration.contentType == .rive {
            let file = try RiveFile(data: data, loadCdn: false)
            animationFile = RiveAnimationFile(file: file)
        } else {
            throw FileWrapperError.unknownContentType
        }

        parseTime = Date.now.timeIntervalSince(parsingTimeStart)
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
