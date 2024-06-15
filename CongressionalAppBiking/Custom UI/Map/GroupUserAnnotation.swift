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
    var name: String?
    
    var initials: String {
        let split = name?.uppercased().split(separator: " ") ?? [""]
        var out = ""
        for s in split {
            out += String(s.first ?? Character(""))
        }
        return out
    }
    
    var status: GroupUserStatus!
}

class GroupUserAnnotationView: MKAnnotationView {
    var inSelectedState: Bool = false
    
    public lazy var containerView: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: -30, width: 40, height: 40))
        
//        if (annotation as! GroupUserAnnotation).status! == .moving {
            view.backgroundColor = .accentColor
//        } else {
//            view.backgroundColor = .red
//        }
        view.layer.cornerRadius = view.frame.width / 2
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    public lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = (annotation as! GroupUserAnnotation).initials
        label.font = UIFont(name: "Montserrat-Medium", size: 18)
        label.clipsToBounds = true
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = (annotation as! GroupUserAnnotation).image
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
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
        
        addSubview(containerView)
        if inSelectedState == true {
            containerView.addSubview(imageView)
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2.0).isActive = true
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2.0).isActive = true
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0).isActive = true
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2.0).isActive = true
            imageView.layer.cornerRadius = (containerView.frame.size.width - 1) / 2
        } else {
            containerView.addSubview(label)
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2.0).isActive = true
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2.0).isActive = true
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2.0).isActive = true
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2.0).isActive = true
            label.layer.cornerRadius = (containerView.frame.size.width - 1) / 2
        }

        
        
        
    }
    
    @objc func selectedSelf(_ sender: UITapGestureRecognizer) {
        print("bam")
    }
    
    public func makeAnnotationSelected() {
        layer.zPosition = 100
        self.label.isHidden = true
        self.imageView.isHidden = false
        
        self.imageView.frame = CGRect(x: 5, y: -20, width: 10, height: 10)
        UIView.animate(withDuration: 0.2) { [self] in
            self.containerView.frame = CGRect(x: -10, y: -50, width: 90, height: 90)
            self.containerView.backgroundColor = .selectedBlueColor
            self.containerView.isUserInteractionEnabled = true
            self.containerView.layer.cornerRadius = 45
            
            self.imageView.frame = CGRect(x: -6, y: -46, width: 82, height: 82)
            self.imageView.layer.cornerRadius = 41
        }
        
        self.inSelectedState = true
        setupView()
        
    }
    
    public func makeAnnotationDeselected () {
        layer.zPosition = 0
        self.label.isHidden = false
        self.imageView.isHidden = true
        self.label.frame = CGRect(x: 25 , y: -20, width: self.label.frame.width, height: self.label.frame.height)
        UIView.animate(withDuration: 0.2) {
            self.containerView.frame = CGRect(x: 0, y: -30, width: 40, height: 40)
            self.containerView.backgroundColor = .accentColor
            self.containerView.isUserInteractionEnabled = true
            self.containerView.layer.cornerRadius = 20
            
            self.imageView.frame = CGRect(x: 5, y: -20, width: 10, height: 10)
            self.label.layer.cornerRadius = 18
        }
        self.inSelectedState = false
        setupView()
    }
}
