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
    }

    let animation: LottieAnimation

    static let readableContentTypes: [UTType] = [.lottie, .dotLottie]
    static let writableContentTypes: [UTType] = []

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        animation = try LottieAnimation.from(data: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw FileWrapperError.writeNotSupported
    }
}
