//
//  SearchView.swift
//  Tools
//
//  Created by LingXiFox on 2025/9/27.
//

import SwiftUI
import CryptoKit
import AppKit
import UniformTypeIdentifiers

struct Haxi: View {
    enum Algorithm: String, CaseIterable, Identifiable {
        case md5 = "MD5"
        case sha1 = "SHA-1"
        case sha256 = "SHA-256"
        case sha384 = "SHA-384"
        case sha512 = "SHA-512"
        var id: String { rawValue }
    }
    @State private var selectedAlgorithm: Algorithm = .sha256
    @State private var saltLength: Int = 8 // bytes
    @State private var useSalt: Bool = true
    @State private var saltHex: String = ""
    @State private var inputText: String = ""
    @State private var textHashHex: String = ""
    @State private var importedFileURL: URL? = nil
    @State private var importedFileName: String = ""
    @State private var fileHashHex: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("哈希编码").font(.largeTitle).bold()
            GroupBox("编码设置") {
                HStack(spacing: 16) {
                    Picker("算法", selection: $selectedAlgorithm) {
                        ForEach(Algorithm.allCases) { algo in
                            Text(algo.rawValue).tag(algo)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("使用盐", isOn: $useSalt)

                    HStack(spacing: 8) {
                        Text("盐字节数: \(saltLength)")
                        Stepper(value: $saltLength, in: 0...64) { EmptyView() }
                        Button("重新生成盐") { regenerateSalt() }
                            .disabled(!useSalt)
                    }
                }
                .onChange(of: useSalt) {
                    regenerateSaltIfNeeded()
                }
                .onChange(of: saltLength) {
                    regenerateSaltIfNeeded()
                }

                HStack(alignment: .firstTextBaseline) {
                    Text("盐(HEX):").frame(width: 70, alignment: .leading)
                    TextField("自动生成 (可复制)", text: $saltHex)
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                }
            }
            TabView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("字符输入").font(.headline)
                    TextEditor(text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 140)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary))

                    HStack {
                        Button("计算哈希") {
                            textHashHex = hashString(inputText)
                        }
                        .keyboardShortcut(.return, modifiers: [.command])

                        Button("清空") {
                            inputText.removeAll()
                            textHashHex.removeAll()
                        }
                    }

                    if !textHashHex.isEmpty {
                        GroupBox("结果 (HEX)") {
                            ScrollView { Text(textHashHex).textSelection(.enabled).font(.system(.body, design: .monospaced)) }
                        }
                    }

                    Spacer(minLength: 0)
                }
                .tabItem { Text("字符") }

                VStack(alignment: .leading, spacing: 10) {
                    Text("导入文件").font(.headline)
                    HStack {
                        Button("选择文件…") { pickFile() }
                        if let name = importedFileURL?.lastPathComponent ?? (importedFileName.isEmpty ? nil : importedFileName) {
                            Text("已选择：\(name)")
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }

                    HStack {
                        Button("计算哈希") { computeFileHash() }
                            .disabled(importedFileURL == nil)
                        Button("结果另存为…") { saveResult() }
                            .disabled(fileHashHex.isEmpty)
                    }

                    if !fileHashHex.isEmpty {
                        GroupBox("结果 (HEX)") {
                            ScrollView { Text(fileHashHex).textSelection(.enabled).font(.system(.body, design: .monospaced)) }
                        }
                    }

                    Spacer(minLength: 0)
                }
                .tabItem { Text("文件") }
            }
            .tabViewStyle(.automatic)
        }
        .padding()
        .onAppear { regenerateSaltIfNeeded() }
    }

    private func regenerateSaltIfNeeded() {
        guard useSalt else { saltHex = ""; return }
        regenerateSalt()
    }

    private func regenerateSalt() {
        guard useSalt else { saltHex = ""; return }
        let bytes = (0..<max(0, saltLength)).map { _ in UInt8.random(in: 0...255) }
        saltHex = bytes.map { String(format: "%02x", $0) }.joined()
    }

    private func currentSaltData() -> Data {
        guard useSalt, !saltHex.isEmpty else { return Data() }
        return Data(hexString: saltHex) ?? Data()
    }

    private func hashString(_ text: String) -> String {
        let data = Data(text.utf8) + currentSaltData()
        return hashData(data)
    }

    private func hashData(_ data: Data) -> String {
        switch selectedAlgorithm {
        case .md5:
            let digest = Insecure.MD5.hash(data: data)
            return digest.hexString
        case .sha1:
            let digest = Insecure.SHA1.hash(data: data)
            return digest.hexString
        case .sha256:
            let digest = SHA256.hash(data: data)
            return digest.hexString
        case .sha384:
            let digest = SHA384.hash(data: data)
            return digest.hexString
        case .sha512:
            let digest = SHA512.hash(data: data)
            return digest.hexString
        }
    }

    private func pickFile() {
        #if os(macOS)
        let panel = NSOpenPanel()
        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = [.item]
        } else {
            panel.allowedFileTypes = ["*"]
        }
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            importedFileURL = url
            importedFileName = url.lastPathComponent
            fileHashHex = ""
        }
        #endif
    }

    private func computeFileHash() {
        guard let url = importedFileURL else { return }
        do {
            let fileData = try Data(contentsOf: url, options: .mappedIfSafe)
            let salted = fileData + currentSaltData()
            fileHashHex = hashData(salted)
        } catch {
            #if os(macOS)
            NSAlert(error: error).runModal()
            #endif
        }
    }

    private func saveResult() {
        #if os(macOS)
        let panel = NSSavePanel()
        panel.title = "导出哈希结果"
        panel.nameFieldStringValue = "hash.txt"
        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = [.plainText]
        } else {
            panel.allowedFileTypes = ["txt"]
        }
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true
        panel.begin { resp in
            guard resp == .OK, let url = panel.url else { return }
            do {
                let meta = "算法: \(selectedAlgorithm.rawValue)\n盐(HEX): \(useSalt ? saltHex : "<未使用>")\n文件: \(importedFileURL?.lastPathComponent ?? "<未选择>")\n———\n"
                let content = meta + (fileHashHex.isEmpty ? textHashHex : fileHashHex) + "\n"
                guard let data = content.data(using: .utf8) else {
                    throw NSError(domain: "EncodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法将字符串转为 UTF-8 数据"])
                }
                try data.write(to: url, options: .atomic)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
        #endif
    }
}

private extension Sequence where Element == UInt8 {
    var hexString: String { map { String(format: "%02x", $0) }.joined() }
}

private extension Digest {
    var hexString: String { makeIterator().hexString }
}

private extension Data {
    init?(hexString: String) {
        let cleaned = hexString.replacingOccurrences(of: " ", with: "").lowercased()
        guard cleaned.count % 2 == 0 else { return nil }
        var bytes = [UInt8]()
        bytes.reserveCapacity(cleaned.count/2)
        var idx = cleaned.startIndex
        while idx < cleaned.endIndex {
            let next = cleaned.index(idx, offsetBy: 2)
            let bStr = cleaned[idx..<next]
            guard let b = UInt8(bStr, radix: 16) else { return nil }
            bytes.append(b)
            idx = next
        }
        self.init(bytes)
    }
}

#Preview {
    ContentView()
}
