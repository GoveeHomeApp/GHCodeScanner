//
//  GHScanNetAnimationView.swift
//  GHAuthManager
//
//  Created by songyang on 2023/10/20.
//  Copyright © 2021 Govee. All rights reserved.
//

import UIKit

class GHScanNetAnimation: UIImageView {

    var isAnimationing = false
    var animationRect = CGRect.zero

    public static func instance() -> GHScanNetAnimation {
        return GHScanNetAnimation()
    }
    
    func startAnimatingWithRect(animationRect: CGRect, parentView: UIView, image: UIImage?) {
        self.image = image
        self.animationRect = animationRect
        parentView.addSubview(self)

        isHidden = false

        isAnimationing = true

        if image != nil {
            stepAnimation()
        }
    }

    @objc func stepAnimation() {
        guard isAnimationing else {
            return
        }
        var frame = animationRect

        let hImg = image!.size.height * animationRect.size.width / image!.size.width

//        frame.origin.y -= hImg
        frame.size.height = hImg
        self.frame = frame

        alpha = 1.0

        UIView.animateKeyframes(withDuration: 3, delay: 0, options: .calculationModeLinear) {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 9/10) {
                var frame = self.animationRect
                let hImg = self.image!.size.height * self.animationRect.size.width / self.image!.size.width
                frame.origin.y += (frame.size.height - hImg - frame.size.height/10)
                frame.size.height = hImg
                self.frame = frame
            }
            
            UIView.addKeyframe(withRelativeStartTime: 9/10, relativeDuration: 1/10) {
                var frame = self.animationRect
                let hImg = self.image!.size.height * self.animationRect.size.width / self.image!.size.width
                frame.origin.y += (frame.size.height - hImg)
                frame.size.height = hImg
                self.alpha = 0.0
                self.frame = frame
            }
            
        } completion: { _ in
            self.perform(#selector(GHScanNetAnimation.stepAnimation), with: nil, afterDelay: 0.3)
        }
    }

    func stopStepAnimating() {
        isHidden = true
        isAnimationing = false
    }

}

