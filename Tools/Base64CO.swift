//
//  Base64.swift
//  Tools
//
//  Created by LingXiFox on 2025/9/28.
//

import SwiftUI

struct Base64CO: View {
    @State private var selection = 0
    var body: some View {
        VStack {
            Picker("模式", selection: $selection) {
                Text("键入").tag(0)
                Text("文件").tag(1)
            }
            .pickerStyle(.segmented)

            if selection == 0 {
                Base64CT()
            } else {
                Base64CF()
            }
        }
    }
}

#Preview {
    ContentView()
}
