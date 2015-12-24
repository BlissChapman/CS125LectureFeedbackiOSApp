//
//  QRCodeHelper.swift
//  CS125LectureFeedback
//
//  Created by Bliss Chapman on 11/17/15.
//  Copyright © 2015 Bliss Chapman. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


final class QRCodeHelper {
    
    enum QRCodeGenerationResult {
        case Success(qrCode: UIImage)
        case Error(message: String)
    }
    private enum UIImageFromCGImageError: ErrorType {
        case ExtractingRawImageData
    }
    
    static internal func generateQRCode(forString stringToEncode: String) -> QRCodeGenerationResult {
        guard let stringData = stringToEncode.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: true) else {
            return .Error(message: "Failed to encode the QR Code information.")
        }
        
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return .Error(message: "Failed to initialize the QR Code filter.")
        }
        
        qrFilter.setDefaults()
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let filterOutput = qrFilter.outputImage else {
            return .Error(message: "Failed to retrieve the QR Code filter output.")
        }
        
        do {
            let qrCode = try createNonInterpolatedUIImageFromCIImage(filterOutput, scale: 5.0)
            return .Success(qrCode: qrCode)
        } catch {
            return .Error(message: "Failed to create a non interpolated QR Code image.")
        }
    }
    
    
    private static func createNonInterpolatedUIImageFromCIImage(image: CIImage, scale: CGFloat) throws -> UIImage {
        let cgImageRef: CGImageRef = CIContext(options: nil).createCGImage(image, fromRect: image.extent)
        
        UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.height * scale))
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .None)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImageRef)
        let scaledImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        guard let scaledCGImage = scaledImage.CGImage else {
            throw UIImageFromCGImageError.ExtractingRawImageData
        }
        
        return UIImage(CGImage: scaledCGImage, scale: scaledImage.scale, orientation: .DownMirrored)
    }
    
    //MARK: Camera Permissions
    static func cameraAccessIsAllowed() -> Bool {
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .Authorized: return true
        case .Denied, .Restricted: return false
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) in
                return cameraAccessIsAllowed()
            })
        }
        
        return false
    }
}