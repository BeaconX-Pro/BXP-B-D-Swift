//
//  MKBXDTabBarController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - Delegate

public protocol MKBXDTabBarControllerDelegate: AnyObject {
    /// 返回到扫描页面，肯定需要开启扫描
    /// - Parameter need: YES:DFU 升级情况下返回，需要设置扫描代理；NO:不需要重设代理
    func mk_bxd_needResetScanDelegate(_ need: Bool)
}

// MARK: - TabBar Controller

public final class MKBXDTabBarController: UITabBarController {

    public weak var tabBarDelegate: MKBXDTabBarControllerDelegate?

    // 状态标记
    /// 01:连接成功后，1 分钟内没有通过密码验证（未输入密码，或者连续输入密码错误）认为超时，返回结果，然后断开连接
    /// 02:修改密码成功后，返回结果，断开连接
    /// 03:恢复出厂设置
    /// 04:关机
    private var disconnectType: Bool = false
    private var startDfu: Bool = false

    // MARK: - Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // OC 中 navigationController 为 nil 时，[nil containsObject:self] 返回 NO，!NO = YES，会执行 disconnect
        // Swift 中可选绑定为 nil 时直接跳过，因此需要显式处理 nil 情况
        if navigationController == nil || !navigationController!.viewControllers.contains(self) {
            MKBXDCentralManager.shared.disconnect()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubPages()
        addNotifications()
    }

    // MARK: - Notifications

    private func addNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gotoScanPage),
                                               name: Notification.Name("mk_bxd_popToRootViewControllerNotification"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dfuUpdateComplete),
                                               name: Notification.Name("mk_bxd_centralDeallocNotification"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(centralManagerStateChanged),
                                               name: .mk_bxd_centralManagerStateChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(disconnectTypeNotification(_:)),
                                               name: .mk_bxd_deviceDisconnectTypeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceConnectStateChanged),
                                               name: .mk_bxd_peripheralConnectStateChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(startDfuProcess),
                                               name: Notification.Name("mk_bxd_startDfuProcessNotification"),
                                               object: nil)
    }

    @objc private func gotoScanPage() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.tabBarDelegate?.mk_bxd_needResetScanDelegate(false)
        }
    }

    @objc private func dfuUpdateComplete() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.tabBarDelegate?.mk_bxd_needResetScanDelegate(true)
        }
    }

    @objc private func disconnectTypeNotification(_ note: Notification) {
        if startDfu { return }
        guard let type = note.userInfo?["type"] as? String else { return }
        // 02:修改密码成功后，返回结果，断开连接
        // 03:恢复出厂设置
        // 04:关机
        disconnectType = true
        if type == "02" {
            showAlert(msg: "Modify password success! Please reconnect the Device.", title: "")
            return
        }
        if type == "03" {
            showAlert(msg: "Factory reset successfully!Please reconnect the device.", title: "Factory Reset")
            return
        }
        if type == "04" {
            gotoScanPage()
            return
        }
    }

    @objc private func centralManagerStateChanged() {
        if disconnectType || startDfu { return }
        if MKBXDCentralManager.shared.centralStatus != .enable {
            showAlert(msg: "The current system of bluetooth is not available!", title: "Dismiss")
        }
    }

    @objc private func deviceConnectStateChanged() {
        if disconnectType || startDfu { return }
        showAlert(msg: "The device is disconnected.", title: "Dismiss")
    }

    @objc private func startDfuProcess() {
        startDfu = true
    }

    // MARK: - Private

    private func showAlert(msg: String, title: String) {
        // 让 setting 页面推出的 alert 消失
        NotificationCenter.default.post(name: Notification.Name("mk_bxd_needDismissAlert"), object: nil)
        // 让所有 MKPickView 消失
        NotificationCenter.default.post(name: Notification.Name("mk_customUIModule_dismissPickView"), object: nil)

        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.gotoScanPage()
        })
        alert.showAlert(title: title, message: msg)
    }

    private func loadSubPages() {
        // Alarm page
        let alarmPage: UIViewController
        if Int(MKBXDConnectManager.shared.deviceType) == 0 {
            // 0 旧固件
            alarmPage = MKBXDAlarmController()
        } else {
            // 1 支持长链接 2 支持双按键
            alarmPage = MKBXDAlarmV2Controller()
        }
        alarmPage.tabBarItem.title = "ALARM"
        alarmPage.tabBarItem.image = UIImage(named: "bxd_slotTabBarItemUnselected.png")
        alarmPage.tabBarItem.selectedImage = UIImage(named: "bxd_slotTabBarItemSelected.png")
        let alarmNav = MKSwiftBaseNavigationController(rootViewController: alarmPage)

        // Setting page
        let settingPage = MKBXDSettingController()
        settingPage.tabBarItem.title = "SETTING"
        settingPage.tabBarItem.image = UIImage(named: "bxd_settingTabBarItemUnselected.png")
        settingPage.tabBarItem.selectedImage = UIImage(named: "bxd_settingTabBarItemSelected.png")
        let settingNav = MKSwiftBaseNavigationController(rootViewController: settingPage)

        // Device page
        let devicePage = MKBXDDeviceController()
        devicePage.tabBarItem.title = "DEVICE"
        devicePage.tabBarItem.image = UIImage(named: "bxd_deviceTabBarItemUnselected.png")
        devicePage.tabBarItem.selectedImage = UIImage(named: "bxd_deviceTabBarItemSelected.png")
        let deviceNav = MKSwiftBaseNavigationController(rootViewController: devicePage)

        viewControllers = [alarmNav, settingNav, deviceNav]
    }
}
