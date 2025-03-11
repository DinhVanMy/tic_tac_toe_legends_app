import UIKit
import AVFoundation

// Định nghĩa enum ImageFormat để xử lý các định dạng ảnh
enum ImageFormat: Int {
    case JPEG = 0
    case PNG = 1
    case WEBP = 2
}

@objc class ThumbnailPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.tictactoe_gameapp/video_thumbnail", binaryMessenger: registrar.messenger())
        let instance = ThumbnailPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        let videoPath = args["video"] as! String
        let format = args["format"] as! Int
        let maxHeight = args["maxh"] as! Int
        let maxWidth = args["maxw"] as! Int
        let timeMs = args["timeMs"] as! Int
        let quality = args["quality"] as! Int
        let headers = args["headers"] as? [String: String]

        switch call.method {
        case "file":
            let thumbnailPath = args["path"] as? String
            do {
                let filePath = try generateThumbnailFile(
                    videoPath: videoPath, thumbnailPath: thumbnailPath, format: format,
                    maxHeight: maxHeight, maxWidth: maxWidth, timeMs: timeMs, quality: quality, headers: headers
                )
                result(filePath)
            } catch {
                result(FlutterError(code: "ThumbnailError", message: error.localizedDescription, details: nil))
            }
        case "data":
            do {
                let data = try generateThumbnailData(
                    videoPath: videoPath, format: format, maxHeight: maxHeight,
                    maxWidth: maxWidth, timeMs: timeMs, quality: quality, headers: headers
                )
                result(data)
            } catch {
                result(FlutterError(code: "ThumbnailError", message: error.localizedDescription, details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func generateThumbnailFile(
        videoPath: String, thumbnailPath: String?, format: Int, maxHeight: Int,
        maxWidth: Int, timeMs: Int, quality: Int, headers: [String: String]?
    ) throws -> String {
        let url = URL(string: videoPath)!
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers ?? [:]])
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if maxHeight > 0 || maxWidth > 0 {
            generator.maximumSize = CGSize(width: CGFloat(maxWidth), height: CGFloat(maxHeight))
        }

        let cgImage = try generator.copyCGImage(at: CMTimeMake(value: Int64(timeMs), timescale: 1000), actualTime: nil)
        let uiImage = UIImage(cgImage: cgImage)

        let outputPath = thumbnailPath ?? (NSTemporaryDirectory() + "thumb_\(UUID().uuidString).jpg")
        let urlPath = URL(fileURLWithPath: outputPath)

        switch ImageFormat(rawValue: format) {
        case .JPEG:
            try uiImage.jpegData(compressionQuality: CGFloat(quality) / 100.0)?.write(to: urlPath)
        case .PNG:
            try uiImage.pngData()?.write(to: urlPath)
        case .WEBP:
            // iOS không hỗ trợ WebP native, mặc định dùng JPEG thay thế
            try uiImage.jpegData(compressionQuality: CGFloat(quality) / 100.0)?.write(to: urlPath)
        case .none:
            throw NSError(domain: "InvalidFormat", code: -1, userInfo: nil)
        }

        return outputPath
    }

    private func generateThumbnailData(
        videoPath: String, format: Int, maxHeight: Int, maxWidth: Int,
        timeMs: Int, quality: Int, headers: [String: String]?
    ) throws -> Data {
        let url = URL(string: videoPath)!
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers ?? [:]])
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if maxHeight > 0 || maxWidth > 0 {
            generator.maximumSize = CGSize(width: CGFloat(maxWidth), height: CGFloat(maxHeight))
        }

        let cgImage = try generator.copyCGImage(at: CMTimeMake(value: Int64(timeMs), timescale: 1000), actualTime: nil)
        let uiImage = UIImage(cgImage: cgImage)

        switch ImageFormat(rawValue: format) {
        case .JPEG:
            return uiImage.jpegData(compressionQuality: CGFloat(quality) / 100.0) ?? Data()
        case .PNG:
            return uiImage.pngData() ?? Data()
        case .WEBP:
            // iOS không hỗ trợ WebP native, mặc định dùng JPEG thay thế
            return uiImage.jpegData(compressionQuality: CGFloat(quality) / 100.0) ?? Data()
        case .none:
            throw NSError(domain: "InvalidFormat", code: -1, userInfo: nil)
        }
    }
}