//
//  PreviewView.swift
//  AVideo
//
//  Created by wesion on 2021/10/8.
//

import UIKit
import AVFoundation
class PreviewView: UIView {
    // 人脸位置的框
    let faceView:UIView = {
        let view = UIView.init(frame:CGRect.init(x: 0, y: 0, width: 150, height: 150))
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 3
        return view
    }()
    var faceLayers:[Int:CALayer] = [:]
    //视频画面预览
    var previewLayer = AVCaptureVideoPreviewLayer()
    let overlayLayer:CALayer = .init()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        //设置它的frame
        self.overlayLayer.frame = self.bounds;
        //子图层形变 sublayerTransform属性   Core  Animation动画
        self.overlayLayer.sublayerTransform = CATransform3DMakePerspective(1000);
        //将子图层添加到预览图层来
        self.layer.addSublayer(self.overlayLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.addSubview(faceView)
        overlayLayer.frame = self.bounds
        //子图层形变 sublayerTransform属性   Core  Animation动画
//        self.overlayLayer.sublayerTransform = CATransform3DMakeAffineTransform(1000);
        //将子图层添加到预览图层来
        self.layer.addSublayer(overlayLayer)
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
    
    func showFace(_ faces :[AVMetadataObject]) {
        //创建一个本地数组 保存转换后的人脸数据
        let transformedFaces:[AVMetadataObject] = self.transformedFacesFromFaces(faces)
        //获取faceLayers的key，用于确定哪些人移除了视图并将对应的图层移出界面。
        /*
         支持同时识别10个人脸
         */
        var lostFaces:[Int] = []
        for key in self.faceLayers.keys {
            lostFaces.append(key)
        }
        //遍历每个转换的人脸对象
        for faceL in transformedFaces {
            let face = faceL as! AVMetadataFaceObject
            let faceID:Int = face.faceID
            //将对象从lostFaces 移除
            lostFaces =  lostFaces.filter { i in
                return i != faceID
            }
            
            var layer:CALayer? = self.faceLayers[faceID]
            
            //拿到当前faceID对应的layer
            if (self.faceLayers[faceID] == nil) {
                //调用makeFaceLayer 创建一个新的人脸图层
                layer = self.makeFaceLayer()
                //将新的人脸图层添加到 overlayLayer上
                self.overlayLayer.addSublayer(layer!);
                //将layer加入到字典中
                self.faceLayers[faceID] = layer;
            }
            //设置图层的transform属性 CATransform3DIdentity 图层默认变化 这样可以重新设置之前应用的变化
            layer!.transform = CATransform3DIdentity
            //图层的大小 = 人脸的大小
            layer!.frame = face.bounds;
            
            //判断人脸对象是否具有有效的斜倾交。
            if face.hasRollAngle {
                //如果为YES,则获取相应的CATransform3D 值
//                CATransform3D t = [self transformForRollAngle:face.rollAngle];
//
//                //将它与标识变化关联在一起，并设置transform属性
//                layer.transform = CATransform3DConcat(layer.transform, t);
            }
            //判断人脸对象是否具有有效的偏转角
            if (face.hasYawAngle) {
                
                //如果为YES,则获取相应的CATransform3D 值
//                CATransform3D  t = [self transformForYawAngle:face.yawAngle];
//                layer.transform = CATransform3DConcat(layer.transform, t);
                
            }
        }
        
        //遍历数组将剩下的人脸ID集合从上一个图层和faceLayers字典中移除
        for faceId in lostFaces {
            let layer:CALayer = faceLayers[faceId]!
            layer.removeFromSuperlayer()
            faceLayers.removeValue(forKey: faceId)
        }
        
    }
    func makeFaceLayer() -> CALayer {
        let layer = CALayer.init()
        //边框宽度为5.0f
        layer.borderWidth = 5.0
        //边框颜色为红色
        layer.borderColor = UIColor.red.cgColor
//        layer.contents = (id)[UIImage imageNamed:@"551.png"].CGImage;
        return layer
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
    func THDegreesToRadians(_ degrees:CGFloat) -> CGFloat {
        return degrees*Double.pi
    }

}
