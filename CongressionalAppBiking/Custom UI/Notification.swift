//
//  Notification.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 10/9/21.
//

import UIKit
import Lottie

extension UIViewController {
    func showNotification(message: String, duration: Double = 3, image: UIImage = UIImage(systemName: "cart")!, color: UIColor = .label, fontColor: UIColor = .label) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        let notificationView = UIView(frame: CGRect(x: 10, y: -50, width: window.frame.size.width - 20, height: 125))
        notificationView.addLeftBorder(with: color, andWidth: 1)
        notificationView.addBottomBorder(with: color, andWidth: 1)
        notificationView.addRightBorder(with: color, andWidth: 1)
        
        let shoppingCartImage = UIImageView(frame: CGRect(x: 10, y: 10, width: notificationView.frame.size.height - 20, height: notificationView.frame.size.height - 20))
        
        shoppingCartImage.image = image
        shoppingCartImage.tintColor = color
        notificationView.addSubview(shoppingCartImage)
        
        let messageLabel = UILabel(frame: CGRect(x: notificationView.frame.size.height, y: 0, width: notificationView.frame.size.width - notificationView.frame.size.height, height: notificationView.frame.size.height))
        messageLabel.textAlignment = .left
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Poppins-Regular", size: 20)
        messageLabel.textColor = fontColor
        messageLabel.numberOfLines = 0
        notificationView.addSubview(messageLabel)
        window.addSubview(notificationView)
        
        notificationView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            notificationView.frame.origin.y = 50
        })
        
        UIView.animate(withDuration: 0.2, delay: duration, animations: {
            notificationView.center.y = -50
        }, completion: {_ in
            notificationView.removeFromSuperview()
        })
    }
    
    func showAnimationNotification(animationName: String, message: String, duration: Double = 3, color: UIColor = .label, fontColor: UIColor = .label, playbackSpeed: CGFloat = 1, loop: LottieLoopMode = .playOnce, fontsize: Double = 20) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        let notificationView = UIView(frame: CGRect(x: 10, y: -50, width: window.frame.size.width - 20, height: 100))
        notificationView.addLeftBorder(with: color, andWidth: 1)
        notificationView.addBottomBorder(with: color, andWidth: 1)
        notificationView.addRightBorder(with: color, andWidth: 1)
        
        notificationView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        
        let animationView = AnimationView(name: animationName)
        animationView.frame = CGRect(x: 5, y: 10, width: notificationView.frame.size.height - 20, height: notificationView.frame.size.height - 20)
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = playbackSpeed
        animationView.loopMode = loop
        notificationView.addSubview(animationView)
        
        let messageLabel = UILabel(frame: CGRect(x: notificationView.frame.size.height, y: 0, width: notificationView.frame.size.width - notificationView.frame.size.height, height: notificationView.frame.size.height))
        messageLabel.textAlignment = .left
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Poppins-Regular", size: fontsize)
        messageLabel.textColor = fontColor
        messageLabel.numberOfLines = 0
        notificationView.addSubview(messageLabel)
        window.addSubview(notificationView)
        
        
        notificationView.isUserInteractionEnabled = true
        //Let Swipe Down Dismiss. Does not work
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissNotification(_:)))
        swipeDownGesture.direction = .up
        notificationView.addGestureRecognizer(swipeDownGesture)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: {
                notificationView.frame.origin.y = 50
            }, completion: {_ in
                animationView.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.2) {
                    UIView.animate(withDuration: 0.2, delay: 0, animations: {
                        notificationView.center.y = -50
                    }, completion: {_ in
                        notificationView.removeFromSuperview()
                    })
                }

            })
    }
    
    func showAnnouncementNotification(announcement: AnnouncementNotification, duration: Double = 8, color: UIColor = .systemBlue, fontColor: UIColor = .systemBlue, playbackSpeed: CGFloat = 1, loop: LottieLoopMode = .playOnce) {
        guard let userName = (Locations.groupUsers.groupUserFrom(email: announcement.email))?.displayName else { return }
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        let notificationView = UIView(frame: CGRect(x: 10, y: -50, width: window.frame.size.width - 20, height: 100))
        notificationView.addLeftBorder(with: color, andWidth: 1)
        notificationView.addBottomBorder(with: color, andWidth: 1)
        notificationView.addRightBorder(with: color, andWidth: 1)
        
        notificationView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        let animationView = AnimationView(name: "Megaphone")
        animationView.frame = CGRect(x: 5, y: 10, width: notificationView.frame.size.height - 20, height: notificationView.frame.size.height - 20)
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = playbackSpeed
        animationView.loopMode = loop
        notificationView.addSubview(animationView)
        
        let userLabel = UILabel(frame: CGRect(x: notificationView.frame.size.height, y: 15, width: notificationView.frame.size.width - notificationView.frame.size.height, height: notificationView.frame.size.height / 3))
        userLabel.textAlignment = .left
        userLabel.text = userName + " says:"
        userLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        userLabel.textColor = fontColor
        userLabel.numberOfLines = 0
        notificationView.addSubview(userLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: notificationView.frame.size.height, y:  notificationView.frame.size.height / 3 + 8, width: notificationView.frame.size.width - notificationView.frame.size.height, height: 36))
        messageLabel.textAlignment = .left
        messageLabel.text = "\"\(announcement.title ?? "(error getting message)")\""
        messageLabel.font = UIFont(name: "Poppins-Regular", size: 18)
        messageLabel.textColor = fontColor
        messageLabel.numberOfLines = 0
        notificationView.addSubview(messageLabel)
        
        let timeLabel = UILabel(frame: CGRect(x: notificationView.frame.size.width - 60, y: 0, width: 50, height: 36))
        timeLabel.textAlignment = .right
        timeLabel.text = "Now"
        timeLabel.font = UIFont(name: "Poppins-Regular", size: 16)
        timeLabel.textColor = .systemGray
        timeLabel.numberOfLines = 0
        notificationView.addSubview(timeLabel)
        
        window.addSubview(notificationView)
        
        
        notificationView.isUserInteractionEnabled = true
        //Let Swipe Down Dismiss. Does not work
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissNotification(_:)))
        swipeDownGesture.direction = .up
        notificationView.addGestureRecognizer(swipeDownGesture)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: {
                notificationView.frame.origin.y = 50
            }, completion: {_ in
                animationView.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.2) {
                    UIView.animate(withDuration: 0.2, delay: 0, animations: {
                        notificationView.center.y = -50
                    }, completion: {_ in
                        notificationView.removeFromSuperview()
                    })
                }

            })
    }
    
    @objc func dismissNotification(_ sender: UIGestureRecognizer) {
        print("dismiss notification")
        let notificationView = sender.view
        
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            notificationView?.center.y = -50
        }, completion: {_ in
            notificationView?.removeFromSuperview()
        })
        
    }
    func showErrorNotification(message: String, duration: Double = 3) {
        showAnimationNotification(animationName: "CrossX", message: message, duration: duration, color: .red, fontColor: .red)
    }
    
    func showSuccessNotification(message: String, duration: Double = 3) {
        showAnimationNotification(animationName: "CheckMark", message: message, duration: duration, color: .systemGreen, fontColor: .systemGreen)
    }
}

//MARK: -Single Border
extension UIView {
    
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }

    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }

    func addLeftBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }

    func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        addSubview(border)
    }
}

