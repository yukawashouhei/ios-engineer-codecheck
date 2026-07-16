//
//  ImageLoader.swift
//  iOSEngineerCodeCheck
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import UIKit

/// URL から画像を非同期に取得するユーティリティ。
/// 取得済みの画像はメモリキャッシュされ、同じ URL への再ダウンロードを防ぐ。
enum ImageLoader {

    private static let cache = NSCache<NSURL, UIImage>()

    static func load(from url: URL) async -> UIImage? {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
