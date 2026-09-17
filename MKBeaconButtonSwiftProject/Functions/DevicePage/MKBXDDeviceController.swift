//
//  MKBXDDeviceController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDDeviceController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    // MARK: - Data

    private lazy var section0List: [MKSwiftNormalTextCellModel] = []
    private lazy var section1List: [MKSwiftNormalTextCellModel] = []
    private lazy var section2List: [MKSwiftNormalTextCellModel] = []
    private lazy var section3List: [MKSwiftNormalTextCellModel] = []
    private lazy var section4List: [MKSwiftTextFieldCellModel] = []
    private lazy var section5List: [MKBXDDeviceIDCellModel] = []

    private let dataModel = MKBXDDevicePageModel()

    private var dfuMode: Bool = false
    private var passwordAsciiStr: String = ""
    private var confirmAsciiStr: String = ""

    // MARK: - Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !dfuMode {
            readDataFromDevice()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        loadSectionDatas()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceDFUComplete),
                                               name: Notification.Name("mk_bxd_startDfuProcessNotification"),
                                               object: nil)
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
            if !self.section4List.isEmpty {
                self.section4List[0].textFieldValue = self.dataModel.deviceName
            }
            if !self.section5List.isEmpty {
                self.section5List[0].deviceID = self.dataModel.deviceID
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

    @objc private func deviceDFUComplete() {
        dfuMode = true
    }

    // MARK: - Actions

    private func pushQuickSwitchPage() {
        let vc = MKBXDQuickSwitchController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func turnOffBeacon() {
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") {})
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.commandPowerOff()
        })
        alert.showAlert(title: "Warning!",
                        message: "Are you sure to turn off the Beacon?Please make sure the Beacon has a button to turn on!")
    }

    private func resetBeacon() {
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") {})
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.commandResetDevice()
        })
        alert.showAlert(title: "Warning!", message: "Are you sure to reset the Beacon？")
    }

    private func modifyPassword() {
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") {})
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.setPasswordToDevice()
        })
        // ⚠️ MKSwiftAlertView 的 textField 添加方式按工程实际接口调整
        let passwordField = MKSwiftAlertViewTextField(textValue: "",
                                                      placeholder: "Enter new password",
                                                      textFieldType: .normal,
                                                      maxLength: 16) { [weak self] text in
            self?.passwordAsciiStr = text
        }
        let confirmField = MKSwiftAlertViewTextField(textValue: "",
                                                     placeholder: "Enter new password again",
                                                     textFieldType: .normal,
                                                     maxLength: 16) { [weak self] text in
            self?.confirmAsciiStr = text
        }
        alert.addTextField(passwordField)
        alert.addTextField(confirmField)
        alert.showAlert(title: "Modify password",
                        message: "Note: The password should not be exceed 16 characters in length.")
    }

    private func startDFU() {
        let vc = MKBXDUpdateController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushDeviceInfoPage() {
        let vc = MKBXDDeviceInfoController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Commands

    private func commandPowerOff() {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_powerOff(sucBlock: {
            MKSwiftHudManager.shared.hide()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func commandResetDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_factoryReset(sucBlock: {
            MKSwiftHudManager.shared.hide()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func setPasswordToDevice() {
        let password = passwordAsciiStr
        let confirmPassword = confirmAsciiStr
        guard !password.isEmpty, !confirmPassword.isEmpty,
              password.count <= 16, confirmPassword.count <= 16 else {
            view.showCentralToast("Length error.")
            return
        }
        guard password == confirmPassword else {
            view.showCentralToast("Password do not match! Please try again.")
            return
        }
        MKSwiftHudManager.shared.showHUD(with: "Setting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configConnectPassword(password, sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Load Section Datas

    private func loadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        loadSection2Datas()
        loadSection3Datas()
        loadSection4Datas()
        loadSection5Datas()
        tableView.reloadData()
    }

    private func loadSection0Datas() {
        let m1 = MKSwiftNormalTextCellModel()
        m1.leftMsg = "Quick switch"
        m1.showRightIcon = true

        let m2 = MKSwiftNormalTextCellModel()
        m2.leftMsg = "Turn off Beacon"
        m2.showRightIcon = true

        section0List = [m1, m2]
    }

    private func loadSection1Datas() {
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Reset Beacon"
        m.showRightIcon = true
        section1List = [m]
    }

    private func loadSection2Datas() {
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Modify password"
        m.showRightIcon = true
        section2List = [m]
    }

    private func loadSection3Datas() {
        let m1 = MKSwiftNormalTextCellModel()
        m1.leftMsg = "DFU"
        m1.showRightIcon = true

        let m2 = MKSwiftNormalTextCellModel()
        m2.leftMsg = "Device info"
        m2.showRightIcon = true

        section3List = [m1, m2]
    }

    private func loadSection4Datas() {
        let m = MKSwiftTextFieldCellModel()
        m.index = 0
        m.msg = "Device Name"
        m.textPlaceholder = "1-10 characters"
        m.textFieldType = .normal
        m.maxLength = 10
        section4List = [m]
    }

    private func loadSection5Datas() {
        let m = MKBXDDeviceIDCellModel()
        section5List = [m]
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "DEVICE"
        view.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
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

extension MKBXDDeviceController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { 6 }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return section0List.count }
        if section == 1 {
            return MKBXDConnectManager.shared.needPassword ? section1List.count : 0
        }
        if section == 2 {
            let need = MKBXDConnectManager.shared.needPassword
                && !MKBXDConnectManager.shared.password.isEmpty
            return need ? section2List.count : 0
        }
        if section == 3 { return section3List.count }
        if section == 4 { return section4List.count }
        if section == 5 { return section5List.count }
        return 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            pushQuickSwitchPage()
            return
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            turnOffBeacon()
            return
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            resetBeacon()
            return
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            modifyPassword()
            return
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            startDFU()
            return
        }
        if indexPath.section == 3 && indexPath.row == 1 {
            pushDeviceInfoPage()
            return
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section0List[indexPath.row]
            return cell
        case 1:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section1List[indexPath.row]
            return cell
        case 2:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section2List[indexPath.row]
            return cell
        case 3:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section3List[indexPath.row]
            return cell
        case 4:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section4List[indexPath.row]
            cell.delegate = self
            return cell
        default:
            let cell = MKBXDDeviceIDCell.initCellWithTableView(tableView)
            cell.dataModel = section5List[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - MKSwiftTextFieldCellDelegate

extension MKBXDDeviceController: MKSwiftTextFieldCellDelegate {

    public func mkDeviceTextCellValueChanged(_ index: Int, textValue: String) {
        if index == 0 {
            dataModel.deviceName = textValue
            if !section4List.isEmpty { section4List[0].textFieldValue = textValue }
        }
    }
}

// MARK: - MKBXDDeviceIDCellDelegate

extension MKBXDDeviceController: MKBXDDeviceIDCellDelegate {

    public func bxd_deviceIDChanged(_ text: String) {
        dataModel.deviceID = text
        if !section5List.isEmpty { section5List[0].deviceID = text }
    }
}
