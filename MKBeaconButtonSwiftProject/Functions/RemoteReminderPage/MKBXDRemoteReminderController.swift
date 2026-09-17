//
//  MKBXDRemoteReminderController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDRemoteReminderController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        tv.separatorStyle = .none                     // ✅ 跟 SensorAdvancedController 一致
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0            // ✅ 跟 SensorAdvancedController 一致
        }
        return tv
    }()

    // MARK: - Data

    private lazy var section0List: [MKBXDRemoteReminderCellModel] = []
    private lazy var section1List: [MKSwiftTextFieldCellModel] = []
    private lazy var section2List: [MKBXDRemoteReminderCellModel] = []
    private lazy var section3List: [MKSwiftTextFieldCellModel] = []
    private lazy var section4List: [MKBXDRemoteReminderCellModel] = []
    private lazy var section5List: [MKSwiftTextFieldCellModel] = []
    private lazy var headerList: [MKSwiftTableSectionLineHeaderModel] = []

    private let dataModel = MKBXDRemoteReminderModel()

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        loadSectionDatas()              // ✅ 先加载 section 数据
        readDataFromDevice()            // ✅ 再读设备数据
    }

    // MARK: - Read

    private func readDataFromDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        dataModel.readData(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.reloadSectionDatas()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Reminders

    private func reminderLED() {
        guard !dataModel.blinkingTime.isEmpty,
              let time = Int(dataModel.blinkingTime), time >= 1, time <= 6000 else {
            view.showCentralToast("Blink Time Error")
            return
        }
        guard !dataModel.blinkingInterval.isEmpty,
              let interval = Int(dataModel.blinkingInterval), interval >= 0, interval <= 100 else {
            view.showCentralToast("Blink Interval Error")
            return
        }
        MKSwiftHudManager.shared.showHUD(with: "Config...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configRemoteReminderLEDNotiParams(blinkingTime: time,
                                                              blinkingInterval: interval,
                                                              sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func reminderVibration() {
        guard !dataModel.vibratingTime.isEmpty,
              let time = Int(dataModel.vibratingTime), time >= 1, time <= 6000 else {
            view.showCentralToast("Vibrating Time Error")
            return
        }
        guard !dataModel.vibratingInterval.isEmpty,
              let interval = Int(dataModel.vibratingInterval), interval >= 0, interval <= 100 else {
            view.showCentralToast("Vibrating Interval Error")
            return
        }
        MKSwiftHudManager.shared.showHUD(with: "Config...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configRemoteReminderVibrationNotiParams(vibratingTime: time,
                                                                    vibraingInterval: interval,
                                                                    sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func reminderBuzzer() {
        guard !dataModel.ringingTime.isEmpty,
              let time = Int(dataModel.ringingTime), time >= 1, time <= 6000 else {
            view.showCentralToast("Ringing Time Error")
            return
        }
        guard !dataModel.ringingInterval.isEmpty,
              let interval = Int(dataModel.ringingInterval), interval >= 0, interval <= 100 else {
            view.showCentralToast("Ringing Interval Error")
            return
        }
        MKSwiftHudManager.shared.showHUD(with: "Config...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configRemoteReminderBuzzerNotiParams(ringingTime: time,
                                                                 ringingInterval: interval,
                                                                 sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Private Helpers

    private var isCR: Bool { MKBXDConnectManager.shared.isCR }

    private func numberOfRows(section: Int) -> Int {
        if section == 0 { return section0List.count }
        if section == 1 { return section1List.count }
        if section == 2 { return isCR ? section2List.count : 0 }
        if section == 3 { return isCR ? section3List.count : 0 }
        if section == 4 { return section4List.count }
        if section == 5 { return section5List.count }
        return 0
    }

    private func heightForHeader(section: Int) -> CGFloat {
        if section == 0 || section == 4 { return 10 }
        if section == 2 { return isCR ? 10 : 0 }
        return 0
    }

    // MARK: - Load Datas

    /// 首次加载：初始化所有 section 数据 + header
    private func loadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        loadSection2Datas()
        loadSection3Datas()
        loadSection4Datas()
        loadSection5Datas()

        headerList = (0..<6).map { _ in MKSwiftTableSectionLineHeaderModel() }
        tableView.reloadData()
    }

    /// 重新加载：只重建 section 数据（保持 header 不变）
    private func reloadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        loadSection2Datas()
        loadSection3Datas()
        loadSection4Datas()
        loadSection5Datas()

        if headerList.isEmpty {
            headerList = (0..<6).map { _ in MKSwiftTableSectionLineHeaderModel() }
        }
        tableView.reloadData()
    }

    private func loadSection0Datas() {
        let m = MKBXDRemoteReminderCellModel()
        m.msg = "LED notification"
        m.index = 0
        section0List = [m]
    }

    private func loadSection1Datas() {
        let m1 = MKSwiftTextFieldCellModel()
        m1.index = 0
        m1.msg = "Blinking time"
        m1.textPlaceholder = "1~6000"
        m1.textFieldValue = dataModel.blinkingTime
        m1.textFieldType = .realNumberOnly
        m1.unit = "x100ms"
        m1.maxLength = 4

        let m2 = MKSwiftTextFieldCellModel()
        m2.index = 1
        m2.msg = "Blinking interval"
        m2.textPlaceholder = "0~100"
        m2.textFieldValue = dataModel.blinkingInterval
        m2.textFieldType = .realNumberOnly
        m2.unit = "x100ms"
        m2.maxLength = 3

        section1List = [m1, m2]
    }

    private func loadSection2Datas() {
        let m = MKBXDRemoteReminderCellModel()
        m.msg = "Vibration notification"
        m.index = 1
        section2List = [m]
    }

    private func loadSection3Datas() {
        let m1 = MKSwiftTextFieldCellModel()
        m1.index = 2
        m1.msg = "Vibrating time"
        m1.textPlaceholder = "1~6000"
        m1.textFieldValue = dataModel.vibratingTime
        m1.textFieldType = .realNumberOnly
        m1.unit = "x100ms"
        m1.maxLength = 4

        let m2 = MKSwiftTextFieldCellModel()
        m2.index = 3
        m2.msg = "Vibrating interval"
        m2.textPlaceholder = "0~100"
        m2.textFieldValue = dataModel.vibratingInterval
        m2.textFieldType = .realNumberOnly
        m2.unit = "x100ms"
        m2.maxLength = 3

        section3List = [m1, m2]
    }

    private func loadSection4Datas() {
        let m = MKBXDRemoteReminderCellModel()
        m.msg = "Buzzer notification"
        m.index = 2
        section4List = [m]
    }

    private func loadSection5Datas() {
        let m1 = MKSwiftTextFieldCellModel()
        m1.index = 4
        m1.msg = "Ringing time"
        m1.textPlaceholder = "1~6000"
        m1.textFieldValue = dataModel.ringingTime
        m1.textFieldType = .realNumberOnly
        m1.unit = "x100ms"
        m1.maxLength = 4

        let m2 = MKSwiftTextFieldCellModel()
        m2.index = 5
        m2.msg = "Ringing interval"
        m2.textPlaceholder = "0~100"
        m2.textFieldValue = dataModel.ringingInterval
        m2.textFieldType = .realNumberOnly
        m2.unit = "x100ms"
        m2.maxLength = 3

        section5List = [m1, m2]
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "Remote reminder"
        view.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-MKLayout.safeAreaBottom)
        }
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDRemoteReminderController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { headerList.count }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows(section: section)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        heightForHeader(section: section)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MKSwiftTableSectionLineHeader.dequeueHeader(with: tableView)
        if section < headerList.count {
            header.headerModel = headerList[section]
        }
        return header
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = MKBXDRemoteReminderCell.initCellWithTableView(tableView)
            cell.dataModel = section0List[indexPath.row]
            cell.delegate = self
            return cell
        case 1:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section1List[indexPath.row]
            cell.delegate = self
            return cell
        case 2:
            let cell = MKBXDRemoteReminderCell.initCellWithTableView(tableView)
            cell.dataModel = section2List[indexPath.row]
            cell.delegate = self
            return cell
        case 3:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section3List[indexPath.row]
            cell.delegate = self
            return cell
        case 4:
            let cell = MKBXDRemoteReminderCell.initCellWithTableView(tableView)
            cell.dataModel = section4List[indexPath.row]
            cell.delegate = self
            return cell
        default:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section5List[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - MKSwiftTextFieldCellDelegate

extension MKBXDRemoteReminderController: MKSwiftTextFieldCellDelegate {

    public func mkDeviceTextCellValueChanged(_ index: Int, textValue: String) {
        if index == 0 {
            dataModel.blinkingTime = textValue
            if !section1List.isEmpty { section1List[0].textFieldValue = textValue }
            return
        }
        if index == 1 {
            dataModel.blinkingInterval = textValue
            if section1List.count > 1 { section1List[1].textFieldValue = textValue }
            return
        }
        if index == 2 {
            dataModel.vibratingTime = textValue
            if !section3List.isEmpty { section3List[0].textFieldValue = textValue }
            return
        }
        if index == 3 {
            dataModel.vibratingInterval = textValue
            if section3List.count > 1 { section3List[1].textFieldValue = textValue }
            return
        }
        if index == 4 {
            dataModel.ringingTime = textValue
            if !section5List.isEmpty { section5List[0].textFieldValue = textValue }
            return
        }
        if index == 5 {
            dataModel.ringingInterval = textValue
            if section5List.count > 1 { section5List[1].textFieldValue = textValue }
        }
    }
}

// MARK: - MKBXDRemoteReminderCellDelegate

extension MKBXDRemoteReminderController: MKBXDRemoteReminderCellDelegate {

    public func bxd_remindButtonPressed(_ index: Int) {
        if index == 0 { reminderLED() }
        else if index == 1 { reminderVibration() }
        else if index == 2 { reminderBuzzer() }
    }
}
