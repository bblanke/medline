//
//  GradientView.swift
//  vitalflow
//
//  Created by Bailey Blankenship on 4/27/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import UIKit

class GradientView: UIViewController, CAAnimationDelegate{
    let gradientBackground = CAGradientLayer()
    var gradientColors : [CGColor] = []
    
    enum viewMood {
        case normal
        case warn
    }
    
    override func viewDidLoad() {
        gradientBackground.frame = self.view.bounds
        gradientColors = [UIColor.primary.cgColor, UIColor.accent.cgColor]
        gradientBackground.colors = gradientColors
        
        self.view.layer.insertSublayer(gradientBackground, at: 0)
    }
    
    func setVisualState(mood: viewMood){
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        animation.fillMode = kCAFillModeForwards
        
        let transitionGradient : [CGColor]
        switch(mood){
        case .normal:
            transitionGradient = [UIColor.primary.cgColor, UIColor.accent.cgColor]
            break
        case .warn:
            transitionGradient = [UIColor.warn.cgColor, UIColor.warn.cgColor]
            break
        }
        animation.fromValue = gradientColors
        animation.toValue = transitionGradient
        
        gradientColors = transitionGradient
        gradientBackground.add(animation, forKey: "colorAnim")
    }
}
