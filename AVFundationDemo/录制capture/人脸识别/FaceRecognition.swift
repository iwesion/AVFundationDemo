//
//  FaceRecognition.swift
//  AVideo
//
//  Created by wesion on 2021/10/8.
//

import UIKit
import AVFoundation

//最多同时支持识别10个人脸
class FaceRecognition: NSObject {
    var metadataOutput = AVCaptureMetadataOutput()
    let metaDataQueue = DispatchQueue(label: "com.wesion.metaDataCaptureQueue")
    //错误回调
    typealias SetupCompletionHandler = ((Bool,Error?) -> Void)
    
    let previewView:PreviewView = .init()

    public func setupSessionInput(_ captureSession:AVCaptureSession,completion:SetupCompletionHandler){

        let outputError = NSError.init(
            domain: "com.session.error",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("输出设置出错", comment: "")])
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes  = [.face]
            metadataOutput.setMetadataObjectsDelegate(self, queue: metaDataQueue)
        }else{
            completion(false,outputError)
        }
        completion(true,nil)
    }
    
    
    
}
extension FaceRecognition:AVCaptureMetadataOutputObjectsDelegate{
    
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
        if metadataObjects.first?.type  == .face {
            previewView.showFace(metadataObjects)
        }
        
        
    
    }

}
