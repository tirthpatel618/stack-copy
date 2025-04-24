//
//  StackManagerView.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import SwiftUI

struct StackManagerView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack {
            Text("Clipboard Stack")
                .font(.headline)
                .padding()
            
            if clipboardManager.clipboardStack.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Your clipboard stack is empty")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(clipboardManager.clipboardStack.enumerated()), id: \.element.id) { index, item in
                        HStack {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 25)
                            
                            VStack(alignment: .leading) {
                                itemPreview(item: item)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(item.createdAt, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                clipboardManager.clipboardStack.remove(at: index)
                                clipboardManager.saveStack()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            HStack {
                Button("Clear All") {
                    clipboardManager.clipboardStack.removeAll()
                    clipboardManager.saveStack()
                }
                .disabled(clipboardManager.clipboardStack.isEmpty)
                
                Spacer()
                
                Text("\(clipboardManager.clipboardStack.count)/10 items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
    }
    
    @ViewBuilder
    func itemPreview(item: ClipboardItem) -> some View {
        switch item.contentType {
        case .text:
            Text(item.textData ?? "")
                .lineLimit(2)
                .foregroundColor(.primary)
        
        case .image:
            if let imageData = item.imageData, let nsImage = NSImage(data: imageData) {
                HStack {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                    Text("Image")
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Image")
                    .foregroundColor(.secondary)
            }
            
        case .fileURL:
            if let url = item.fileURLData?.first {
                HStack {
                    Image(systemName: "doc")
                    Text(url.lastPathComponent)
                }
            } else {
                Text("File")
                    .foregroundColor(.secondary)
            }
            
        case .rtf:
            Text("Formatted text")
                .foregroundColor(.secondary)
        }
    }
}