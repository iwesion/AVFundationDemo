//
//  TrailorSideView.swift
//  AVFundationDemo
//
//  Created by wesion on 2021/10/14.
//

import UIKit

public protocol TrailorSideViewDelegate:NSObjectProtocol {
    func callBackStartAndEndTime(_ start: CGFloat, _ end: CGFloat)
}

class TrailorSideView: UIView {
   open weak var delegate:TrailorSideViewDelegate?
    let left : UIImageView = {
        let img:UIImageView = .init(image: UIImage.init(named: "icon_arrow_left_light"))
        
        return img
    }()
    
    let right : UIImageView = {
        let img:UIImageView = .init(image: UIImage.init(named: "ic_arrow_right"))
        return img
    }()
    
    var touch:UITouch?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(left)
        self.addSubview(right)
        left.backgroundColor = .darkGray
        right.backgroundColor = .darkGray
        
        left.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(50)
        }
        right.snp.makeConstraints { make in
            make.right.top.bottom.equalTo(self)
            make.width.equalTo(50)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t:UITouch = touches.first else { return }
        let currentPoint:CGPoint = t.location(in: self.superview)
        let previousPoint:CGPoint = t.previousLocation(in: self.superview)
        let dlx = previousPoint.x - currentPoint.x
//        let dly = currentPoint.y - previousPoint.y
        
        let leftPoint:CGPoint = t.location(in: left)
        let rightPoint:CGPoint = t.location(in: right)
        
        
        
        if (left.layer.contains(leftPoint)) {
            var chgX:CGFloat = left.center.x - dlx
            if chgX < 25 {
                chgX = 25
            }
            if chgX > right.center.x - 50 {
                chgX = right.center.x - 50
            }
            let newCenter:CGPoint = .init(x: chgX , y: left.center.y)
            left.center = newCenter
        }
        if (right.layer.contains(rightPoint)) {
            var chgX:CGFloat = right.center.x - dlx
            if chgX > HSScreen.init().width() - 25 - 100 {
                chgX = HSScreen.init().width() - 25 - 100
            }
            if chgX < left.center.x + 50 {
                chgX = left.center.x + 50
            }
            let newCenter:CGPoint = .init(x: chgX , y: right.center.y)
            right.center = newCenter
        }

        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let leftX:CGFloat = ( left.frame.origin.x) / (self.bounds.width - 100)
        let rightX:CGFloat = (right.frame.origin.x) / (self.bounds.width - 50)
        
        
        delegate?.callBackStartAndEndTime(leftX, rightX)
    }
}
