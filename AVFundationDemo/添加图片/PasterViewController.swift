//
//  PasterViewController.swift
//  AVFundationDemo
//
//  Created by wesion on 2021/11/9.
//

import UIKit
import AVKit
import AVFoundation
class PasterViewController: UIViewController {
    let captureManager = CaptureManager()
    //视频画面预览
    var previewLayer = AVCaptureVideoPreviewLayer()
    var overlayLayer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
 


}
