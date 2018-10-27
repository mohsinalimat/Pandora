//
//  MenuTransitionManager.swift
//  Menu
//
//  Created by Mathew Sanders on 9/7/14.
//  Copyright (c) 2014 Mat. All rights reserved.
//

import UIKit

class MenuTransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    fileprivate var presenting = false
    fileprivate var interactive = false

    fileprivate var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    fileprivate var statusBarBackground: UIView!
    
    var sourceViewController: UIViewController! {
        didSet {
            self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action:#selector(MenuTransitionManager.handleOnstagePan(_:)))
            self.enterPanGesture.edges = UIRectEdge.left
            self.sourceViewController.view.addGestureRecognizer(self.enterPanGesture)
            
            // create view to go behind statusbar
            self.statusBarBackground = UIView()
            self.statusBarBackground.frame = CGRect(x: 0, y: 0, width: self.sourceViewController.view.frame.width, height: 20)
            self.statusBarBackground.backgroundColor = self.sourceViewController.view.backgroundColor
            
            // add to window rather than view controller
            UIApplication.shared.keyWindow?.addSubview(self.statusBarBackground)
        }
    }
    
    fileprivate var exitPanGesture: UIPanGestureRecognizer!
    
    var menuViewController: UIViewController! {
        didSet {
            self.exitPanGesture = UIPanGestureRecognizer()
            self.exitPanGesture.addTarget(self, action:#selector(MenuTransitionManager.handleOffstagePan(_:)))
            self.menuViewController.view.addGestureRecognizer(self.exitPanGesture)
        }
    }
    
    func handleOnstagePan(_ pan: UIPanGestureRecognizer){
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translation(in: pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / pan.view!.bounds.width * 0.5
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.began:
            // set our interactive flag to true
            self.interactive = true
            
            // trigger the start of the transition
            self.sourceViewController.performSegue(withIdentifier: "presentMenu", sender: self)
            break
            
        case UIGestureRecognizerState.changed:
            
            // update progress of the transition
            self.update(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            if(d > 0.2){
                // threshold crossed: finish
                self.finish()
            }
            else {
                // threshold not met: cancel
                self.cancel()
            }
        }
    }
    
    // pretty much the same as 'handleOnstagePan' except 
    // we're panning from right to left
    // perfoming our exitSegeue to start the transition
    func handleOffstagePan(_ pan: UIPanGestureRecognizer){
        
        let translation = pan.translation(in: pan.view!)
        let d =  translation.x / pan.view!.bounds.width * -0.5
        
        switch (pan.state) {
            
        case UIGestureRecognizerState.began:
            self.interactive = true
            self.menuViewController.performSegue(withIdentifier: "dismissMenu", sender: self)
            break
            
        case UIGestureRecognizerState.changed:
            self.update(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            self.interactive = false
            if(d > 0.1){
                self.finish()
            }
            else {
                self.cancel()
            }
        }
    }
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        
        // create a tuple of our screens
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!, transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        let menuViewController = !self.presenting ? screens.from as! MenuViewController : screens.to as! MenuViewController
        let topViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
        
        let menuView = menuViewController.view
        let topView = topViewController.view
        
        // prepare menu items to slide in
        if (self.presenting){
            self.offStageMenuControllerInteractive(menuViewController) // offstage for interactive
        }
        
        // add the both views to our view controller
        
        container.addSubview(menuView!)
        container.addSubview(topView!)
        container.addSubview(self.statusBarBackground)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        // perform the animation!
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            
                if (self.presenting){
                    self.onStageMenuController(menuViewController) // onstage items: slide in
                    topView?.transform = self.offStage(290)
                }
                else {
                    topView?.transform = CGAffineTransform.identity
                    self.offStageMenuControllerInteractive(menuViewController)
                }

            }, completion: { finished in
                
                // tell our transitionContext object that we've finished animating
                if(transitionContext.transitionWasCancelled){
                    
                    transitionContext.completeTransition(false)
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.shared.keyWindow?.addSubview(screens.from.view)
                    
                }
                else {
                    
                    transitionContext.completeTransition(true)
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.shared.keyWindow?.addSubview(screens.to.view)
                    
                }
                UIApplication.shared.keyWindow?.addSubview(self.statusBarBackground)
                
        })
        
    }
    
    func offStage(_ amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(translationX: amount, y: 0)
    }
    
    func offStageMenuControllerInteractive(_ menuViewController: MenuViewController){
        
        menuViewController.view.alpha = 0
        self.statusBarBackground.backgroundColor = self.sourceViewController.view.backgroundColor
        
        // setup paramaters for 2D transitions for animations
        let offstageOffset  :CGFloat = -200
        
        menuViewController.textPostIcon.transform = self.offStage(offstageOffset)
        menuViewController.textPostLabel.transform = self.offStage(offstageOffset)
        
        menuViewController.quotePostIcon.transform = self.offStage(offstageOffset)
        menuViewController.quotePostLabel.transform = self.offStage(offstageOffset)
        
        menuViewController.chatPostIcon.transform = self.offStage(offstageOffset)
        menuViewController.chatPostLabel.transform = self.offStage(offstageOffset)
        
        menuViewController.photoPostIcon.transform = self.offStage(offstageOffset)
        menuViewController.photoPostLabel.transform = self.offStage(offstageOffset)
        
        menuViewController.linkPostIcon.transform = self.offStage(offstageOffset)
        menuViewController.linkPostLabel.transform = self.offStage(offstageOffset)
        
        menuViewController.audioPostIcon.transform = self.offStage(offstageOffset)
        menuViewController.audioPostLabel.transform = self.offStage(offstageOffset)
        
    }
    
    func onStageMenuController(_ menuViewController: MenuViewController){
        
        // prepare menu to fade in
        menuViewController.view.alpha = 1
        self.statusBarBackground.backgroundColor = UIColor.black
        
        menuViewController.textPostIcon.transform = CGAffineTransform.identity
        menuViewController.textPostLabel.transform = CGAffineTransform.identity
        
        menuViewController.quotePostIcon.transform = CGAffineTransform.identity
        menuViewController.quotePostLabel.transform = CGAffineTransform.identity
        
        menuViewController.chatPostIcon.transform = CGAffineTransform.identity
        menuViewController.chatPostLabel.transform = CGAffineTransform.identity
        
        menuViewController.photoPostIcon.transform = CGAffineTransform.identity
        menuViewController.photoPostLabel.transform = CGAffineTransform.identity
        
        menuViewController.linkPostIcon.transform = CGAffineTransform.identity
        menuViewController.linkPostLabel.transform = CGAffineTransform.identity
        
        menuViewController.audioPostIcon.transform = CGAffineTransform.identity
        menuViewController.audioPostLabel.transform = CGAffineTransform.identity
        
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // rememeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
}
