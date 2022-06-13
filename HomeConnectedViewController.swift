//
//  HomeConnectedViewController.swift
//  Connect.io
//
//  Created by Hassan Khan on 11/18/21.
//

import UIKit
import NetworkExtension
import Alamofire
import SafariServices
import WebKit

class HomeConnectedViewController: UIViewController {
    
    var timer:Timer?
    var totalHour = Int()
    var totalMinut = Int()
    var totalSecond = Int()
    
    private let navBarView: CustomNavBar  = {
        let navBarView = CustomNavBar(logoWithRighButton: #selector(actionNotificationButton), upgradeNowAction: #selector(actionUpgradeNow))
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        return navBarView
    }()
    
    private let imageViewParent: UIView = {
        let imageViewParent = UIView()
        imageViewParent.translatesAutoresizingMaskIntoConstraints = false
        //imageViewParent.backgroundColor = .red
        return imageViewParent
    }()
    
    private let centerImageView: UIImageView = {
        let centerImageView = UIImageView()
        centerImageView.image = UIImage(named: "stop")!
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        return centerImageView
    }()
    
    private let buttonMenu: ButtonWithImageAndText = {
        let buttonHome = ButtonWithImageAndText(withImage: UIImage(named: "buttonMenu")!, text: "Menu", action: #selector(actionMenuButton), type: .menu)
        buttonHome.translatesAutoresizingMaskIntoConstraints = false
        return buttonHome
    }()
    
    private let buttonLocations: ButtonWithImageAndText = {
        let buttonLocations = ButtonWithImageAndText(withImage: UIImage(named: "browser")!, text: "Browser", action: #selector(actionLocationsButton), type: .locations)
        buttonLocations.translatesAutoresizingMaskIntoConstraints = false
        return buttonLocations
    }()
    
    private let buttonDisconnectCenter: ButtonWithImageAndText = {
        let buttonDisconnectCenter = ButtonWithImageAndText(withImage: UIImage(named: "disconnect")!, text: "Disconnect", action: #selector(actionDisconnect), type: .locations)
        buttonDisconnectCenter.translatesAutoresizingMaskIntoConstraints = false
        return buttonDisconnectCenter
    }()
    
    private let parentViewDetail: UIView = {
        let parentViewDetail = UIView()
        parentViewDetail.translatesAutoresizingMaskIntoConstraints = false
        return parentViewDetail
    }()
    
    private let buttonStop: UIButton = {
        let buttonTap = UIButton()
        buttonTap.backgroundColor = .clear
        buttonTap.translatesAutoresizingMaskIntoConstraints = false
        buttonTap.setTitle("", for: .normal)
        buttonTap.setTitleColor(.white, for: .normal)
        buttonTap.titleLabel?.font = CustomFont.shared.customBold(24)
        return buttonTap
    }()
    
    private let labelDurationHeading: UILabel = {
        let labelDurationHeading = UILabel()
        labelDurationHeading.textColor = .black
        labelDurationHeading.text = "Duration"
        labelDurationHeading.backgroundColor = .clear
        labelDurationHeading.font = CustomFont.shared.customRegular(16)
        labelDurationHeading.textAlignment = .center
        labelDurationHeading.translatesAutoresizingMaskIntoConstraints = false
        return labelDurationHeading
    }()
    
    private let labelDurationTime: UILabel = {
        let labelDurationTime = UILabel()
        labelDurationTime.textColor = .black
        labelDurationTime.text = "00:00:00"
        labelDurationTime.backgroundColor = .clear
        labelDurationTime.font = CustomFont.shared.customBold(24)
        labelDurationTime.textAlignment = .center
        labelDurationTime.translatesAutoresizingMaskIntoConstraints = false
        return labelDurationTime
    }()
    
    private let labelServerHeading: UILabel = {
        let labelServerHeading = UILabel()
        labelServerHeading.textColor = .black
        labelServerHeading.text = "VPN Server"
        labelServerHeading.backgroundColor = .clear
        labelServerHeading.font = CustomFont.shared.customRegular(16)
        labelServerHeading.textAlignment = .center
        labelServerHeading.translatesAutoresizingMaskIntoConstraints = false
        return labelServerHeading
    }()
    
    private let labelServerName: UILabel = {
        let labelServerName = UILabel()
        labelServerName.textColor = .black
        labelServerName.text = "Secured"
        labelServerName.backgroundColor = .clear
        labelServerName.font = CustomFont.shared.customBold(24)
        labelServerName.textAlignment = .center
        labelServerName.translatesAutoresizingMaskIntoConstraints = false
        return labelServerName
    }()
    
    private let serverImageView: UIImageView = {
        let serverImageView = UIImageView()
        serverImageView.image = UIImage(named: "pin")!
        serverImageView.contentMode = .scaleAspectFit
        serverImageView.translatesAutoresizingMaskIntoConstraints = false
        return serverImageView
    }()
    
    private let dotTopLeft: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dotBottomLeft: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dotBottomRight: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dotTopRight: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var providerManager = NETunnelProviderManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColor.shared.white
        addViews()
        setupLayouts()
        buttonStop.addTarget(self, action: #selector(actionTap), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil , queue: nil) {
           notification in
        }
        
        navBarView.buttonUpgradeNow.isHidden = true
        navBarView.rightButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    private func addViews() {
        view.addSubview(navBarView)
        view.addSubview(buttonMenu)
        view.addSubview(buttonLocations)
        view.addSubview(buttonDisconnectCenter)
        view.addSubview(parentViewDetail)
        parentViewDetail.addSubview(imageViewParent)
        parentViewDetail.addSubview(buttonStop)
        imageViewParent.addSubview(centerImageView)
        view.addSubview(labelDurationHeading)
        view.addSubview(labelDurationTime)
        view.addSubview(labelServerHeading)
        view.addSubview(labelServerName)
        view.addSubview(serverImageView)
        view.addSubview(dotTopLeft)
        view.addSubview(dotBottomLeft)
        view.addSubview(dotTopRight)
        view.addSubview(dotBottomRight)
        

    }
    
    private func loadManager() {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard error == nil else {
                // Handle an occurred error
                print(error!)
                return
            }

            self.providerManager = managers?.first ?? NETunnelProviderManager()
        }
    }
    
    private func setupLayouts() {
        navBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navBarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1231).isActive = true
        
        imageViewParent.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageViewParent.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageViewParent.heightAnchor.constraint(equalToConstant: 228).isActive = true
        imageViewParent.widthAnchor.constraint(equalToConstant: 228).isActive = true
        
        centerImageView.topAnchor.constraint(equalTo: imageViewParent.topAnchor).isActive = true
        centerImageView.leadingAnchor.constraint(equalTo: imageViewParent.leadingAnchor, constant: 8).isActive = true
        centerImageView.trailingAnchor.constraint(equalTo: imageViewParent.trailingAnchor, constant: -8).isActive = true
        centerImageView.bottomAnchor.constraint(equalTo: imageViewParent.bottomAnchor).isActive = true
        
        buttonStop.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonStop.heightAnchor.constraint(equalTo: imageViewParent.heightAnchor).isActive = true
        buttonStop.widthAnchor.constraint(equalTo: imageViewParent.widthAnchor).isActive = true
        buttonStop.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
        buttonMenu.trailingAnchor.constraint(equalTo: buttonStop.leadingAnchor, constant: 5).isActive = true
        buttonMenu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        buttonMenu.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonMenu.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        buttonLocations.leadingAnchor.constraint(equalTo: buttonStop.trailingAnchor, constant: -20).isActive = true
        buttonLocations.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        buttonLocations.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonLocations.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        buttonDisconnectCenter.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        buttonDisconnectCenter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        buttonDisconnectCenter.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonDisconnectCenter.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        parentViewDetail.topAnchor.constraint(equalTo: navBarView.bottomAnchor, constant: 30).isActive = true
        parentViewDetail.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        parentViewDetail.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        parentViewDetail.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.50).isActive = true
        parentViewDetail.bottomAnchor.constraint(lessThanOrEqualTo: buttonStop.topAnchor, constant: -10).isActive = true
        
        labelDurationHeading.topAnchor.constraint(equalTo: buttonStop.bottomAnchor, constant: 50).isActive = true
        labelDurationHeading.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        labelDurationHeading.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        labelDurationTime.topAnchor.constraint(equalTo: labelDurationHeading.bottomAnchor, constant: 10).isActive = true
        labelDurationTime.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        labelDurationTime.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        labelServerName.bottomAnchor.constraint(equalTo: buttonStop.topAnchor, constant: -50).isActive = true
        labelServerName.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        labelServerName.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        labelServerHeading.bottomAnchor.constraint(equalTo: labelServerName.topAnchor, constant: -10).isActive = true
        labelServerHeading.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        labelServerHeading.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        serverImageView.bottomAnchor.constraint(equalTo: labelServerHeading.topAnchor, constant: -10).isActive = true
        serverImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        serverImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        serverImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        dotTopLeft.topAnchor.constraint(equalTo: buttonStop.topAnchor, constant: 0).isActive = true
        dotTopLeft.leadingAnchor.constraint(equalTo: buttonStop.leadingAnchor, constant: 30).isActive = true
        dotTopLeft.widthAnchor.constraint(equalToConstant: 6).isActive = true
        dotTopLeft.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        dotBottomLeft.bottomAnchor.constraint(equalTo: buttonStop.bottomAnchor, constant: -15).isActive = true
        dotBottomLeft.leadingAnchor.constraint(equalTo: buttonStop.leadingAnchor, constant: 10).isActive = true
        dotBottomLeft.widthAnchor.constraint(equalToConstant: 4).isActive = true
        dotBottomLeft.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        
        dotTopRight.topAnchor.constraint(equalTo: buttonStop.topAnchor, constant: 15).isActive = true
        dotTopRight.trailingAnchor.constraint(equalTo: buttonStop.trailingAnchor, constant: -10).isActive = true
        dotTopRight.widthAnchor.constraint(equalToConstant: 4).isActive = true
        dotTopRight.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        dotBottomRight.bottomAnchor.constraint(equalTo: buttonStop.bottomAnchor, constant: 0).isActive = true
        dotBottomRight.trailingAnchor.constraint(equalTo: buttonStop.trailingAnchor, constant: -30).isActive = true
        dotBottomRight.widthAnchor.constraint(equalToConstant: 6).isActive = true
        dotBottomRight.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        
        dotTopLeft.layer.cornerRadius = 3.0
        dotTopLeft.layer.masksToBounds = true
        
        dotBottomLeft.layer.cornerRadius = 2.0
        dotBottomLeft.layer.masksToBounds = true
        
        dotTopRight.layer.cornerRadius = 2.0
        dotTopRight.layer.masksToBounds = true
        
        dotBottomRight.layer.cornerRadius = 3.0
        dotBottomRight.layer.masksToBounds = true
            
        
    }
    
    private func getAppLink() {
        startWaiting()
        let urlString = "https://connectio-api.vpnsystem.dev/users/me"//"https://dev-api.blufwl.com/users/login"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        let _: Parameters = [:]
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON {
                response in
                self.stopWaiting()
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value as? [String: AnyObject] {
                        if let link = data["browserPage"] as? String {
                            let dvc = WebViewController()
                            let navController = UINavigationController(rootViewController: dvc)
                            dvc.urlString = link
                            navController.modalPresentationStyle = .fullScreen
                            self.present(navController, animated: true, completion: nil)
                        }
                    }
                    break
                case .failure(_):
                    print(response.result.error!)
                    break
                }
        }
        
    }
    
    
    @objc private func actionDisconnect() {
        self.providerManager.loadFromPreferences(completionHandler: { (error) in
            if error == nil {
                self.providerManager.connection.stopVPNTunnel()
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    @objc private func actionMenuButton() {
        let dvc = MenuViewController()
        navigationController?.pushViewController(dvc, animated: true)
    }
    
    @objc private func actionLocationsButton() {
        getAppLink()
    }

    @objc private func actionTap() {
        getAppLink()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
    }

    @objc private func actionUpgradeNow() {
        
    }
    
    @objc private func actionNotificationButton() {
        
    }
    
}

extension HomeConnectedViewController {
    
    @objc private func updateLabel() {
        if let date = UserDefaults.standard.object(forKey: "StartTime") as? Date {
            let components = Calendar.current.dateComponents([.second], from: date, to: Date())
            let numberOfSecondsSinceStartTime = components.second ?? 0
            print(numberOfSecondsSinceStartTime)
            let hours = numberOfSecondsSinceStartTime / 3600
            let minutes = (numberOfSecondsSinceStartTime % 3600) / 60
            let seconds = (numberOfSecondsSinceStartTime % 3600) % 60
            labelDurationTime.text = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        }
    }
}
