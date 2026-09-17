//
//  MKBXDQuickSwitchController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI
import MKSwiftBeaconXCustomUI

public final class MKBXDQuickSwitchController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 11, left: 11, bottom: 0, right: 11)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 11
        layout.minimumInteritemSpacing = 11

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 246/255.0, green: 247/255.0, blue: 251/255.0, alpha: 1)
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceVertical = true
        // ⚠️ 按工程实际 Cell 类名调整
        cv.register(MKBXQuickSwitchCell.self, forCellWithReuseIdentifier: "MKBXQuickSwitchCellIdenty")
        return cv
    }()

    // MARK: - Data

    private lazy var dataList: [MKBXQuickSwitchCellModel] = []
    private let dataModel = MKBXDQuickSwitchModel()

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        readDataFromDevice()
    }

    // MARK: - Read

    private func readDataFromDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        dataModel.read(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.loadSectionData()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Load Data

    private func loadSectionData() {
        var list: [MKBXQuickSwitchCellModel] = []

        let m1 = MKBXQuickSwitchCellModel()
        m1.index = 0
        m1.titleMsg = "Connectable status"
        m1.isOn = dataModel.connectable
        list.append(m1)

        let m2 = MKBXQuickSwitchCellModel()
        m2.index = 1
        m2.titleMsg = "Reset Beacon by button"
        m2.isOn = dataModel.resetByButton
        list.append(m2)

        let m3 = MKBXQuickSwitchCellModel()
        m3.index = 2
        m3.titleMsg = "Password verification"
        m3.isOn = dataModel.passwordVerification
        list.append(m3)

        let m4 = MKBXQuickSwitchCellModel()
        m4.index = 3
        m4.titleMsg = "Dismiss alarm by button"
        m4.isOn = dataModel.dismiss
        list.append(m4)

        let m5 = MKBXQuickSwitchCellModel()
        m5.index = 4
        m5.titleMsg = "Scan response packet"
        m5.isOn = dataModel.scanPacket
        list.append(m5)

        if MKBXDConnectManager.shared.isCR {
            let m6 = MKBXQuickSwitchCellModel()
            m6.index = 5
            m6.titleMsg = "Turn off Beacon by button"
            m6.isOn = dataModel.turnOffByButton
            list.append(m6)
        }

        dataList = list
        collectionView.reloadData()
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "Quick switch"
        view.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-MKLayout.safeAreaBottom)
        }
    }
}

// MARK: - UICollectionViewDataSource / Delegate / FlowLayout

extension MKBXDQuickSwitchController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    public func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataList.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MKBXQuickSwitchCellIdenty", for: indexPath) as! MKBXQuickSwitchCell
        cell.dataModel = dataList[indexPath.row]
        cell.delegate = self
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (MKScreen.width - 3 * 11) / 2, height: 85)
    }
}

// MARK: - MKBXQuickSwitchCellDelegate

extension MKBXDQuickSwitchController: MKBXQuickSwitchCellDelegate {

    public func mk_swift_bx_quickSwitchStatusChanged(_ isOn: Bool, index: Int) {
        switch index {
        case 0: configConnectEnable(isOn)
        case 1: configButtonReset(isOn)
        case 2: configPasswordVerification(isOn)
        case 3: configDismissByButton(isOn)
        case 4: configScanPacket(isOn)
        case 5: setTurnOffByButtonToDevice(isOn)
        default: break
        }
    }
}

// MARK: - Config Methods

extension MKBXDQuickSwitchController {

    // MARK: 可连接性

    private func configConnectEnable(_ connect: Bool) {
        if connect {
            setConnectStatusToDevice(connect)
            return
        }
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") { [weak self] in
            self?.collectionView.reloadData()
        })
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.setConnectStatusToDevice(connect)
        })
        alert.showAlert(title: "Warning!", message: "Are you sure to set the Beacon non-connectable？")
    }

    private func setConnectStatusToDevice(_ connect: Bool) {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configConnectable(connect, sucBlock: { [weak self] in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.dataModel.connectable = connect
            if !self.dataList.isEmpty { self.dataList[0].isOn = connect }
            self.view.showCentralToast("Success!")
        }, failedBlock: { [weak self] error in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            self.collectionView.reloadData()
        })
    }

    // MARK: 密码验证

    private func configPasswordVerification(_ isOn: Bool) {
        if isOn {
            commandForPasswordVerification(isOn)
            return
        }
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") { [weak self] in
            self?.collectionView.reloadData()
        })
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.commandForPasswordVerification(isOn)
        })
        alert.showAlert(title: "Warning!",
                        message: "If Password verification is disabled, it will not need password to connect the Beacon.")
    }

    private func commandForPasswordVerification(_ isOn: Bool) {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configPasswordVerification(isOn, sucBlock: { [weak self] in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            if self.dataList.count > 2 { self.dataList[2].isOn = isOn }
            MKBXDConnectManager.shared.needPassword = isOn
            self.view.showCentralToast("Success!")
        }, failedBlock: { [weak self] error in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            self.collectionView.reloadData()
        })
    }

    // MARK: 按键恢复出厂

    private func configButtonReset(_ isOn: Bool) {
        if isOn {
            setButtonResetToDevice(isOn)
            return
        }
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") { [weak self] in
            self?.collectionView.reloadData()
        })
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.setButtonResetToDevice(isOn)
        })
        alert.showAlert(title: "Warning!",
                        message: "If Button reset is disabled, you cannot reset the Beacon by button operation.")
    }

    private func setButtonResetToDevice(_ isOn: Bool) {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configResetDeviceByButtonStatus(isOn, sucBlock: { [weak self] in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.dataModel.resetByButton = isOn
            if self.dataList.count > 1 { self.dataList[1].isOn = isOn }
            self.view.showCentralToast("Success!")
        }, failedBlock: { [weak self] error in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            self.collectionView.reloadData()
        })
    }

    // MARK: 回应包

    private func configScanPacket(_ isOn: Bool) {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configScanResponsePacket(isOn, sucBlock: { [weak self] in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.dataModel.scanPacket = isOn
            if self.dataList.count > 4 { self.dataList[4].isOn = isOn }
            self.view.showCentralToast("Success!")
        }, failedBlock: { [weak self] error in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            self.collectionView.reloadData()
        })
    }

    // MARK: 按键消警

    private func configDismissByButton(_ isOn: Bool) {
        if isOn {
            setDismissByButtonToDevice(isOn)
            return
        }
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") { [weak self] in
            self?.collectionView.reloadData()
        })
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.setDismissByButtonToDevice(isOn)
        })
        alert.showAlert(title: "Warning!",
                        message: "If this function is disabled, you cannot dismiss alarm by button.")
    }

    private func setDismissByButtonToDevice(_ isOn: Bool) {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configDismissAlarmByButton(isOn, sucBlock: { [weak self] in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.dataModel.dismiss = isOn
            if self.dataList.count > 3 { self.dataList[3].isOn = isOn }
            self.view.showCentralToast("Success!")
        }, failedBlock: { [weak self] error in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            self.collectionView.reloadData()
        })
    }

    // MARK: 按键开关机

    private func setTurnOffByButtonToDevice(_ isOn: Bool) {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configTurnOffByButton(isOn, sucBlock: { [weak self] in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.dataModel.turnOffByButton = isOn
            if self.dataList.count > 5 { self.dataList[5].isOn = isOn }
            self.view.showCentralToast("Success!")
        }, failedBlock: { [weak self] error in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            self.collectionView.reloadData()
        })
    }
}
