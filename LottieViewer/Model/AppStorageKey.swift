//
//  AppStorageKey.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 19.01.2025.
//


import LottieViewerCore
import SwiftUI

@propertyWrapper
struct ShowInfoAppStorage: DynamicProperty {
    @AppStorage("settings.show-info-by-default") private var showInfoByDefault = true

    var wrappedValue: Bool {
        get { showInfoByDefault }
        nonmutating set { showInfoByDefault = newValue }
    }

    var projectedValue: Binding<Bool> {
        $showInfoByDefault
    }
}

@propertyWrapper
struct RenderingEngineAppStorage: DynamicProperty {
    @AppStorage(SharedDefaultsKey.renderingEngine, store: .shared)
    private var renderingEngine = LottieLibrary.default

    var wrappedValue: LottieLibrary {
        get { renderingEngine }
        nonmutating set { renderingEngine = newValue }
    }

    var projectedValue: Binding<LottieLibrary> {
        $renderingEngine
    }
}
