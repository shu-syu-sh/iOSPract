//
//  MainViewController.swift
//  Pract
//
//  Created by 小林涼 on 2016/04/18.
//  Copyright © 2016年 ShuSyuSh. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doButton(sender: AnyObject) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("popup")
        vc.preferredContentSize = CGSizeMake(200, 500)
        vc.modalPresentationStyle = .Popover
        if let pres = vc.popoverPresentationController {
            pres.delegate = self // must be before presentViewController.
        }
        presentViewController(vc, animated: true, completion: nil)
        if let pop = vc.popoverPresentationController {
            let v = sender as! UIView
            pop.sourceView = v
            pop.sourceRect = v.bounds
            // A popover sometimes doesn't conform correctly to the base default case.
            // In particular, if a popover is summoned by the user tapping a UIBarButton
            // item in a toolbar, other UIBarButton item in that toolbar are passthrough views!
            // Rather hacky solution is to provide some extra delay, 
            // so as to assert my will after the runtime
            delay(0.1) {
                pop.passthroughViews = nil
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController
        dest.preferredContentSize = CGSizeMake(200, 300)
        if let pop = dest.popoverPresentationController {
            pop.delegate = self
            delay(0.1) {
                pop.passthroughViews = nil
            }
        }
    }

}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        // The popover is being presented.
        // There is time to perform further initial configurations here.
        // (but this method is still called too early for you to work around
        // the passthroughViews issue).
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        // The user is dismissing the popover by tapping outside it.
        // Return false to prevent dismissal.
        // Not called when you dismiss the popover in code.
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        // The user has dismissed the popover by tapping outside it.
        // The popover is gone from the screen and dismissal is complete,
        // even though the popover presentation controller still exists.
        // Not called when you dismiss the popover in code.
    }
    
    func popoverPresentationController(popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverToRect rect: UnsafeMutablePointer<CGRect>, inView view: AutoreleasingUnsafeMutablePointer<UIView?>) {
        
    }
}

extension MainViewController: UIAdaptivePresentationControllerDelegate {

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // if you return .None instead of .FullScreen,
        // the presented view controller will be treated as a popover even on iPhone.
        return .None
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // to substitute a different view controller.
        // Tipically, this new view controller might be nothing but the old view
        // controller wrapped in UINavigationController! 
        // If this view controller has a navigationItem with a working Done button,
        // the problem is now solved: on iPhone, there's a navigation bar at the top of
        // the interface, and the Done button appears in it.
        // In order for this trick to work, you must do two additional things.
        // Implement the other delegate method,
        // adaptivePresentationStyleForPresentationController:- even if only to return the default,
        // .FullScreen.
        // Set the presetation controller's delegate before 
        // calling presentViewController:animated:completion:
        let vc = controller.presentedViewController
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
}
