//
//  Base64CF.swift
//  Tools
//
//  Created by LingXiFox on 2025/9/28.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct Base64CF: View
{
    @State private var importedText: String = ""
    @State private var outputString: String = ""
    @State private var FileName: String = ""
    private var inputStatus: String { importedText.isEmpty ? "导入失败或未选择文件" : "导入成功" }
    private func save()
    {
        let panel = NSSavePanel()
        panel.title = "导出"
        panel.nameFieldStringValue = "Default.txt"
        if #available(macOS 26.0, *)
        {
            panel.allowedContentTypes = [.plainText]
        }
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true
        panel.begin
        {   resp in
            guard resp == .OK, let url = panel.url else { return }
            do{
                try outputString.data(using: .utf8)?.write(to: url,options: .atomic)
            }catch{
                NSAlert(error: error).runModal()
            }
        }
    }
    var body: some View
    {
        VStack(spacing: 20)
        {
            HStack(spacing: 20){
                Button("选择文件")
                {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.plainText]
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
            Button("Base64编码")
            {
                if let data = importedText.data(using: .utf8)
                {
                    outputString = data.base64EncodedString()
                }
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
                Text("尚未编码或编码失败")
            }
        }
    }
}

#Preview {
    ContentView()
}
