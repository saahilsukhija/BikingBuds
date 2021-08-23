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
    private lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: -40, y: -70, width: 70, height: 70))
        view.backgroundColor = .accentColor
        view.layer.cornerRadius = view.frame.width / 2
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = (annotation as! GroupUserAnnotation).image!
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var bottomCornerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .accentColor
        view.layer.cornerRadius = 4.0
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
    
    private func setupView() {
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
}
