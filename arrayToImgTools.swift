import Foundation
import Cocoa
import UniformTypeIdentifiers

extension CGImage
{
    //https://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file
    var png: Data?
    {
        let cfdata: CFMutableData = CFDataCreateMutable(nil, 0)
        if let destination = CGImageDestinationCreateWithData(cfdata, String(describing: UTType.png) as CFString, 1, nil)
        {
            CGImageDestinationAddImage(destination, self, nil)
            if CGImageDestinationFinalize(destination)
            {
                return cfdata as Data
            }
        }
        return nil
    }
}

func pixeldata_to_image(pixels: [PixelData], width: Int, height: Int)->CGImage
{
    assert(pixels.count == Int(width * height))
    let bitsPerComponent: Int = 8
    let bitsPerPixel: Int = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    let bitsPerByte = 8
    let bytesPerPixel: Int = bitsPerPixel/bitsPerByte
    
    
    var data = pixels

    guard
        let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * bytesPerPixel))
//        let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * bitsPerPixel))
    else
    {
        fatalError("CGDataProvider failure")
    }
    guard
        let image = CGImage(
            width: width,
            height: height,
            bitsPerComponent:bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * bytesPerPixel,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    else
    {
        fatalError("CGImage failure")
    }
    return image
}
