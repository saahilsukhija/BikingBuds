//
//  GroupUserAnnotation.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 8/13/21.
//

import UIKit
import MapKit

class GroupUserAnnotation: MKPointAnnotation {
    var email: String!
    var image: UIImage!
}

class GroupUserAnnotationView: MKAnnotationView {
    var inSelectedState: Bool = false
    public lazy var containerView: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: -30, width: 70, height: 70))
        view.backgroundColor = .accentColor
        view.layer.cornerRadius = view.frame.width / 2
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = (annotation as! GroupUserAnnotation).image!
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    public lazy var bottomCornerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .accentColor
        view.layer.cornerRadius = 4.0
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // MARK: Initialization
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation as! GroupUserAnnotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupView() {
        subviews.forEach({ $0.removeFromSuperview() })
        
        containerView.addSubview(bottomCornerView)
        bottomCornerView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20.0).isActive = true
        bottomCornerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 2).isActive = true
        bottomCornerView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        bottomCornerView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let angle = (39.0 * CGFloat.pi) / 180
        let transform = CGAffineTransform(rotationAngle: angle)
        bottomCornerView.transform = transform
        
        addSubview(containerView)
        containerView.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2.0).isActive = true
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2.0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2.0).isActive = true
        
        imageView.layer.cornerRadius = (containerView.frame.size.width - 1) / 2
        
    }
    
    @objc func selectedSelf(_ sender: UITapGestureRecognizer) {
        print("bam")
    }
    
    public func makeAnnotationSelected() {
        layer.zPosition = 100
        UIView.animate(withDuration: 0.2) {
            self.containerView = {
                let view = UIButton(frame: CGRect(x: -10, y: -50, width: 90, height: 90))
                view.backgroundColor = .selectedBlueColor
                view.layer.cornerRadius = view.frame.width / 2
                view.isUserInteractionEnabled = true
                
                return view
            }()
            
            self.bottomCornerView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .selectedBlueColor
                view.layer.cornerRadius = 4.0
                return view
            }()
        }
        
        self.inSelectedState = true
        setupView()
        
    }
    
    public func makeAnnotationDeselected () {
        layer.zPosition = 0
        UIView.animate(withDuration: 0.3) {
            
            self.containerView = {
                let view = UIButton(frame: CGRect(x: 0, y: -30, width: 70, height: 70))
                view.backgroundColor = .accentColor
                view.layer.cornerRadius = view.frame.width / 2
                view.isUserInteractionEnabled = true
                
                return view
            }()
            
            self.bottomCornerView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .accentColor
                view.layer.cornerRadius = 4.0
                return view
            }()
        }
        self.inSelectedState = false
        setupView()
    }
}
