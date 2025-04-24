//
//  ClipboardItem.swift
//  stack-copy
//
//  Created by Tirth Patel on 2025-04-24.
//


import Foundation
import AppKit

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    
    // handle all of these types only for now - POTENTIAL UPGRADE HERE
    enum ContentType: String, Codable {
        case text, image, fileURL, rtf
    }
    
    var contentType: ContentType
    
    
    var textData: String?
    var imageData: Data?
    var fileURLData: [URL]?
    var rtfData: Data?
    
    // preview only text and url. will try to add in support for pictures - POTENTIAL UPRADE HERE too
    var previewText: String {
        switch contentType {
        case .text:
            return textData?.prefix(30).appending(textData!.count > 30 ? "..." : "") ?? ""
        case .image:
            return "Image"
        case .fileURL:
            return fileURLData?.first?.lastPathComponent ?? "File"
        case .rtf:
            return "Formatted text"
        }
    }
    
    init(id: UUID = UUID(), createdAt: Date = Date(), contentType: ContentType, textData: String? = nil, imageData: Data? = nil, fileURLData: [URL]? = nil, rtfData: Data? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.contentType = contentType
        self.textData = textData
        self.imageData = imageData
        self.fileURLData = fileURLData
        self.rtfData = rtfData
    }
    
    // containers for all the data - from what I read for Codable impl from apple
    private enum CodingKeys: String, CodingKey {
        case id, createdAt, contentType, textData, imageData, fileURLStrings, rtfData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        contentType = try container.decode(ContentType.self, forKey: .contentType)
        textData = try container.decodeIfPresent(String.self, forKey: .textData)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        rtfData = try container.decodeIfPresent(Data.self, forKey: .rtfData)
        
        // Convert String array back to URL array
        if let urlStrings = try container.decodeIfPresent([String].self, forKey: .fileURLStrings) {
            fileURLData = urlStrings.compactMap { URL(string: $0) }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(contentType, forKey: .contentType)
        try container.encodeIfPresent(textData, forKey: .textData)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encodeIfPresent(rtfData, forKey: .rtfData)
        
        // Convert URL array to String array for encoding
        if let urls = fileURLData {
            let urlStrings = urls.map { $0.absoluteString }
            try container.encode(urlStrings, forKey: .fileURLStrings)
        }
    }
}
