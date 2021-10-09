//
//  SpeechSynthesisViewController.swift
//  AVideo
//
//  Created by wesion on 2021/9/28.
//

import UIKit
import AVFoundation
class SpeechSynthesisViewController: UIViewController {
    // Create an utterance.
    let utterance:AVSpeechUtterance = {
        let utterance = AVSpeechUtterance(string: "AVFoundation是很多处理基于时间的音视频文件的框架之一。你可以用它来检查，创建，编辑或者对媒体文件重编码。可以从设备中得到输入流，以及在实时捕捉和播放的时候对视频进行处理。")
        // Configure the utterance.
        utterance.rate = 0.56//设置语速
        utterance.pitchMultiplier = 1//设置语调
        utterance.postUtteranceDelay = 0.0//
        utterance.volume = 0.8//设置音量
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        return utterance
    }()
    let synthesizer = AVSpeechSynthesizer()
    
    
    
    let btn:UIButton = {
        let btn = UIButton.init()
        btn.setTitle("开始", for: .normal)
        return btn
    }()
    
    let s1:UISlider = {
        let s = UISlider.init()
        s.minimumValue = 0
        s.maximumValue = 1
        
        return s
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        //UI
        
        self.view.addSubview(btn)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(start), for: .touchUpInside)
        btn.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.centerX.equalTo(self.view)
            make.height.equalTo(50)
            make.width.equalTo(100)
        }
        
        
        
        self.view.addSubview(s1)
        //添加值改变监听器
        s1.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        s1.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        
        synthesizer.delegate = self
    }
    @objc func start(_ sender: UIButton) {
        synthesizer.speak(utterance)
    }
    @objc
    func sliderDidChange(_ sender: UISlider) {
      print(sender.value)
        utterance.volume = sender.value//设置语速
    }

}

extension SpeechSynthesisViewController:AVSpeechSynthesizerDelegate{
    //当合成器开始说话时
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        btn.setTitle("播放中", for: .normal)
    }
    //当合成器将要说出一段话语文本时
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
    }
    //当合成器在说话时暂停时
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        
    }
    //当合成器取消说话时
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        
    }
    //当合成器完成说话时
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        btn.setTitle("开始", for: .normal)
    }
    //当合成器在暂停后恢复说话
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        
    }
    
}
