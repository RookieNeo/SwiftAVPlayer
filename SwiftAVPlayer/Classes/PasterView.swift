//
//  PasterView.swift
//  AVPlayerTest
//
//  Created by Neo on 2018/4/20.
//  Copyright © 2018年 Neo. All rights reserved.
//

import UIKit
import AVFoundation
//class PasterModel{
//
//}
public protocol CustomControlEvent: class {
    func tapOnce()
    func tapTwice()
}
protocol PasterViewProtocl: class {
    func userSlider(to progress: Float,complete : @escaping() -> Void)
    func isPlay(_ bool : Bool)
    func toFull()
    func toPaster()
}
class PasterView: UIView {

    @IBOutlet weak var playModelBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var tapTwiceGesture: UITapGestureRecognizer!
    @IBOutlet weak var tapOnceGesture: UITapGestureRecognizer!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    //自定义单击双击事件
    weak var customerDelegate: CustomControlEvent?
    weak var delegate: PasterViewProtocl?
    weak var avPlayerLayer: AVPlayerLayer?
    private var canUpdateSlider = true //在用户滑动的时候不可以更新
    private var controlSubViewsHidden = false{
        didSet{
            _ = controlView.subviews.map {$0.isHidden = !$0.isHidden}
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        timeSlider.addTarget(self, action: #selector(PasterView.slideTouchDown(slider:)), for: UIControlEvents.touchDown)
        timeSlider.addTarget(self, action: #selector(PasterView.slideTouchOut(slider:)), for: UIControlEvents.touchUpOutside)
        timeSlider.addTarget(self, action: #selector(PasterView.slideTouchOut(slider:)), for: UIControlEvents.touchUpInside)
        timeSlider.addTarget(self, action: #selector(PasterView.slideTouchOut(slider:)), for: UIControlEvents.touchCancel)
        tapOnceGesture.require(toFail: tapTwiceGesture)
        controlSubViewsHidden = true
    }
    @objc private func slideTouchDown(slider: UISlider){
        canUpdateSlider = false
    }
    @objc private func slideTouchOut(slider: UISlider){
        delegate?.userSlider(to: slider.value, complete: {[weak self] in
            self?.canUpdateSlider = true
        })
    }
    @IBAction private func btnClick(_ sender: Any) {
        if playBtn.isSelected{
            delegate?.isPlay(true)
        }else{
            delegate?.isPlay(false)
        }
        playBtn.isSelected = !playBtn.isSelected
        
    }
    @IBAction private func tapTwiceClick(_ sender: Any) {
        if let customerEvent = customerDelegate{
            customerEvent.tapOnce()
        }else{
            if playBtn.isSelected{
                delegate?.isPlay(true)
            }else{
                delegate?.isPlay(false)
            }
            playBtn.isSelected = !playBtn.isSelected
        }
        print("双击")
    }
    @IBAction private func tapOnceClick(_ sender: Any) {
        if let customerEvent = customerDelegate{
            customerEvent.tapOnce()
        }else{
            controlSubViewsHidden = !controlSubViewsHidden
        }
        print("单击")
    }
    @IBAction private func toFullOrPasterBtnClick(_ sender: Any) {
        if let btn = sender as? UIButton{
//            btn.isSelected = !btn.isSelected
            if !btn.isSelected{
                delegate?.toFull()
            }else{
                delegate?.toPaster()
            }
        }
    }
    func update(sliderValue value: Float){
        if canUpdateSlider{
            timeSlider.setValue(value, animated: false)
        }
    }
    func updateModeBtn(isfull: Bool){
        if isfull{
            playModelBtn.isSelected = true
        }else{
            playModelBtn.isSelected = false
        }
    }
    override func layoutSubviews() {
        self.avPlayerLayer?.frame = self.bounds
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
