//
//  CaptureViewController.swift
//  AVideo
//
//  Created by wesion on 2021/9/28.
//

import UIKit
import AVFoundation
import Photos

class CaptureViewController: UIViewController {
    let captureSession = AVCaptureSession()
    //当前正在使用的输入设备(摄像头)
    weak var activeCamera : AVCaptureDeviceInput?
    //
    var metadataOutput = AVCaptureMetadataOutput()
    //人脸识别处理队列
    let metaDataQueue = DispatchQueue(label: "com.wesion.metaDataCaptureQueue")
    //视频数据处理队列
    let videoDataQueue = DispatchQueue(label: "com.videoDataCaptureQueue")
    //音频数据处理队列
    let audioDataQueue = DispatchQueue(label: "com.audioDataCaptureQueue")
    
    var currentFilter: String  = "CIPhotoEffectChrome"
    //捕捉的视频数据输出对象
    let videoDataOutput = AVCaptureVideoDataOutput()
    //捕捉的音频数据输出对象
    let audioDataOutput = AVCaptureAudioDataOutput()
    //设置滤镜view
    let filterSettingView = FilterSettingView()
    
  
    var writeVideo : WriteVideo?
    //当前是否在录制
    var isRecording = false
    
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    
    
    let btn:UIButton = {
        let btn = UIButton.init()
        btn.setTitle("录制", for: .normal)
        btn.setTitle("结束", for: .selected)
        btn.backgroundColor = .red
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.addUI()
        self.setupSessionInput()
        self.setupSessionOutput()
       
    }
    func addUI() {
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(44)
            make.left.right.bottom.equalTo(self.view)
        }
        
        self.view.addSubview(filterSettingView)
        filterSettingView.snp.makeConstraints { make in
            make.bottom.equalTo(self.view)
            make.centerX.equalTo(self.view)
        }
        
        self.view.addSubview(btn)
        btn.addTarget(self, action: #selector(didClickCaptureButton(_:)), for: .touchUpInside)
        btn.snp.makeConstraints { make in
            make.top.equalTo(44)
            make.centerX.equalTo(self.view)
            make.height.equalTo(50)
            make.width.equalTo(100)
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        self.startSession()
    }
    
    func setupSessionInput() {
        captureSession.sessionPreset = .hd1920x1080
        //配置摄像头
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("配置录制设备出错1")
            return
        }
        do {
            let videoInput = try AVCaptureDeviceInput.init(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                activeCamera = videoInput
            }
        } catch {
            print("配置录制设备出错2")
            return
        }
        //配置麦克风
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("配置麦克风出错1")
            return
        }
        do {
            let audioInput = try AVCaptureDeviceInput.init(device: audioDevice)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
        } catch {
            print("配置麦克风出错2")
            return
        }
    }
    func setupSessionOutput(){
        //摄像头采集的yuv是压缩的视频信号，要还原成可以处理的数字信号
        let outputSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoDataOutput.videoSettings = outputSettings
        //不丢弃迟到帧，但会增加内存开销
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataQueue)
        if captureSession.canAddOutput(videoDataOutput){
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        }else{
            print("输出设置出错")
            return
        }
        
        audioDataOutput.setSampleBufferDelegate(self, queue: audioDataQueue)
        if captureSession.canAddOutput(audioDataOutput) {
            captureSession.addOutput(audioDataOutput)
        }else{
            print("输出设置出错")
            return
        }

    }
    
    func startSession() {
        //防止阻塞主线程
        videoDataQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    func stopSession() {
        videoDataQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
  
    @objc func didClickCaptureButton(_ sender: UIButton) {
        //未开始录制，开始录制
        if !isRecording {
            //连续拍摄多段时，每次都需要重新生成一个实例。之前的writer会因为已经完成写入，无法再次使用
            setupMoiveWriter()
            writeVideo?.startWriting()
            isRecording = true
            sender.isSelected = true
        }else {
            //录制中，停止录制
            writeVideo?.stopWriting()
            isRecording = false
            sender.isSelected = false
        }
    }
    func setupMoiveWriter() {
        //输出视频的参数设置，如果要自定义视频分辨率，在此设置。否则可使用相应格式的推荐参数
        guard let videoSetings = videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4),
              let audioSetings = audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mp4)
            else{
                return
        }
        writeVideo = WriteVideo(videoSetting: videoSetings, audioSetting: audioSetings, fileType: .mp4)
        //录制成功回调
        writeVideo?.finishWriteCallback = { [weak self] url in
            guard let strongSelf = self else { return  }
            strongSelf.saveToAlbum(atURL: url, complete: { (success) in
                DispatchQueue.main.async {
                    strongSelf.showSaveResult(isSuccess: success)
                }
                
            })
        }
    }
    func saveToAlbum(atURL url: URL,complete: @escaping ((Bool) -> Void)){
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }, completionHandler: { (success, error) in
            complete(success)
        })
    }
    func showSaveResult(isSuccess: Bool) {
        let message = isSuccess ? "保存成功" : "保存失败"
        
        let alertController =  UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
            
        }))
        self .present(alertController, animated: true, completion: nil)
    }
    
}

extension CaptureViewController : AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //视频数据输出对象
        if output == videoDataOutput {
            //数据处理
            guard  let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            //1. 处理图像数据，输出结果为CIImage,作为后续展示和写入的基础数据
            let ciImage = CIImage.init(cvImageBuffer: imageBuffer)
            
//            //人脸识别
//            let temporaryContext:CIContext = .init()
//
//            let detector:CIDetector = .init(ofType: CIDetectorTypeFace, context: temporaryContext, options: [CIDetectorAccuracy:CIDetectorAccuracyLow])!
//            var faceArray:Array = detector.features(in: ciImage)
            
            //加滤镜
//            let filter = CIFilter.init(name: self.currentFilter)!
//            filter.setValue(ciImage, forKey: kCIInputImageKey)
//            guard let finalImage = filter.outputImage else {
//                return
//            }
            //自己的滤镜
            guard let finalImage = filterSettingView.xFilter.colorControlFilter(ciImage) else{
                return
            }
            guard let final1Image = filterSettingView.xFilter.gaussianBlurFilter(finalImage) else{
                return
            }
            //2. 用户界面展示
            let image = UIImage.init(ciImage: final1Image)
            DispatchQueue.main.async { [weak self] in
                if self != nil {
                    self!.imageView.image = image
                }
                
            }
            //3. 保存写入文件
            self.writeVideo?.processImageData(CIImage: finalImage, atTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))

        }else{
          
        }
    }
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}
