/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import QuartzCore

@IBDesignable
class AvatarView: UIView {
  
  //constants
  let lineWidth: CGFloat = 6.0
  let animationDuration = 1.0
  
  //ui
  let photoLayer = CALayer()
  let circleLayer = CAShapeLayer()
  let maskLayer = CAShapeLayer()
  let label: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "ArialRoundedMTBold", size: 18.0)
    label.textAlignment = .Center
    label.textColor = UIColor.blackColor()
    return label
    }()
  
  //variables
  @IBInspectable
  var image: UIImage! {
    didSet {
      photoLayer.contents = image.CGImage
    }
  }
  
  @IBInspectable
  var name: String? {
    didSet {
      label.text = name
    }
  }
  
  var shouldTransitionToFinishedState = false
  var isSquare = false
  
  override func didMoveToWindow() {
    layer.addSublayer(photoLayer)
    photoLayer.mask = maskLayer
    layer.addSublayer(circleLayer)
    addSubview(label)
  }
  
  override func layoutSubviews() {
    
    //Size the avatar image to fit
    photoLayer.frame = CGRect(
      x: (bounds.size.width - image.size.width + lineWidth)/2,
      y: (bounds.size.height - image.size.height - lineWidth)/2,
      width: image.size.width,
      height: image.size.height)
    
    //Draw the circle
    circleLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
    circleLayer.strokeColor = UIColor.whiteColor().CGColor
    circleLayer.lineWidth = lineWidth
    circleLayer.fillColor = UIColor.clearColor().CGColor
    
    //Size the layer
    maskLayer.path = circleLayer.path
    maskLayer.position = CGPoint(x: 0.0, y: 10.0)
    
    //Size the label
    label.frame = CGRect(x: 0.0, y: bounds.size.height + 10.0, width: bounds.size.width, height: 24.0)
  }
  
  func bounceOffPoint(bouncePoint: CGPoint, morphSize: CGSize) {
    let originalCenter = center
    
    UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
      self.center = bouncePoint
      }, completion: {_ in
        //complete bounce to
        if self.shouldTransitionToFinishedState {
          self.animateToSquare()
        }
    })
    
    UIView.animateWithDuration(animationDuration, delay: animationDuration, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: {
      self.center = originalCenter
      }, completion: {_ in
        delay(seconds: 0.1) {
          if !self.isSquare {
            self.bounceOffPoint(bouncePoint, morphSize: morphSize)
          }
        }
    })

    let morphedFrame = (originalCenter.x > bouncePoint.x) ?
      
      CGRect(x: 0.0, y: bounds.height - morphSize.height,
        width: morphSize.width, height: morphSize.height):
      
      CGRect(x: bounds.width - morphSize.width,
        y: bounds.height - morphSize.height,
        width: morphSize.width, height: morphSize.height)

    let morphAnimation = CABasicAnimation(keyPath: "path")
    morphAnimation.duration = animationDuration
    morphAnimation.toValue = UIBezierPath(ovalInRect: morphedFrame).CGPath
    morphAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    circleLayer.addAnimation(morphAnimation, forKey:nil)
    maskLayer.addAnimation(morphAnimation, forKey: nil)
  }
  
  func animateToSquare() {
    isSquare = true
    
    let squarePath = UIBezierPath(rect: bounds).CGPath
    let morph = CABasicAnimation(keyPath: "path")
    morph.duration = 0.25
    morph.fromValue = circleLayer.path
    morph.toValue = squarePath
    
    circleLayer.addAnimation(morph, forKey: nil)
    maskLayer.addAnimation(morph, forKey: nil)
    
    circleLayer.path = squarePath
    maskLayer.path = squarePath
  }
}
