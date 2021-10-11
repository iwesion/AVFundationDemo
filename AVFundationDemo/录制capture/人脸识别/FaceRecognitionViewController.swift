//
//  FaceRecognitionViewController.swift
//  AVFundationDemo
//
//  Created by wesion on 2021/10/11.
//

import UIKit
import AVFoundation
class FaceRecognitionViewController: UIViewController {
    let captureManager = CaptureManager()
    //视频画面预览
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        previewLayer.session = captureManager.captureSession
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
        self.setupCaptureManager()
    }
    func setupCaptureManager() {
        captureManager.setupSession { (isSuccess, error) in
            if isSuccess {
                captureManager.startSession()
            }
        }
        captureManager.faceDataCallback = {[weak self] (metadataObjects) in
            for item in metadataObjects {
                let transformedFace:AVMetadataObject? = self!.previewLayer.transformedMetadataObject(for: item)
                
//                faceV.frame = transformedFace!.bounds
//
//                faceV.layoutIfNeeded()
                print("item=\(item.bounds),transformedFace= \(transformedFace?.bounds)")
            }
            
        }
        
    }

}
