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
    var overlayLayer = CALayer()
    
    /// [faceID:CALayer]
    var faceLayers:[Int:CALayer] = [:]
    
    var faceLayerArr:[CALayer] = []
    
    var showStar:Bool = false
    
    
    let btn:UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom )
        btn.setTitle("添加✨", for: .normal)
        btn.setTitle("取消✨", for: .selected)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        previewLayer.session = captureManager.captureSession
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
        
        overlayLayer.frame = self.view.bounds
        self.view.layer.addSublayer(overlayLayer)
       
        self.view.addSubview(btn)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(chgSelectBtn(_:)), for: .touchUpInside)
        btn.snp.makeConstraints { make in
            make.bottom.equalTo(-50)
            make.centerX.equalTo(self.view)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        self.setupCaptureManager()
    }
    func setupCaptureManager() {
        captureManager.setupSession { (isSuccess, error) in
            if isSuccess {
                captureManager.startSession()
            }
        }
        captureManager.faceDataCallback = {[weak self] (metadataObjects) in
            if self != nil {
                let transformedFaces:[AVMetadataObject] = self!.transformedFacesFromFaces(metadataObjects)
                self!.showFace(transformedFaces)
            }
            
        }
        
    }
    
    func showFace(_ metadataObjects:[AVMetadataObject]) {
//        //获取faceLayers的key，用于确定哪些人移除了视图并将对应的图层移出界面。
//        /*
//         支持同时识别10个人脸
//         */
//        var lostFaces:[Int] = []
//        for key in self.faceLayers.keys {
//            lostFaces.append(key)
//        }
//        for metadataObject in metadataObjects {
//            let face = metadataObject as! AVMetadataFaceObject
//            let faceID:Int = face.faceID
//            //将对象从lostFaces 移除,留下的就是不要的（到时候要删除）
//            print("删除前\(lostFaces),\(faceID)")
//            lostFaces =  lostFaces.filter { i in
//                return i != faceID
//            }
//            print("删除后\(lostFaces),\(faceID)")
//            var layer:CALayer? = self.faceLayers[faceID]
//            //拿到当前faceID对应的layer
//            if (layer == nil) {
//                //调用makeFaceLayer 创建一个新的人脸图层
//                layer = self.makeFaceLayer()
//                //将新的人脸图层添加到 previewLayer上
//                self.overlayLayer.addSublayer(layer!);
//                //将layer加入到字典中
//                self.faceLayers[faceID] = layer;
//            }
//            //设置图层的transform属性 CATransform3DIdentity 图层默认变化 这样可以重新设置之前应用的变化
//            layer!.transform = CATransform3DIdentity
//            //图层的大小 = 人脸的大小
//            DispatchQueue.main.async { [weak self] in
//                layer!.frame = face.bounds;
//            }
//
//        }
//        //遍历数组将剩下的人脸ID集合从上一个图层和faceLayers字典中移除
//        for faceId in lostFaces {
//            let layer:CALayer = faceLayers[faceId]!
//            layer.removeFromSuperlayer()
//            faceLayers.removeValue(forKey: faceId)
//        }
//
//        self.overlayLayer.layoutIfNeeded()
        
        
        faceLayerArr.removeAll()
        overlayLayer.sublayers?.removeAll()
        faceLayers.removeAll()
        for metadataObject in metadataObjects {
            let face = metadataObject as! AVMetadataFaceObject
            let faceID:Int = face.faceID
            var layer:CALayer = self.makeFaceLayer()
            
            DispatchQueue.main.async { [weak self] in
                layer.frame = face.bounds;
                self?.overlayLayer.addSublayer(layer)
                self?.faceLayerArr.append(layer)
                
            }
            
            
        }
        
        
    }
    //将设备的坐标空间的人脸转换为视图空间的对象集合
    func transformedFacesFromFaces(_ faces:[AVMetadataObject]) -> [AVMetadataObject] {
        var transformedFaces:[AVMetadataObject] = []
        
        for item in faces {
            //将摄像头的人脸数据 转换为 视图上的可展示的数据
            //简单说：UIKit的坐标 与 摄像头坐标系统（0，0）-（1，1）不一样。所以需要转换
            //转换需要考虑图层、镜像、视频重力、方向等因素 在iOS6.0之前需要开发者自己计算，但iOS6.0后提供方法
            let transformedFace:AVMetadataObject? = previewLayer.transformedMetadataObject(for: item)
            if transformedFace != nil {
                transformedFaces.append(transformedFace!)
            }
            
        }
        
        return transformedFaces
    }
    func makeFaceLayer() -> CALayer {
        let layer = CALayer.init()
        //边框宽度为1.0f
        layer.borderWidth = 1.0
        //边框颜色为红色
        layer.borderColor = UIColor.red.cgColor
        if showStar {
            layer.contents = UIImage.init(named: "xinxin")?.cgImage
        }
        return layer
    }
    
    
    @objc func chgSelectBtn(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        showStar = sender.isSelected
    }
    
    
    
    
    func CATransform3DMakePerspective(_ eyePosition:CGFloat) -> CATransform3D {
        //CATransform3D 图层的旋转，缩放，偏移，歪斜和应用的透
        //CATransform3DIdentity是单位矩阵，该矩阵没有缩放，旋转，歪斜，透视。该矩阵应用到图层上，就是设置默认值。
        var transform:CATransform3D = .init()
        //透视效果（就是近大远小），是通过设置m34 m34 = -1.0/D 默认是0.D越小透视效果越明显
        //D:eyePosition 观察者到投射面的距离
        transform.m34 = -1/eyePosition
        return transform
        
    }
}
