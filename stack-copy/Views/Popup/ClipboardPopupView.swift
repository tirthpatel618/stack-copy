//
//  ClipboardPopupView.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import SwiftUI

struct ClipboardPopupView: View {
    let items: [ClipboardItem]
    let mode: PopupMode
    let onSelect: (Int) -> Void
    
    @State private var hoveredIndex: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            if items.isEmpty {
                Text("Stack is empty")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button(action: {
                        onSelect(index)
                    }) {
                        HStack {
                            Text("\(index + 1)")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 25)
                            
                            // Item preview
                            itemPreview(item: item)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(hoveredIndex == index ? Color.accentColor.opacity(0.1) : Color.clear)
                    .onHover { isHovered in
                        hoveredIndex = isHovered ? index : nil
                    }
                    
                    if index < items.count - 1 {
                        Divider()
                    }
                }
                
                // Show "0 - Delete All" option in delete mode
                if mode == .delete {
                    Divider()
                    Button(action: {
                        onSelect(-1) // Special index for delete all
                    }) {
                        HStack {
                            Text("0")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 25)
                            
                            Text("Delete All")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(hoveredIndex == -1 ? Color.red.opacity(0.1) : Color.clear)
                    .onHover { isHovered in
                        hoveredIndex = isHovered ? -1 : nil
                    }
                }
            }
        }
        .frame(width: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
    }
    
    @ViewBuilder
    func itemPreview(item: ClipboardItem) -> some View {
        switch item.contentType {
        case .text:
            Text(item.previewText)
                .lineLimit(1)
                .foregroundColor(.primary)
        
        case .image:
            if let imageData = item.imageData, let nsImage = NSImage(data: imageData) {
                HStack {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
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
                        .lineLimit(1)
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