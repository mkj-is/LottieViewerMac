//
//  LottieViewerTests.swift
//  LottieViewerTests
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import Testing
import UniformTypeIdentifiers
import LottieViewerCore
@testable import LottieViewer

struct SupportedFileExtensionTests {

    @Test(arguments: [
        ("json", SupportedFileExtension.lottie),
        ("lot", SupportedFileExtension.lot),
        ("LOT", SupportedFileExtension.lot),
        ("lottie", SupportedFileExtension.dotLottie),
        ("riv", SupportedFileExtension.rive)
    ])
    func recognisesExtension(_ pathExtension: String, format: SupportedFileExtension) {
        #expect(SupportedFileExtension(pathExtension: pathExtension) == format)
    }

    /// `lot` and `json` are two spellings of one format, callers must treat them alike.
    @Test(arguments: [
        (SupportedFileExtension.lottie, true),
        (SupportedFileExtension.lot, true),
        (SupportedFileExtension.dotLottie, false),
        (SupportedFileExtension.rive, false)
    ])
    func identifiesRawLottieJSON(_ format: SupportedFileExtension, isLottieJSON: Bool) {
        #expect(format.isLottieJSON == isLottieJSON)
    }

    @Test(arguments: ["", "txt", "lottiejson", "lo"])
    func rejectsUnknownExtension(_ pathExtension: String) {
        #expect(SupportedFileExtension(pathExtension: pathExtension) == nil)
    }
}

struct LottieUTTypeTests {

    /// `lot` has no built-in identifier, the app declares it in its Info.plist.
    @Test func lotResolvesToTheDeclaredType() {
        #expect(UTType(filenameExtension: "lot") == .lot)
        #expect(UTType(mimeType: "video/lottie+json") == .lot)
    }

    /// The document reader branches on conformance, not equality.
    @Test func lotIsReadAsLottieJSON() {
        #expect(UTType.lot.conforms(to: .lottie))
        #expect(AnimationFileDocument.readableContentTypes.contains(.lot))
    }

    @Test func lotDoesNotCollideWithTheOtherFormats() {
        #expect(!UTType.lot.conforms(to: .dotLottie))
        #expect(!UTType.lot.conforms(to: .rive))
    }
}
