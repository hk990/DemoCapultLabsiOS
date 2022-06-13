//
//  CustomNotificationButton.swift
//  BlufVPN
//
//  Created by Hassan Khan on 4/12/21.
//

import UIKit

class CustomNotificationButton: UIView {
    
    private let parentView: UIView = {
        let parentView = UIView()
        parentView.translatesAutoresizingMaskIntoConstraints = false
        return parentView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "notificationBell")!)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dotView: UIView = {
        let dotView = UIView()
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = CustomColor.shared.green
        return dotView
    }()
    
    private let overButton: UIButton = {
        let overButton = UIButton()
        overButton.translatesAutoresizingMaskIntoConstraints = false
        return overButton
    }()
    
    convenience init(withSelector selector: Selector) {
        self.init()
        overButton.addTarget(nil, action: selector, for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addViews()
        setupLayouts()
    }

    private func addViews() {
        addSubview(parentView)
        parentView.addSubview(imageView)
        parentView.addSubview(dotView)
        parentView.addSubview(overButton)
    }
    
    private func setupLayouts() {
        parentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        parentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        parentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        parentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.55).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
        
        dotView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        dotView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        dotView.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.40).isActive = true
        dotView.widthAnchor.constraint(equalTo: dotView.heightAnchor, multiplier: 1).isActive = true
        
        
        dotView.layer.masksToBounds = true
        dotView.layer.cornerRadius = (imageView.frame.size.height * 0.40)/2
        
        overButton.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        overButton.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
        overButton.heightAnchor.constraint(equalTo: parentView.heightAnchor).isActive = true
        overButton.widthAnchor.constraint(equalTo: parentView.widthAnchor).isActive = true
        
    }
}
