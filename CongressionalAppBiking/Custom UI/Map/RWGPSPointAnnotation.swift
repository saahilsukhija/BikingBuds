//
//  RWGPSPointAnnotation.swift
//  CongressionalAppBiking
//
//  Created by Saahil Sukhija on 12/26/22.
//

import UIKit
import MapKit
class RWGPSDistanceMarkerAnnotation: MKPointAnnotation {
    var color: UIColor!
    var distance: Double!
}

class RWGPSDistanceMarkerAnnotationView: MKAnnotationView {

    public lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: -20, width: 30, height: 30))
        //view.backgroundColor = .blue
        view.layer.cornerRadius = view.frame.width / 2
        return view
    }()

    public lazy var mileView: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.backgroundColor = .clear
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-SemiBold", size: 14)
        label.text = "\(Int((annotation as? RWGPSDistanceMarkerAnnotation)?.distance ?? 0))"
        return label
    }()
    
    // MARK: Initialization
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation as! RWGPSDistanceMarkerAnnotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupView() {
        subviews.forEach({ $0.removeFromSuperview() })
        containerView.addSubview(mileView)
        addSubview(containerView)

    }
}

