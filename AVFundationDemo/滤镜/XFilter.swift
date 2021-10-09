//
//  XFilter.swift
//  AVideo
//
//  Created by wesion on 2021/9/29.
//

import UIKit

class XFilter: NSObject {
    ///饱和度
    var saturation:NSNumber = 1
    ///亮度0-1
    var brightness:NSNumber = 0.5
    ///对比度
    var contrast:NSNumber = 0
    
    /// 高斯模糊圆角
    var gaussianRadius:NSNumber = 1
    
    
func colorControlFilter(_ input: CIImage) -> CIImage?
        {
            let sepiaFilter = CIFilter(name:"CIColorControls")
            sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
            sepiaFilter?.setValue(saturation, forKey: kCIInputSaturationKey)//饱和度
            sepiaFilter?.setValue(brightness, forKey: kCIInputBrightnessKey)//亮度
            sepiaFilter?.setValue(contrast, forKey: kCIInputContrastKey)//对比度
            return sepiaFilter?.outputImage
        }
    
    /// 高斯模糊
    /// - Parameter input: CIImage
    /// - Returns: CIImage
    func gaussianBlurFilter(_ input: CIImage)->CIImage? {
            //        CIFilter.filterNames(inCategory: "")//获取所有滤镜名
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(input, forKey: kCIInputImageKey)
            filter?.setValue(gaussianRadius, forKey: kCIInputRadiusKey)
//            print(filter!.attributes)//获取某一滤镜的所有属性
//            print(filter!.inputKeys)//获取某一属性的所有输入项
            return filter?.outputImage
        }
}
