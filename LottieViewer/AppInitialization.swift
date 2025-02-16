//
//  AppInitialization.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 10.01.2025.
//

@preconcurrency import Lottie
import LottieViewerCore
import OSLog

struct AppInitialization {
    func setup() {
        setupLottieLogging()
    }

    private func setupLottieLogging() {
        let logger = Logger(subsystem: Constant.lottieBundleIdentifier, category: Constant.loggingCategory)
        LottieLogger.shared = LottieLogger(warn: { message, _, _ in
            let message = message()
            logger.warning("\(message)")
        }, info: { message in
            let message = message()
            logger.info("\(message)")
        })
    }
}
