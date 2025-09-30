//
//  Base64DF.swift
//  Tools
//
//  Created by LingXiFox on 2025/9/29.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct Base64DF: View {
    @State private var importedText: String = ""
    @State private var outputString: String = ""
    @State private var FileName: String = ""
    private var inputStatus: String { importedText.isEmpty ? "导入失败或未选择文件" : "导入成功" }
    private func save()
    {
        let panel = NSSavePanel()
        panel.title = "导出"
        panel.nameFieldStringValue = "Default.txt"
        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = [.plainText]
        } else {
            panel.allowedFileTypes = ["txt"]
        }
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true
        panel.begin
        {   resp in
            guard resp == .OK, let url = panel.url else { return }
            do {
                guard let data = outputString.data(using: .utf8) else {
                    throw NSError(domain: "EncodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法将字符串转为 UTF-8 数据"])
                }
                try data.write(to: url, options: .atomic)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }
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
            HStack(spacing: 20){
                Button("选择文件")
                {
                    let panel = NSOpenPanel()
                    if #available(macOS 26.0, *) {
                        panel.allowedContentTypes = [.plainText]
                    } else {
                        panel.allowedFileTypes = ["txt"]
                    }
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    if panel.runModal() == .OK, let url = panel.url
                    {
                        if let data = try? Data(contentsOf: url),let content = String(data: data, encoding: .utf8) {
                            importedText = content
                            FileName = url.lastPathComponent
                        }
                    }
                }
                Text("导入文件名：\(FileName)")
                    .padding()
                Text("状态：\(inputStatus)")
                    .padding()
            }
            Button("Base64解码")
            {
                outputString = decodeBase64ToString(importedText) ?? ""
            }
            if !outputString.isEmpty
            {
                VStack(spacing: 12)
                {
                    Text("OK!")
                    Button("另存为"){
                        save()
                    }
                }
            }
            else
            {
                Text("尚未解码或解码失败")
            }
        }
    }
}

#Preview {
    Base64DF()
}
