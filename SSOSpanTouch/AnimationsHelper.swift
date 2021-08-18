//
//  AnimationsHelper.swift
//  FirebaseTest
//
//  Created by Stoo on 2016-09-22.
//  Copyright © 2016 StooSepp. All rights reserved.
//

import UIKit

class AnimationsHelper{
    
    class func shakeView(_ view:UIView)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.075
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 3, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 3, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
    
    class func fadeIn(_ view:UIView){
        view.alpha = 0.0
        view.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 1
        })
    }

    
    class func fadeOut(_ view:UIView){
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 0.0
            }, completion: {
                (value: Bool) in
                view.isHidden = true
                view.alpha = 1.0
        })
    }
    class func fadeInLayer(_ layer:CALayer){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.repeatCount = 0
        animation.duration = 0.2
        layer.add(animation, forKey: "opacity")
    }
    
    class func fadeOutLayer(_ layer:CALayer){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0
        animation.repeatCount = 0
        animation.duration = 0.2
        layer.add(animation, forKey: "opacity")
    }
    
    class func fadeOutWithCompletion(_ view:UIView, didComplete:@escaping (_ didComplete:Bool) ->()){
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 0.0
        }, completion: {
            (value: Bool) in
            view.isHidden = true
            didComplete(true)            
        })
    }

}
