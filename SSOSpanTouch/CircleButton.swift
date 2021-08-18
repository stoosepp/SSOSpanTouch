//
//  CircleButton.swift
//  FirebaseTest
//
//  Created by Stoo on 2016-09-22.
//  Copyright © 2016 StooSepp. All rights reserved.
//

import UIKit

protocol CircleButtonDelegate {
    func circleTapped(_ sender:CircleButton)
}

@IBDesignable

class CircleButton: UIView {

    @IBInspectable var showRing:Bool = true
    @IBInspectable var isnumberButton:Bool = false{
        didSet{
            setNeedsDisplay()
        }
    }

    @IBInspectable var image:UIImage?{
        didSet{
            setNeedsDisplay()
        }
    }

    @IBInspectable var labelText:String?{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var lineWidth:CGFloat = 1{
        didSet{
            setNeedsDisplay()
        }
    }
    var strokeColor:UIColor = .black{
        didSet{
            setNeedsDisplay()
        }
    }
    
    
    @IBInspectable var text:String?
    
    var selected:Bool = false{
        didSet{
            setNeedsDisplay()
        }
    }
    var highlighted:Bool = false
    var index:Int = 0
    
    //var imageView:UIImageView!
    var titleLabel:UILabel!
    var didDraw:Bool = false

    
    var delegate:CircleButtonDelegate?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
       
        backgroundColor = UIColor.clear
        
        if didDraw == false{
            titleLabel = UILabel()
            titleLabel.frame = self.bounds
            titleLabel.textAlignment = .center
           
            if let tempText = labelText{
                if tempText.characters.count == 1{
                    let adjustedFontSize = self.frame.size.height / 2
                    titleLabel.font = titleLabel.font.withSize(adjustedFontSize)
                    titleLabel.textAlignment = .center
                    titleLabel.textColor = UIColor.black
                }
                else{
                    titleLabel.adjustsFontSizeToFitWidth = true
                    let currentfontSize = titleLabel.font.pointSize
                    titleLabel.font = titleLabel.font.withSize(currentfontSize * 2)
                }
            }
            self.addSubview(titleLabel)
            
            
            if image != nil{
                let imageView = UIImageView()
                imageView.frame = self.bounds.insetBy(dx: 10, dy: 10)
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                imageView.image = image!
                self.addSubview(imageView)
            }
            didDraw = true
        }
       
        //Set Text and Imag, If they exist.
         if labelText != nil{
            titleLabel.text = labelText
        }
        if image != nil{
            for view in self.subviews{
                if view.isKind(of: UIImageView.self){
                    (view as! UIImageView).image = image!
                    break
                }
            }
            
        }
        
        // Drawing code
       let ovalPath = UIBezierPath(ovalIn: CGRect(x: lineWidth/2, y: lineWidth/2, width: self.bounds.size.width-lineWidth, height: self.bounds.size.width-lineWidth))
        
        if showRing{
            //print("Title Label is \(labelText!)")
            strokeColor.setStroke()
            ovalPath.lineWidth = lineWidth
            ovalPath.stroke()
            if selected || highlighted{
                if isnumberButton == true {
                    UIColor.black.setFill()
                    ovalPath.fill()
                    titleLabel.textColor = UIColor.white
                }
                else {
                    UIColor.lightGray.setFill()
                    ovalPath.fill()
                }
                
                
            }
            else{
                titleLabel.textColor = UIColor.black
                UIColor.white.setFill()
                ovalPath.fill()
            }
        }
        else{
            titleLabel.textColor = UIColor.black
        }
        //self.backgroundColor = UIColor.clearColor()
    }
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlighted = true
        setNeedsDisplay()
        /*if delegate != nil && delegate is VPTViewController{
            updateDelegate()
        }*/
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       highlighted = false
     
        
        if isnumberButton == false{//I think this is all about tap training
            if selected == true{
                selected = false
            }
            else{
                selected = true
            }
        }
        
       /* if delegate != nil && delegate is VPTViewController{
            selected = false
        }*/
        if delegate != nil{
            updateDelegate()
        }
        setNeedsDisplay()
    }
 
    func updateDelegate(){
        delegate?.circleTapped(self)
    }
 

}
