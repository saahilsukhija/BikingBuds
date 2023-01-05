////
////  RWGPSPointAnnotation.swift
////  CongressionalAppBiking
////
////  Created by Saahil Sukhija on 12/26/22.
////
//
//import UIKit
//import MapKit
//class RWGPSPointAnnotation: MKPointAnnotation {
//    var color: UIColor!
//}
//
//class RWGPSPointAnnotationView: MKAnnotationView {
//
//    public lazy var containerView: UIButton = {
//        let view = UIButton(frame: CGRect(x: 0, y: -20, width: 20, height: 20))
//        view.backgroundColor = .orange
//        view.layer.cornerRadius = view.frame.width / 2
//        return view
//    }()
//
//    // MARK: Initialization
//    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
//        super.init(annotation: annotation as! RWGPSPointAnnotation, reuseIdentifier: reuseIdentifier)
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    public func setupView() {
//        subviews.forEach({ $0.removeFromSuperview() })
//        addSubview(containerView)
//
//    }
//}
//
