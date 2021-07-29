//
//  Toast.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 6/8/21.
//

import UIKit
import Lottie
extension UIViewController {
    func showToast(message: String, duration: Double = 2, image: UIImage = UIImage(systemName: "cart")!, color: UIColor = .label, fontColor: UIColor = .label) {
        view.endEditing(true)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        let toastView = UIView(frame: CGRect(x: 10, y: view.frame.size.height - view.safeAreaInsets.bottom, width: view.frame.size.width - 20, height: 50))
        toastView.layer.borderWidth = 2
        toastView.layer.borderColor = color.cgColor
        toastView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        
        let shoppingCartImage = UIImageView(frame: CGRect(x: 10, y: 10, width: toastView.frame.size.height - 20, height: toastView.frame.size.height - 20))
        
        shoppingCartImage.image = image
        shoppingCartImage.tintColor = color
        toastView.addSubview(shoppingCartImage)
        
        let messageLabel = UILabel(frame: CGRect(x: toastView.frame.size.height, y: 5, width: toastView.frame.size.width - toastView.frame.size.height, height: 40))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "DIN Alternate Bold", size: 20)
        messageLabel.textColor = fontColor
        toastView.addSubview(messageLabel)
        window.addSubview(toastView)
        
        toastView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            toastView.frame.origin.y = self.view.frame.size.height - self.view.safeAreaInsets.bottom - 70
        })
        
        UIView.animate(withDuration: 0.2, delay: duration, animations: {
            toastView.center.y = self.view.frame.size.height + 50
        }, completion: {_ in
            toastView.removeFromSuperview()
        })
    }
    
    
    ///Shows a green toast
    func showSuccessToast(message: String) {
        showAnimationToast(animationName: "CheckMark", message: message, color: .systemGreen, fontColor: .systemGreen)
    }
    
    ///Shows a red toast
    func showFailureToast(message: String) {
        showAnimationToast(animationName: "CrossX", message: message, color: .red, fontColor: .red)
    }
    
    func showNotAnimatedSuccessToast(message: String) {
        showToast(message: message, image: UIImage(systemName: "checkmark")!, color: .systemGreen, fontColor: .systemGreen)
    }
    
    func showNotAnimatedFailureToast(message: String) {
        showToast(message: message, image: UIImage(systemName: "multiply")!, color: .red, fontColor: .red)
    }
    
    func showAnimationToast(animationName: String, message: String, duration: Double = 3, color: UIColor = .label, fontColor: UIColor = .label) {
        view.endEditing(true)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        let toastView = UIView(frame: CGRect(x: 10, y: view.frame.size.height - view.safeAreaInsets.bottom, width: view.frame.size.width - 20, height: 60))
        toastView.layer.borderWidth = 2
        toastView.layer.borderColor = color.cgColor
        toastView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        
        toastView.tag = 1474
        
        let animationView = AnimationView(name: animationName)
        animationView.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
        animationView.contentMode = .scaleAspectFill
        toastView.addSubview(animationView)
        
        let messageLabel = UILabel(frame: CGRect(x: toastView.frame.size.height, y: 5, width: toastView.frame.size.width - toastView.frame.size.height, height: 50))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "DIN Alternate Bold", size: 22)
        messageLabel.textColor = fontColor
        toastView.addSubview(messageLabel)
        window.addSubview(toastView)
        
        toastView.isUserInteractionEnabled = true
        
        //Let Swipe Down Dismiss. Does not work
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissToast(_:)))
        swipeDownGesture.direction = .down
        toastView.addGestureRecognizer(swipeDownGesture)
        
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            toastView.frame.origin.y = self.view.frame.size.height - self.view.safeAreaInsets.bottom - 70
        }, completion: {_ in
            animationView.play()
        })
        
        UIView.animate(withDuration: 0.2, delay: duration, animations: {
            toastView.center.y = self.view.frame.size.height + 50
        }, completion: {_ in
            toastView.removeFromSuperview()
        })
    }
    
    @objc func dismissToast(_ sender: UIGestureRecognizer) {
        print("dismiss")
        let toastView = view.subviews.filter { view in
            if view.tag == 1474 {
                return true
            }
            return false
        }.last!
        
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            toastView.center.y = self.view.frame.size.height + 50
        }, completion: {_ in
            toastView.removeFromSuperview()
        })
        
    }
}
