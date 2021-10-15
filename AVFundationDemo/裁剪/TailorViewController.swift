//
//  TailorViewController.swift
//  AVFundationDemo
//
//  Created by wesion on 2021/10/13.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary
import Photos
class TailorViewController: UIViewController {
    
    
   


    var palyerItem:AVPlayerItem?
    var player = AVPlayer()



    let scroll:UIScrollView = {
        let scrollView = UIScrollView.init()
        return scrollView
    }()

    let tailorScroll:UIScrollView = {
        let scrollView = UIScrollView.init()
        return scrollView
    }()
    let sideView:TrailorSideView = .init()

    let playBtn:UIButton = {
            let btn = UIButton.init(type: UIButton.ButtonType.custom )
            btn.setTitle("播放", for: .normal)
            btn.setTitle("暂停", for: .selected)
            return btn
        }()
    let saveBtn:UIButton = {
            let btn = UIButton.init(type: UIButton.ButtonType.custom )
            btn.setTitle("裁剪", for: .normal)
            return btn
        }()
    

    var imgArr:[UIImageView] = []
    //开始时间和结束时间
    var startTime : CMTime?
    var durationTime : CMTime?
    var videoTotalTime:Int64 = 0
    var asset:AVURLAsset!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
//        self.view.addSubview(scroll)
//        scroll.snp.makeConstraints { make in
//            make.height.equalTo(200)
//            make.left.right.bottom.equalTo(self.view)
//        }
        self.view.addSubview(tailorScroll)
        tailorScroll.isScrollEnabled = false
        tailorScroll.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(100)
            make.right.equalTo(-100)
        }
        self.view.addSubview(sideView)
        sideView.delegate = self
        sideView.snp.makeConstraints { make in
            make.left.equalTo(tailorScroll).offset(-50)
            make.top.bottom.equalTo(tailorScroll)
            make.right.equalTo(tailorScroll).offset(50)
        }

        self.view.addSubview(playBtn)
        playBtn.backgroundColor = .red
        playBtn.addTarget(self, action: #selector(chgSelectBtn(_:)), for: .touchUpInside)
        playBtn.snp.makeConstraints { make in
            make.bottom.equalTo(sideView).offset(-50)
            make.centerX.equalTo(self.view)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        self.view.addSubview(saveBtn)
        saveBtn.backgroundColor = .red
        saveBtn.addTarget(self, action: #selector(saveSelectBtn(_:)), for: .touchUpInside)
        saveBtn.snp.makeConstraints { make in
            make.bottom.equalTo(playBtn).offset(-50)
            make.centerX.equalTo(self.view)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        
        
        guard let filePath = Bundle.main.path(forResource: "hali.mp4", ofType: nil) else {
            return
        }

        let fileURL:URL = URL(fileURLWithPath: filePath)
        addAVPlayer(fileURL)
        asset = .init(url: fileURL)
        //seconds
       videoTotalTime =   asset.duration.value / Int64( asset.duration.timescale);

        print(videoTotalTime)


        var framesArray:[NSValue] = []


        let generator:AVAssetImageGenerator = .init(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = CMTime.zero
        generator.requestedTimeToleranceBefore = CMTime.zero
        for i in 0...videoTotalTime {
            let time:CMTime = CMTimeMakeWithSeconds(Float64(i), preferredTimescale: asset.duration.timescale)
            let frames:NSValue = NSValue.init(time: time)

            framesArray.append(frames)
        }
        self.addUI(framesArray.count)
        var i:Int = 0
        generator.generateCGImagesAsynchronously(forTimes: framesArray) { [weak self] requestedTime, image, actualTime, result, error in
            
            switch result {
            case .succeeded:
                i += 1
                DispatchQueue.main.async {
                    print("framesArray=\(framesArray.count)---\(i)")
                    self?.imgArr[i].image = .init(cgImage: image!)
                }
                break

            case .failed:
                print("失败")
            case .cancelled:
                print("出错了")
            default:
                break
            }
        }

    }
    func addAVPlayer(_ url:URL) {
        //创建媒体资源管理对象
        palyerItem = AVPlayerItem(url: url as URL)
        //创建ACplayer：负责视频播放
        player = AVPlayer.init(playerItem: self.palyerItem)
        player.rate = 1.0//播放速度 播放前设置
        player.addPeriodicTimeObserver(forInterval: .init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), queue: DispatchQueue.main) {[weak self] timex in
            
            if self!.durationTime != nil {
                if timex >= self!.durationTime! {
                    self!.player.pause()
                }
            }
           
        }
        //创建显示视频的图层
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = CGRect.init(x: 0, y: 0, width: HSScreen.init().width(), height: HSScreen.init().height() - 100)
        self.view.layer .addSublayer(playerLayer)
       
    }

    func addUI(_ n:Int) {
        var imgView = UIImageView()

        for i in 0...n {
            let img:UIImageView = .init()
            tailorScroll.addSubview(img)
            img.snp.makeConstraints { make in
                if i == 0 {
                    make.left.equalTo(tailorScroll)
                }else{
                    make.left.equalTo(imgView.snp.right)
                }
                make.top.bottom.equalTo(tailorScroll)
                make.width.equalTo( (HSScreen.init().width() - 100) / CGFloat( n))
                make.height.equalTo(50)
                if i == n {
                    make.right.equalTo(tailorScroll)
                }
            }
            if i%2 == 0 {
                img.backgroundColor = .green
            }else{
                img.backgroundColor = .purple
            }
            imgView = img
            imgArr.append(img)
        }
    }
    @objc func chgSelectBtn(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            player.play()
        }else{
            player.pause()
        }
    }
    @objc func saveSelectBtn(_ sender:UIButton) {
        let timeRange:CMTimeRange = CMTimeRangeMake(start: startTime!, duration: durationTime!)
        print("timeRange = \(timeRange)")
        guard let exporter:AVAssetExportSession = .init(asset: asset, presetName: AVAssetExportPreset640x480) else{
            print("初始化exporter失败")
            return
        }
        //优化网络
        exporter.shouldOptimizeForNetworkUse = true;
        //设置输出路径
        
        let fileURL = TailorViewController.createTemplateFileURL()
        
        exporter.outputURL = fileURL
           //设置输出类型
        exporter.outputFileType = .mp4;
        exporter.timeRange = timeRange
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                switch exporter.status {
                case .failed:
                    print("failed")
                case .cancelled:
                    print("cancelled")
                case .completed:
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
                    } completionHandler: { success, err in
                        
                    }

                    print("completed")

                default:
                    break
                }
            }
        }
        
    }
    class func createTemplateFileURL() -> URL {
        
        NSHomeDirectory()
        let path = NSTemporaryDirectory() + "writeTemp.mp4"
        let fileURL = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do { try FileManager.default.removeItem(at: fileURL) } catch {
                
            }
        }
        return fileURL
    }
}

extension TailorViewController: TrailorSideViewDelegate {
    func callBackStartAndEndTime(_ start: CGFloat, _ end: CGFloat) {
        print("\(start)到\(end)")
        startTime = CMTimeMakeWithSeconds( start * CGFloat(videoTotalTime)  , preferredTimescale: asset.duration.timescale)
        durationTime = CMTimeMakeWithSeconds(end * CGFloat(videoTotalTime) , preferredTimescale: asset.duration.timescale)
       
        player.seek(to: startTime!)
       
    }
}
