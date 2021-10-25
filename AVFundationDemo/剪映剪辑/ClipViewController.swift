//
//  ClipViewController.swift
//  AVFundationDemo
//
//  Created by wesion on 2021/10/20.
//

import UIKit
import AVFoundation
import AVKit
class ClipViewController: UIViewController {
    let screen = HSScreen.init()
    //媒体资源管理对象
    var palyerItem:AVPlayerItem?
    //播放器
    var player = AVPlayer()
    var asset:AVURLAsset!
    //播放器高度
    var playerHeight : CGFloat = 400
    //视频总时长
    var videoTotalTime : Int64!
    //视频缩略图倍率
    var videoTimeScale = 1
    //视频缩略图数组
    var imgArr:[CGImage] = []
    
    
    /// 播放控制按钮
    var playButton: UIButton = {
        let playButton = UIButton()
        playButton.setTitle("播放", for: .normal)
        playButton.setTitle("暂停", for: .selected)
        playButton.backgroundColor = UIColor.red
        playButton.sizeToFit()
        return playButton
    }()
    //进度时间
    var timeLab:UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14)
        return lab
    }()
    var collectionView:UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 0.6294681079)
        guard let filePath = Bundle.main.path(forResource: "hali.mp4", ofType: nil) else {
            return
        }

        let fileURL:URL = URL(fileURLWithPath: filePath)
        addAVPlayer(fileURL)
        gotAsset(fileURL)
        addUI()
        
    }
    func addAVPlayer(_ url:URL) {
        //创建媒体资源管理对象
        palyerItem = AVPlayerItem(url: url as URL)
        //创建ACplayer：负责视频播放
        player = AVPlayer.init(playerItem: self.palyerItem)
        player.rate = 1.0//播放速度 播放前设置
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: DispatchQueue.main) { [weak self] (time) in
            guard let weakself = self else { return  }
            weakself.timeLab.text = "\(time.value / Int64(time.timescale))/\(weakself.asset.duration.value / Int64( weakself.asset.duration.timescale))"
            weakself.collectionView.contentOffset.x = CGFloat(time.value / Int64(time.timescale)) * 50.0
            print("进度---\(time.value)---\(time.timescale)")
//            print(CGFloat(time.value)/CGFloat(time.timescale))
        }
        //创建显示视频的图层
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = CGRect.init(x: 0, y: 0, width: screen.width(), height: playerHeight)
        self.view.layer .addSublayer(playerLayer)
        player.pause()
       
    }
    func gotAsset(_ url:URL) {
        asset = .init(url: url)
        //seconds
        videoTotalTime = asset.duration.value / Int64( asset.duration.timescale)
        getGenerator()
    }
    func getGenerator() {
        let generator:AVAssetImageGenerator = .init(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = CMTime.zero
        generator.requestedTimeToleranceBefore = CMTime.zero
        var framesArray:[NSValue] = []
        
        for i in 0...videoTotalTime {
            let time:CMTime = CMTimeMakeWithSeconds(Float64(i), preferredTimescale: asset.duration.timescale)
            let frames:NSValue = NSValue.init(time: time)

            framesArray.append(frames)
        }
        
        generator.generateCGImagesAsynchronously(forTimes: framesArray) { [weak self] requestedTime, image, actualTime, result, error in
            
            switch result {
            case .succeeded:
                DispatchQueue.main.async {
                    print("requestedTime\(requestedTime.value / Int64(requestedTime.timescale))")
                    self?.imgArr.append(image!)
                    self?.collectionView.reloadData()
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
    func addUI() {
        self.view.addSubview(playButton)
        playButton.addTarget(self, action: #selector(playerOrpause(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { make in
            make.top.equalTo(playerHeight)
            make.centerX.equalTo(self.view)
        }
        self.view.addSubview(timeLab)
        timeLab.snp.makeConstraints { make in
            make.centerY.equalTo(playButton)
            make.left.equalTo(30)
        }
        initCollectionView()
    }
    func initCollectionView() {
        
        // 1.创建CollectionView布局
        
        // 创建布局实例
        let flowLayout = UICollectionViewFlowLayout()
        // 指定item的大小
        flowLayout.itemSize = .init(width: 50, height: 100)
        // 指定item左右和上下间距
        flowLayout.minimumLineSpacing = CGFloat(0)
        flowLayout.minimumInteritemSpacing = CGFloat(0)
        flowLayout.scrollDirection = .horizontal
        // 2.创建CollectionView
        
        // 创建CollectionView并应用布局
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(ClipVCCollectionCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(playButton.snp.bottom).offset(50)
            make.left.right.equalTo(self.view)
            make.height.equalTo(100)
        }
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchDid(_ :)))
        collectionView.addGestureRecognizer(pinch)
    }
    
    @objc func playerOrpause(_ sender:UIButton)  {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            player.pause()
        }else{
            player.play()
        }
        
    }
    //捏合手势
    @objc func pinchDid(_ pinch:UIPinchGestureRecognizer) {
        if pinch.scale > 1 {
           //1->2
//            print("pinch.scale===\(pinch.scale)")
//            print(1/Int((pinch.scale - 1)*10))
        }else{
            //1->0
            videoTimeScale = Int(pinch.scale*10)
            //
        }
        
        collectionView.reloadData()
        print("捏合比例\(pinch.scale)")//打印捏合比例
//        print(pinch.velocity)//打印捏合速度
    }
}
extension ClipViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count/videoTimeScale
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ClipVCCollectionCell
        let cnt = indexPath.row * videoTimeScale
        cell.imageView.image = .init(cgImage: imgArr[cnt])
        return cell
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let time:CMTime = CMTimeMakeWithSeconds(Float64(Int(scrollView.contentOffset.x)/50*videoTimeScale), preferredTimescale: asset.duration.timescale)
        print(Float64(scrollView.contentOffset.x/50))
//        player.seek(to: time)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}

class ClipVCCollectionCell: UICollectionViewCell {
    
    var localIdentifier: String?
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        return imageView
    }()
}
