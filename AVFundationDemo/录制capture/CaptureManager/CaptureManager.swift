//
//  CaptureManager.swift
//  AVFundationDemo
//
//  Created by wesion on 2021/10/11.
//

import UIKit
import AVFoundation
class CaptureManager: NSObject {
    let captureSession = AVCaptureSession()
    //当前正在使用的输入设备(摄像头)
    weak var activeCamera : AVCaptureDeviceInput?
    //视频数据处理队列
    let videoDataQueue = DispatchQueue(label: "com.wesion.videoDataCaptureQueue")
    //音频数据处理队列
    let audioDataQueue = DispatchQueue(label: "com.wesion.audioDataCaptureQueue")
    //（人脸）数据处理队列
    let metaDataQueue = DispatchQueue(label: "com.wesion.metaDataCaptureQueue")
    //捕捉的视频数据输出对象
    let videoDataOutput = AVCaptureVideoDataOutput()
    //捕捉的音频数据输出对象
    let audioDataOutput = AVCaptureAudioDataOutput()
    //捕捉的（人脸）数据输出对象
    var metadataOutput = AVCaptureMetadataOutput()
  
    //视频数据回调
    var videoDataCallback: ((CMSampleBuffer) -> Void)?
    //音频数据回调
    var audioDataCallback: ((CMSampleBuffer) -> Void)?
    //人脸数据返回
    var faceDataCallback :(([AVMetadataObject]) -> Void)?
    
    // MARK: - SessionConfig
    
    typealias SetupCompletionHandler = ((Bool,Error?) -> Void)
    public func setupSession(completion:SetupCompletionHandler){
        captureSession.sessionPreset = .hd1920x1080
        setupSessionInput { (isSuccess, error) in
            if !isSuccess {
                completion(isSuccess,error);
                return;
            }
        }
        setupSessionOutput { (isSuccess, error) in
            completion(isSuccess,error)
        }
    }
    //摄像头变更
    public func changeCamera(){
        let devicess = AVCaptureDevice.devices(for: AVMediaType.video)
        if devicess.count>1 {
            // 如果当前是后置摄像头，就便利设备，找到前置摄像头，进行切换
            if activeCamera?.device.position == .back{
                for device in devicess {
                    if device.position == .front {
                        do {
                            let deviceInput:AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: device)
                            // 开始配置
                            captureSession.beginConfiguration()
                            captureSession.removeInput(activeCamera!)
                            captureSession.canSetSessionPreset(.high)
                            if captureSession.canAddInput(deviceInput) {
                                captureSession.addInput(deviceInput)
                                activeCamera = deviceInput
                            }else{
                                captureSession.addInput(activeCamera!)
                            }
                            captureSession.commitConfiguration()
                        } catch {

                            return
                        }
                    }
                }

            }else{
                for device in devicess {
                    if device.position == .back {
                        do {
                            let deviceInput:AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: device)
                            // 开始配置
                            captureSession.beginConfiguration()
                            captureSession.removeInput(activeCamera!)
                            captureSession.canSetSessionPreset(.high)
                            if captureSession.canAddInput(deviceInput) {
                                captureSession.addInput(deviceInput)
                                activeCamera = deviceInput
                            }else{
                                captureSession.addInput(activeCamera!)
                            }
                            captureSession.commitConfiguration()
                        } catch {

                            return
                        }
                    }
                }
            }
        }
    }
    //
    private func setupSessionInput(completion:SetupCompletionHandler) {
        let deviceError = NSError.init(
            domain: "com.session.error",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("配置录制设备出错", comment: "")])
        
        //配置摄像头
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            completion(false,deviceError)
            return
        }
        do {
            let videoInput = try AVCaptureDeviceInput.init(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                activeCamera = videoInput
            }
        } catch {
            completion(false,deviceError)
            return
        }
        
        //配置麦克风
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            completion(false,deviceError)
            return
        }
        do {
            let audioInput = try AVCaptureDeviceInput.init(device: audioDevice)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
        } catch {
            completion(false,deviceError)
            return
        }
        completion(true,nil)
    }
    private func setupSessionOutput(completion: SetupCompletionHandler){
        let outputError = NSError.init(
            domain: "com.session.error",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("输出设置出错", comment: "")])
        
        //摄像头采集的yuv是压缩的视频信号，要还原成可以处理的数字信号
        let outputSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoDataOutput.videoSettings = outputSettings
        //不丢弃迟到帧，但会增加内存开销
        //视频输出
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataQueue)
        if captureSession.canAddOutput(videoDataOutput){
            captureSession.addOutput(videoDataOutput)
        }else{
            completion(false,outputError)
            return
        }
        //音频输出
        audioDataOutput.setSampleBufferDelegate(self, queue: audioDataQueue)
        if captureSession.canAddOutput(audioDataOutput) {
            captureSession.addOutput(audioDataOutput)
        }else{
            completion(false,outputError)
            return
        }
        
        //人脸
        metadataOutput.setMetadataObjectsDelegate(self, queue: metaDataQueue)
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes  = [.face]
        }else{
            completion(false,outputError)
        }
        completion(true,nil)
    }
    // MARK: - Session operation
    public func startSession() {
        //防止阻塞主线程
        videoDataQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    public func stopSession() {
        videoDataQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    // MARK: - utils
    public func recommendedVideoSettingsForAssetWriter(writingTo outputFileType: AVFileType) -> [String: Any]? {
        return videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: outputFileType)
    }
    public func recommendedAudioSettingsForAssetWriter(writingTo outputFileType: AVFileType) -> [String: Any]? {
        return audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: outputFileType)
    }
}

extension CaptureManager : AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == videoDataOutput {
            //数据处理
            guard let callback = videoDataCallback else {
                return;
            }
            callback(sampleBuffer)
            
        }else if output == audioDataOutput{
            guard let callback = audioDataCallback else {
                return;
            }
            callback(sampleBuffer)
        }
    }
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}

extension CaptureManager:AVCaptureMetadataOutputObjectsDelegate{
    /**
     1. 当检测到AVMetadataObject数据时会调用这个代理, AVMetadataObject 数据有很多种, 其中有一种就是人脸数据
     当然,我们在添加AVCaptureMetadataOutput 输出是设置了类型, 因此这个代理中只有人脸数据

     2. metadataObjects 是一个数组,包含各种类型的 AVMetadataObject.

     3. AVMetadataFaceObject 定义了多个描述检测到人脸的属性.其中,最重要的是人脸的边界(bounds), 它是CGRect类型的变量.
     他的坐标是基于设备标量坐标系,它的范围时摄像头原始朝向左上角(0,0)到右下角(1,1). 除了边界,AVMetadataFaceObject 还提供了检测到的人脸
     的倾斜角和偏转角.
     倾斜角(rollAngle) 表示人的头部向肩的方向侧倾角度, 偏转角(yawAngle) 表示人沿Y轴的旋转角
     3.AVMetadataFaceObject 还有一个重要的属性就是 faceID , 每个人脸AVFoundation 都会给faceID ,当人脸离开屏幕时,
     对应的人脸也会在回调方法中消失, 我们需要根据人脸ID 保存绘制的人脸矩形, 当人脸消失后, 我们需要将矩形去除
     */
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        if output == metadataOutput {
            //数据处理
            guard let callback = faceDataCallback else {
                return;
            }
            callback(metadataObjects)
        }
    }
}
