//
//  Base64DT.swift
//  Tools
//
//  Created by LingXiFox on 2025/9/29.
//

import SwiftUI
import Foundation

struct Base64DT: View {
    @State private var InputText: String = ""
    @State private var OutputText: String = ""
    @State private var ShowCopied: Bool = false
    func decodeBase64ToData(_ base64: String) -> Data? {
        var s = base64.replacingOccurrences(of: "-", with: "+")
                      .replacingOccurrences(of: "_", with: "/")
        s = s.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        let pad = (4 - s.count % 4) % 4
        if pad > 0 { s.append(String(repeating: "=", count: pad)) }
        return Data(base64Encoded: s, options: .ignoreUnknownCharacters)
    }
    func decodeBase64ToString(_ base64: String) -> String? {
        guard let data = decodeBase64ToData(base64) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    var body: some View {
        VStack(spacing: 20)
        {
            TextField("输入需要解码的文本",text: $InputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Base64解码")
            {
                OutputText = decodeBase64ToString(InputText) ?? "解码失败"
            }
            if !OutputText.isEmpty
            {
                VStack
                {
                    Text("解码结果")
                    Text(OutputText)
                        .font(.system(size: 14,weight: .bold,design: .monospaced))
                        .padding()
                    Button("复制结果")
                    {
                        let pastboard = NSPasteboard.general
                        pastboard.clearContents()
                        pastboard.setString(OutputText, forType: .string)
                        ShowCopied = true
                    }
                }
                .alert(isPresented: $ShowCopied){
                    Alert(title: Text("已复制"),message: Text("结果已复制"))
                }
                .frame(width: 400,height: 300)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
