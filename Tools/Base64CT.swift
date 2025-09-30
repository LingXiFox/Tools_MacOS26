//
//  HomeView.swift
//  Tools
//
//  Created by LingXiFox on 2025/9/27.
//

import SwiftUI

struct Base64CT : View
{
    @State private var InputText: String = ""
    @State private var OutputText: String = ""
    @State private var ShowCopied: Bool = false
    var body: some View
    {
        VStack(spacing: 20)
        {
            TextField("输入需要编码的文本",text: $InputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Base64编码")
            {
                if let data = InputText.data(using: .utf8)
                {
                    OutputText = data.base64EncodedString()
                }
            }
            if !OutputText.isEmpty
            {
                VStack
                {
                    Text("编码结果")
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
