//
//  ViewController.swift
//  AVideo
//
//  Created by wesion on 2021/9/27.
//

import UIKit
import AVFoundation
import SnapKit
class ViewController: UIViewController{

    let arr = ["语音合成","滤镜","人脸识别"]
    
    lazy var engine = AVAudioEngine()
    lazy var mixer = AVAudioMixerNode()
    let tableView:UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { make in
            make.top.equalTo(44)
            make.left.right.bottom.equalTo(self.view)
        }
    }
}

extension ViewController:  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.arr[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let speechSynthesisVC = SpeechSynthesisViewController.init()
        let captureVC = CaptureViewController.init()
        let faceRecognitionVC = FaceRecognitionViewController.init()
        
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(speechSynthesisVC, animated: true)
        }else if (indexPath.row == 1){
            self.navigationController?.pushViewController(captureVC, animated: true)
        }else if(indexPath.row == 2){
            self.navigationController?.pushViewController(faceRecognitionVC, animated: true)
        }
        
        
    }
}

