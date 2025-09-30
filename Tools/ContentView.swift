//
//  ContentView.swift
//  Tools
//
//  Created by LingXiFox on 2025/9/27.
//

import SwiftUI

struct ContentView: View
{
    var body: some View
    {
        TabView
        {
            Base64()
                .tabItem
                {
                    Text("Base64编码")
                }
            Haxi()
                .tabItem
                {
                    Text("哈希编码")
                }
            SettingView()
                .tabItem
                {
                    Text("设置")
                }
        }
    }
}

#Preview {
    ContentView()
}
