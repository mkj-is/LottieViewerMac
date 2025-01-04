//
//  LottieViewerDocument.swift
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

struct LottieViewerDocument: FileDocument {

    enum FileWrapperError: Error {
        case writeNotSupported
        case noFilename
        case noDotLottieAnimation
        case unknownContentType
    }

    let animation: LottieAnimation

    static let readableContentTypes: [UTType] = [.lottie, .dotLottie]
    static let writableContentTypes: [UTType] = []

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        if configuration.contentType == .lottie {
            animation = try LottieAnimation.from(data: data)
        } else if configuration.contentType == .dotLottie {
            animation = try LottieViewerDocument.loadDotLottie(configuration: configuration, data: data)
        } else {
            throw FileWrapperError.unknownContentType
        }
    }

    private static func loadDotLottie(configuration: ReadConfiguration, data: Data) throws -> LottieAnimation {
        guard let filename = configuration.file.filename else {
            throw FileWrapperError.noFilename
        }
        let dotLottieFile = try DotLottieFile.SynchronouslyBlockingCurrentThread.loadedFrom(data: data, filename: filename).get()
        guard let firstAnimation = dotLottieFile.animations.first else {
            throw FileWrapperError.noDotLottieAnimation
        }
        return firstAnimation.animation
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw FileWrapperError.writeNotSupported
    }
}
