//
//  AppStorageKey.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 19.01.2025.
//


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
