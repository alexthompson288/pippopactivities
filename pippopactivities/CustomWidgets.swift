//
//  CustomWidgets.swift
//  pippopactivities
//
//  Created by Alex Thompson on 05/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//


import Foundation
import UIKit

extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}



class MyCustomButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        var redColor = UIColor(red: 242, green: 108, blue: 79)
        var yellowColor = UIColor(red: 255, green: 217, blue: 84)
        var blueColor = UIColor(red: 107, green: 231, blue: 255)
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10.0;
        self.layer.borderColor = UIColor.redColor().CGColor
        self.layer.borderWidth = 3
        self.backgroundColor = redColor
        self.tintColor = UIColor.whiteColor()
    }
}

class RoundedCornerView: UIView {
    required init(coder aDecoder: NSCoder) {
        var redColor = UIColor(red: 242, green: 108, blue: 79)
        var yellowColor = UIColor(red: 255, green: 217, blue: 84)
        var blueColor = UIColor(red: 107, green: 231, blue: 255)
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10.0;
        self.layer.borderColor = redColor.CGColor
        self.layer.borderWidth = 3
        self.backgroundColor = blueColor
        self.tintColor = UIColor.whiteColor()
    }
}

class TransparentView: UIView {
    required init(coder aDecoder: NSCoder) {
        var redColor = UIColor(red: 242, green: 108, blue: 79)
        var yellowColor = UIColor(red: 255, green: 217, blue: 84)
        var blueColor = UIColor(red: 107, green: 231, blue: 255)
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10.0;
        self.layer.borderColor = redColor.CGColor
        self.layer.borderWidth = 3
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
        self.tintColor = UIColor.whiteColor()
    }
}
