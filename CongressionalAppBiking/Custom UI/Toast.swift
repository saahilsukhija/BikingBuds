//
//  Toast.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 6/8/21.
//

import UIKit
import Lottie

extension UIViewController {
    func showToast(message: String, duration: Double = 2, image: UIImage = UIImage(systemName: "bicycle")!, color: UIColor = .label, fontColor: UIColor = .label) {
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
        messageLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20)
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
        showAnimationToast(animationName: "CheckMark", message: message, color: .successGreen, fontColor: .successGreen, speed: 1.5)
    }
    
    ///Shows a red toast
    func showFailureToast(message: String) {
        showAnimationToast(animationName: "CrossX", message: message, color: .failureRed, fontColor: .failureRed)
    }
    
    func showNotAnimatedSuccessToast(message: String) {
        showToast(message: message, image: UIImage(systemName: "checkmark")!, color: .successGreen, fontColor: .successGreen)
    }
    
    func showNotAnimatedFailureToast(message: String) {
        showToast(message: message, image: UIImage(systemName: "multiply")!, color: .failureRed, fontColor: .failureRed)
    }
    
    func showAnimationToast(animationName: String, message: String, duration: Double = 3, color: UIColor = .label, fontColor: UIColor = .label, speed: Double = 1) {
        view.endEditing(true)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        let toastView = UIView(frame: CGRect(x: 10, y: view.frame.size.height - view.safeAreaInsets.bottom, width: view.frame.size.width - 20, height: 60))
        toastView.layer.borderWidth = 2
        toastView.layer.borderColor = color.cgColor
        toastView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        
        let animationView = LottieAnimationView(name: animationName)
        if animationName != "CrossX" {
            animationView.frame = CGRect(x: 8, y: 8, width: 44, height: 44)
        } else {
            animationView.frame = CGRect(x: 14, y: 14, width: 32, height: 32)
        }
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = speed
        toastView.addSubview(animationView)
        
        let messageLabel = UILabel(frame: CGRect(x: toastView.frame.size.height, y: 5, width: toastView.frame.size.width - toastView.frame.size.height, height: 50))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Montserrat-SemiBold", size: 22)
        messageLabel.textColor = fontColor
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.2
        messageLabel.numberOfLines = 0
        toastView.addSubview(messageLabel)
        window.addSubview(toastView)
        
        toastView.isUserInteractionEnabled = true
        
        //Let Swipe Down Dismiss. Does not work
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissToast(_:)))
        swipeDownGesture.direction = .down
        toastView.addGestureRecognizer(swipeDownGesture)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: {
                toastView.frame.origin.y = self.view.frame.size.height - self.view.safeAreaInsets.bottom - 70
            }, completion: {_ in
                animationView.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.2) {
                    UIView.animate(withDuration: 0.2, delay: 0, animations: {
                        toastView.center.y = self.view.frame.size.height + 50
                    }, completion: {_ in
                        toastView.removeFromSuperview()
                    })
                }

            })
    }
    
    @objc func dismissToast(_ sender: UIGestureRecognizer) {
        print("dismiss toast")
        let toastView = sender.view
        
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            toastView?.center.y = self.view.frame.size.height + 50
        }, completion: {_ in
            toastView?.removeFromSuperview()
        })
        
    }
}
