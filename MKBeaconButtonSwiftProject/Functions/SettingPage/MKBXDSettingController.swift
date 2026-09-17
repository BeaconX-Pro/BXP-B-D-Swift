//
//  MKBXDSettingController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDSettingController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    // MARK: - Data

    private lazy var section0List: [MKSwiftSettingTextCellModel] = []
    private lazy var section1List: [MKSwiftSettingTextCellModel] = []
    private lazy var section2List: [MKSwiftSettingTextCellModel] = []
    private lazy var section3List: [MKSwiftTextFieldCellModel] = []

    private let dataModel = MKBXDSettingPageModel()

    // MARK: - Lifecycle

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readDataFromDevice()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        loadSectionDatas()
    }

    public override func leftButtonMethod() {
        NotificationCenter.default.post(name: Notification.Name("mk_bxd_popToRootViewControllerNotification"), object: nil)
    }

    public override func rightButtonMethod() {
        saveDataToDevice()
    }

    // MARK: - Read / Save

    private func readDataFromDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        dataModel.readData(sucBlock: { [weak self] in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            if !self.section3List.isEmpty {
                self.section3List[0].textFieldValue = self.dataModel.clickInterval
            }
            self.tableView.reloadData()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func saveDataToDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Config...", in: view, isPenetration: false)
        dataModel.configData(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Actions

    private func batteryReset() {
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") {})
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.sendResetCommandToDevice()
        })
        alert.showAlert(title: "Warning!",
                        message: "*Please ensure you have replaced the new battery for this beacon before reset the Battery.")
    }

    private func sendResetCommandToDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_batteryReset(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Load Datas

    private func loadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        loadSection2Datas()
        loadSection3Datas()
        tableView.reloadData()
    }

    private func loadSection0Datas() {
        let m1 = MKSwiftSettingTextCellModel()
        m1.leftMsg = "Alarm event"

        let m2 = MKSwiftSettingTextCellModel()
        m2.leftMsg = "Dismiss alarm configuration"

        let m3 = MKSwiftSettingTextCellModel()
        m3.leftMsg = "Remote reminder"

        section0List = [m1, m2, m3]
    }

    private func loadSection1Datas() {
        let m1 = MKSwiftSettingTextCellModel()
        m1.leftMsg = "3-axis accelerometer"

        let m2 = MKSwiftSettingTextCellModel()
        m2.leftMsg = "Power saving configuration"

        section1List = [m1, m2]
    }

    private func loadSection2Datas() {
        let m = MKSwiftSettingTextCellModel()
        m.leftMsg = "Reset Battery"
        section2List = [m]
    }

    private func loadSection3Datas() {
        let m = MKSwiftTextFieldCellModel()
        m.index = 0
        m.msg = "Effective click interval"
        m.textPlaceholder = "5~15"
        m.textFieldType = .realNumberOnly
        m.maxLength = 2
        m.unit = "x100ms"
        section3List = [m]
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "SETTING"
        rightButton.setImage(UIImage(named: "bxd_slotSaveIcon.png"), for: .normal)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-(MKLayout.safeAreaBottom + 49))
        }
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDSettingController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { 4 }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return section0List.count }
        if section == 1 {
            return MKBXDConnectManager.shared.threeSensor ? section1List.count : 0
        }
        if section == 2 {
            return Int(MKBXDConnectManager.shared.deviceType) == 1 ? section2List.count : 0
        }
        if section == 3 { return section3List.count }
        return 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let manager = MKBXDConnectManager.shared

        if indexPath.section == 0 && indexPath.row == 0 {
            // Alarm event
            if manager.isCR {
                navigationController?.pushViewController(MKBXDAlarmEventCRController(), animated: true)
                return
            }
            if manager.doubleBtn {
                // 支持双按键的 BXP-B-D
                navigationController?.pushViewController(MKBXDAlarmEventDBController(), animated: true)
                return
            }
            navigationController?.pushViewController(MKBXDAlarmEventController(), animated: true)
            return
        }

        if indexPath.section == 0 && indexPath.row == 1 {
            // Dismiss alarm configuration
            navigationController?.pushViewController(MKBXDDismissConfigController(), animated: true)
            return
        }

        if indexPath.section == 0 && indexPath.row == 2 {
            // Remote reminder
            navigationController?.pushViewController(MKBXDRemoteReminderController(), animated: true)
            return
        }

        if indexPath.section == 1 && indexPath.row == 0 {
            // 3-axis accelerometer
            navigationController?.pushViewController(MKBXDAccelerationController(), animated: true)
            return
        }

        if indexPath.section == 1 && indexPath.row == 1 {
            // Power saving configuration
            navigationController?.pushViewController(MKBXDPowerSaveController(), animated: true)
            return
        }

        if indexPath.section == 2 && indexPath.row == 0 {
            // Reset Battery
            batteryReset()
            return
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = MKSwiftSettingTextCell.initCellWithTableView(tableView)
            cell.dataModel = section0List[indexPath.row]
            return cell
        case 1:
            let cell = MKSwiftSettingTextCell.initCellWithTableView(tableView)
            cell.dataModel = section1List[indexPath.row]
            return cell
        case 2:
            let cell = MKSwiftSettingTextCell.initCellWithTableView(tableView)
            cell.dataModel = section2List[indexPath.row]
            return cell
        default:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section3List[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - MKSwiftTextFieldCellDelegate

extension MKBXDSettingController: MKSwiftTextFieldCellDelegate {

    public func mkDeviceTextCellValueChanged(_ index: Int, textValue: String) {
        if index == 0 {
            dataModel.clickInterval = textValue
            if !section3List.isEmpty { section3List[0].textFieldValue = textValue }
        }
    }
}
