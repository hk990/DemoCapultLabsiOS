//
//  TextField.swift
//  BlufVPN
//
//  Created by Hassan Khan on 4/5/21.
//

import UIKit
import IQKeyboardManagerSwift

class TextField: UIView {
    
    var isPassword: Bool = false
    var isCode: Bool = false
    var shouldShow = true
    var corner = 15
    var leading = 18
    
    private var borderLayerForSecondaryFields = CAShapeLayer()
    
    private let parentView: UIView = {
        let parentView = UIView()
        parentView.translatesAutoresizingMaskIntoConstraints = false
        parentView.backgroundColor = CustomColor.shared.white
        return parentView
    }()
    

    private let passwordShowButton: UIButton = {
        let passwordShowButton = UIButton()
        passwordShowButton.translatesAutoresizingMaskIntoConstraints = false
        passwordShowButton.setTitle("Show", for: .normal)
        passwordShowButton.setTitleColor(.lightGray, for: .normal)
        passwordShowButton.titleLabel?.font = CustomFont.shared.customRegular(14, adjustFont: false)
        return passwordShowButton
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.font = CustomFont.shared.customRegular(16)
        textField.textColor = CustomColor.shared.lightGrey
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    convenience init(placeholder text: String) {
        self.init()
        textField.attributedPlaceholder = NSAttributedString(string: text,
                                                             attributes: [NSAttributedString.Key.foregroundColor: CustomColor.shared.lightGrey])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addViews()
        setupLayouts()
        passwordShowButton.addTarget(self, action: #selector(actionShow(_:)), for: .touchUpInside)
    }
    
    @objc private func actionShow(_ sender: UIButton) {
        if shouldShow {
            textField.isSecureTextEntry = false
            passwordShowButton.setTitle("Hide", for: .normal)
            shouldShow = false
        } else {
            textField.isSecureTextEntry = true
            passwordShowButton.setTitle("Show", for: .normal)
            shouldShow = true
        }
    }
    
    private func addViews() {
        addSubview(parentView)
        
        if isPassword {
            parentView.addSubview(passwordShowButton)
        }
        parentView.addSubview(self.textField)
        textField.delegate = self
        
        
    }
    
    private func setupLayouts() {
        
        parentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        parentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        parentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        textField.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: CGFloat(leading)).isActive = true
        if isPassword {
            parentView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            textField.trailingAnchor.constraint(equalTo: passwordShowButton.leadingAnchor, constant: -8).isActive = true
            
            passwordShowButton.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -18).isActive = true
            passwordShowButton.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
            passwordShowButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
            passwordShowButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
        } else if isCode {
            parentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            textField.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0).isActive = true
        } else {
            parentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            textField.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0).isActive = true
        }
        
        
        if isPassword && isCode {
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
            self.layer.mask = maskLayer
//
//            // Add border
            let borderLayer = CAShapeLayer()
            borderLayer.path = maskLayer.path // Reuse the Bezier path
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = UIColor.lightGray.cgColor
            borderLayer.lineWidth = 2
            borderLayer.frame = self.bounds
            self.layer.addSublayer(borderLayer)
            self.borderLayerForSecondaryFields = borderLayer
            
            let viewThatHideTopLine = UIView(frame: CGRect(x: 1, y: -1, width: self.bounds.size.width - 2, height: 5))
            viewThatHideTopLine.backgroundColor = CustomColor.shared.white
            self.addSubview(viewThatHideTopLine)
            
            
        } else {
            self.layer.cornerRadius = CGFloat(corner)
            self.layer.masksToBounds = true
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func beginEdit() {
        self.textField.textColor = CustomColor.shared.darkBlue
        borderLayerForSecondaryFields.strokeColor = UIColor.black.cgColor
        self.layer.borderColor = UIColor.black.cgColor
        passwordShowButton.setTitleColor(.black, for: .normal)
    }
    
    func endEdit() {
        self.textField.textColor = CustomColor.shared.lightGrey
        self.layer.borderColor = UIColor.lightGray.cgColor
        borderLayerForSecondaryFields.strokeColor = UIColor.lightGray.cgColor
        passwordShowButton.setTitleColor(.lightGray, for: .normal)
    }
}
extension TextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let manager = IQKeyboardManager.shared
        if manager.canGoNext {
            manager.goNext()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField.textColor = CustomColor.shared.darkBlue
        borderLayerForSecondaryFields.strokeColor = UIColor.black.cgColor
        self.layer.borderColor = UIColor.black.cgColor
        passwordShowButton.setTitleColor(.black, for: .normal)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textField.textColor = CustomColor.shared.lightGrey
        self.layer.borderColor = UIColor.lightGray.cgColor
        borderLayerForSecondaryFields.strokeColor = UIColor.lightGray.cgColor
        passwordShowButton.setTitleColor(.lightGray, for: .normal)
    }
}
