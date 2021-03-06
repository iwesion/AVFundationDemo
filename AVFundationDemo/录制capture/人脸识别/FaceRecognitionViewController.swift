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
    let btn1:UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom )
        btn.setTitle("切换摄像头", for: .normal)
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
        
        
        self.view.addSubview(btn1)
        btn1.backgroundColor = .red
        btn1.addTarget(self, action: #selector(chgSelectBtn1(_:)), for: .touchUpInside)
        btn1.snp.makeConstraints { make in
            make.bottom.equalTo(-150)
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
        //获取faceLayers的key，用于确定哪些人移除了视图并将对应的图层移出界面。
        /*
         支持同时识别10个人脸
         */
        var lostFaces:[Int] = []
        for key in self.faceLayers.keys {
            lostFaces.append(key)
        }
        for metadataObject in metadataObjects {
            let face = metadataObject as! AVMetadataFaceObject
            let faceID:Int = face.faceID
            //将对象从lostFaces 移除,留下的就是不要的（到时候要删除）
            
            lostFaces =  lostFaces.filter { i in
                return i != faceID
            }
            
            var layer:CALayer? = self.faceLayers[faceID]
            //拿到当前faceID对应的layer
            if (layer == nil) {
                //调用makeFaceLayer 创建一个新的人脸图层
                layer = self.makeFaceLayer()
                //将新的人脸图层添加到 previewLayer上
                self.overlayLayer.addSublayer(layer!);
                //将layer加入到字典中
                self.faceLayers[faceID] = layer;
            }
            //设置图层的transform属性 CATransform3DIdentity 图层默认变化 这样可以重新设置之前应用的变化
            layer!.transform = CATransform3DIdentity
            if (face.hasRollAngle) {
                
                //如果为YES,则获取相应的CATransform3D 值
                let t:CATransform3D = self.transformForRollAngle(face.rollAngle);
                //将它与标识变化关联在一起，并设置transform属性
                layer!.transform = CATransform3DConcat(layer!.transform, t);
            }
            //判断人脸对象是否具有有效的偏转角
            if (face.hasYawAngle) {
                
                //如果为YES,则获取相应的CATransform3D 值
                let t:CATransform3D = self.transformForYawAngle(face.yawAngle);
                layer!.transform = CATransform3DConcat(layer!.transform, t);
                
            }
            //图层的大小 = 人脸的大小
            DispatchQueue.main.async { [weak self] in
                layer!.frame = face.bounds;
            }

        }
        //遍历数组将剩下的人脸ID集合从上一个图层和faceLayers字典中移除
        for faceId in lostFaces {
            let layer:CALayer = faceLayers[faceId]!
            layer.backgroundColor = UIColor.green.cgColor
            DispatchQueue.main.async { [weak self] in
                layer.removeFromSuperlayer()
            }
           
            faceLayers.removeValue(forKey: faceId)
            
           
        }
        
        
//        faceLayerArr.removeAll()
//        overlayLayer.sublayers?.removeAll()
//        faceLayers.removeAll()
//        for metadataObject in metadataObjects {
//            let face = metadataObject as! AVMetadataFaceObject
//            let faceID:Int = face.faceID
//            var layer:CALayer = self.makeFaceLayer()
//            //判断人脸对象是否具有有效的斜倾交。
//            if (face.hasRollAngle) {
//
//                //如果为YES,则获取相应的CATransform3D 值
//                let t:CATransform3D = self.transformForRollAngle(face.rollAngle);
//                //将它与标识变化关联在一起，并设置transform属性
//                layer.transform = CATransform3DConcat(layer.transform, t);
//            }
//            //判断人脸对象是否具有有效的偏转角
//            if (face.hasYawAngle) {
//
//                //如果为YES,则获取相应的CATransform3D 值
//                let t:CATransform3D = self.transformForYawAngle(face.yawAngle);
//                layer.transform = CATransform3DConcat(layer.transform, t);
//
//            }
//
//
//            DispatchQueue.main.async { [weak self] in
//                layer.frame = face.bounds;
//                self?.overlayLayer.addSublayer(layer)
//                self?.faceLayerArr.append(layer)
//
//            }
//
//
//        }
        
        
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
        //边框宽度为3.0f
        layer.borderWidth = 3.0
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
    @objc func chgSelectBtn1(_ sender:UIButton) {
        captureManager.changeCamera()
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
    //将 RollAngle 的 rollAngleInDegrees 值转换为 CATransform3D
    func transformForRollAngle(_ rollAngleInDegrees:CGFloat) -> CATransform3D {
        //将人脸对象得到的RollAngle 单位“度” 转为Core Animation需要的弧度值
        let rollAngleInRadians:CGFloat = rollAngleInDegrees * Double.pi / 180
        //将结果赋给CATransform3DMakeRotation x,y,z轴为0，0，1 得到绕Z轴倾斜角旋转转换
        return CATransform3DMakeRotation(rollAngleInRadians, 0, 0, 1)
        
    }
    //将 YawAngle 的 yawAngleInDegrees 值转换为 CATransform3D
    func transformForYawAngle(_ yawAngleInDegrees:CGFloat) -> CATransform3D {
        //将角度转换为弧度值
        let yawAngleInRaians:CGFloat = yawAngleInDegrees * Double.pi / 180
        //将结果赋给CATransform3DMakeRotation x,y,z轴为0，0，1 得到绕Z轴倾斜角旋转转换
        let yawTransform:CATransform3D = CATransform3DMakeRotation(yawAngleInRaians, 0, -1, 0)
        
        
        return CATransform3DConcat(yawTransform, self.orientationTransform())
        
    }
    
    func orientationTransform() -> CATransform3D {
        var angle:CGFloat = 0
        
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            angle = .pi
            //方向：右
        case .landscapeRight:
            angle = -(.pi / 2.0)
            //方向：左
        case .landscapeLeft:
            angle = .pi / 2.0
            //其他
        default:
            angle = 0.0
            break;
        }
        
        return CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0);
    }
}
