//
//  SwiftPlayerManager.swift
//  AVPlayerTest
//
//  Created by Neo on 2018/4/25.
//  Copyright © 2018年 Neo. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import SnapKit
open class SwiftPlayerManager: NSObject{
    private lazy var pasterView: PasterView! = {
        let view = Bundle(for: PasterView.self).loadNibNamed("PasterView", owner: self, options: nil)?.first as! PasterView
        //控件点击的事件都在View中,如果要自定义事件,请单独设置代理
        view.delegate = self
        view.avPlayerLayer = self.avPlayerLayer
        return view
    }()
    private var contentView : UIView!
    private var avItem : AVPlayerItem!
    private var avPlayer : AVPlayer!
    private var avPlayerLayer : AVPlayerLayer!
    private var link : CADisplayLink!
    open static let share = SwiftPlayerManager()
    
    /// 新建播放
    ///
    /// - Parameters:
    ///   - url: 播放的视频源
    ///   - contentView: 要添加到的View
    ///   - customerDelgate: 如果要自定义单双击的事件 实现次代理
    open func newPlayer(withURL url: URL,contentView: UIView,customerDelgate: CustomControlEvent? = nil){
        avItem = AVPlayerItem(url: url)
        avPlayer = AVPlayer(playerItem: avItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayerLayer.contentsScale =  UIScreen.main.scale
        self.contentView = contentView
        self.pasterView.layer.insertSublayer(avPlayerLayer, at: 0)
        self.pasterView.customerDelegate = customerDelgate
        self.contentView.addSubview(pasterView)
        self.configUI(index: 1)
        //监听播放的状态
        self.avItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)
        self.avItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: NSKeyValueObservingOptions.new, context: nil)
        //监听旋转的方向
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChange(notification:)), name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
        //播放中的更新操作 : 时间Label 进度条等
        self.link = CADisplayLink(target: self, selector: #selector(SwiftPlayerManager.updateTime))
        self.link.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        self.avPlayer.play()
    }
    
    /// 暂停播放
    open func pausePlayer(){
        self.isPlay(false)
    }
    
    /// 取消播放
    open func releasePlayer(){
        pasterView.removeFromSuperview()
        pasterView = nil
        avItem = nil
        avPlayer = nil
        avPlayerLayer = nil
        link.invalidate()
        link = nil
        contentView = nil
    }
    
    
    
    @objc private func updateTime(){
        let current = CMTimeGetSeconds(self.avPlayer.currentTime())
        let total   = CMTimeGetSeconds(avItem.duration)
        let timeStr = "\(formatPlayTime(secounds: total))"
        pasterView.timeLabel.text = timeStr
        let currentTime = "\(formatPlayTime(secounds: current))"
        let totalTime = "\(formatPlayTime(secounds: total))"
        pasterView.currentTimeLabel.text = currentTime
        pasterView.timeLabel.text = totalTime
        pasterView.update(sliderValue: Float(current/total))
    }
    //屏幕旋转的监听方法
    @objc private func orientationChange(notification: NSNotification){
        if let index = notification.userInfo?["UIApplicationStatusBarOrientationUserInfoKey"] as? Int{
            print(index)
            self.configUI(index: index)
        }
    }
    private func configUI(index: Int){
        switch index{
        case 3,4:
            pasterView.removeFromSuperview()
            UIApplication.shared.keyWindow?.addSubview(pasterView)
            self.pasterView.snp.remakeConstraints { (make) in
                make.edges.equalTo(UIApplication.shared.keyWindow!)
            }
            self.pasterView.updateModeBtn(isfull: true)
        case 1:
            pasterView.removeFromSuperview()
            self.contentView.addSubview(pasterView)
            pasterView.snp.remakeConstraints { (make) in
                make.edges.equalTo(self.contentView)
            }
            self.pasterView.updateModeBtn(isfull: false)
        default:
            break
        }
        
    }
    private func formatPlayTime(secounds:TimeInterval)->String{
        if secounds.isNaN{
            return "00:00"
        }
        let Min = Int(secounds / 60)
        let Sec = Int(Int(secounds) % 60)
        return String(format: "%02d:%02d", Min, Sec)
    }
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else{
            return
        }
        if keyPath == #keyPath(AVPlayerItem.status){
            switch playerItem.status{
            case .failed:
                print("播放失败重新加载")
            case .readyToPlay:
                print("准备播放")
            case .unknown:
                print("未知错误")
            }
        }
        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges){
            let loadedTime = self.avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            let percent = loadedTime/totalTime
            self.pasterView.progressView.progress = Float(percent)
        }
    }
    private func avalableDurationWithplayerItem() -> TimeInterval{
        guard let first = avItem.loadedTimeRanges.first else{
            fatalError()
        }
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecound = CMTimeGetSeconds(timeRange.duration)
        return startSeconds + durationSecound
        
    }
}
extension SwiftPlayerManager: PasterViewProtocl{
    func toFull() {
        UIDevice.current.setValue(NSNumber(integerLiteral: UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
    }
    
    
    func toPaster() {
        UIDevice.current.setValue(NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }
    
    func isPlay(_ bool: Bool) {
        if bool{
            self.avPlayer.play()
        }else{
            self.avPlayer.pause()
        }
    }
    
    func userSlider(to progress: Float, complete: @escaping () -> Void) {
        if self.avPlayer.status == AVPlayerStatus.readyToPlay{
            let duration = Float64(progress) * CMTimeGetSeconds(avItem.duration)
            let seekTime = CMTime(seconds: Double(duration), preferredTimescale: 1)
            self.avPlayer.seek(to: seekTime) { (bool) in
                complete()
            }
        }
    }
    
    
    
}
