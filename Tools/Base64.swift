//
//  Base64.swift
//  Tools
//
//  Created by LingXiFox on 2025/9/29.
//

import SwiftUI

struct Base64: View {
    var body: some View{
        TabView {
            NavigationStack {
                Base64CO()
                    .navigationTitle("编码")
            }
            .tabItem { Label("编码", systemImage: "arrow.up.circle") }

            NavigationStack {
                Base64DE()
                    .navigationTitle("解码")
            }
            .tabItem { Label("解码", systemImage: "arrow.down.circle") }
        }
    }
}

#Preview {
    ContentView()
}
//
