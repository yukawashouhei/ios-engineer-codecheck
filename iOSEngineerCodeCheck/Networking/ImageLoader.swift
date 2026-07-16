//
//  ImageLoader.swift
//  iOSEngineerCodeCheck
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import UIKit

/// URL から画像を非同期に取得するユーティリティ
enum ImageLoader {

    static func load(from url: URL) async -> UIImage? {
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}
