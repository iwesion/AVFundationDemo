//
//  FilterSettingView.swift
//  AVideo
//
//  Created by wesion on 2021/10/9.
//

import UIKit

class FilterSettingView: UIView {
    
    //滤镜
    let xFilter = XFilter()
    
    /// 亮度滑杆inputBrightness
    let s1:UISlider = {
        let s = UISlider.init()
        s.tag = 100
        s.minimumValue = 0
        s.maximumValue = 1
        s.value = 1
        return s
    }()
    
    /// 对比度滑杆inputContrast
    let s2:UISlider = {
        let s = UISlider.init()
        s.tag = 101
        s.minimumValue = 1
        s.maximumValue = 10
        s.value = 1
        return s
    }()
    
    /// 饱和度inputSaturation
    let s3:UISlider = {
        let s = UISlider.init()
        s.tag = 102
        s.minimumValue = 1
        s.maximumValue = 10
        s.value = 1
        return s
    }()
    
    /// 高斯模糊
    let s4:UISlider = {
        let s = UISlider.init()
        s.tag = 103
        s.minimumValue = 0
        s.maximumValue = 10
        
        return s
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(s1)
        //添加值改变监听器
        s1.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        s1.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        self.addSubview(s2)
        //添加值改变监听器
        s2.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        s2.snp.makeConstraints { make in
            make.top.equalTo(s1.snp.bottom).offset(20)
            make.centerX.equalTo(s1)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        self.addSubview(s3)
        //添加值改变监听器
        s3.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        s3.snp.makeConstraints { make in
            make.top.equalTo(s2.snp.bottom).offset(20)
            make.centerX.equalTo(s1)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        self.addSubview(s4)
        s4.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        s4.snp.makeConstraints { make in
            make.top.equalTo(s3.snp.bottom).offset(20)
            make.centerX.equalTo(s1)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.bottom.equalTo(self)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc
    func sliderDidChange(_ sender: UISlider) {
        switch sender.tag {
        case 100:
            xFilter.brightness = NSNumber(value: sender.value)
        case 101:
            xFilter.contrast = NSNumber(value: sender.value)
        case 102:
            xFilter.saturation = NSNumber(value: sender.value)
        case 103:
            xFilter.gaussianRadius = NSNumber(value: sender.value)
        default:
            break
            
        }
       
      print(sender.value)
        
    }
}

