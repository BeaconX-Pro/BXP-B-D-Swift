//
//  MKBXDAlarmModeConfigController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - Page Type

public enum MKBXDAlarmModeConfigControllerType: Int {
    case single = 0
    case double = 1
    case long = 2
    case abnormal = 3
}

// MARK: - Controller

public final class MKBXDAlarmModeConfigController: MKSwiftBaseViewController {

    public var pageType: MKBXDAlarmModeConfigControllerType = .single

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        tv.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        return tv
    }()

    // MARK: - Data

    private lazy var section0List: [MKSwiftTextSwitchCellModel] = []
    private lazy var section1List: [MKSwiftNormalTextCellModel] = []
    private lazy var section2List: [MKBXDDeviceIDCellModel] = []
    private lazy var section3List: [MKSwiftTextFieldCellModel] = []
    private lazy var section4List: [MKSwiftNormalSliderCellModel] = []
    private lazy var section5List: [MKBXDTxPowerCellModel] = []
    private lazy var section6List: [MKSwiftTextSwitchCellModel] = []
    private lazy var section7List: [MKBXDAbnormalInactivityTimeCellModel] = []
    private lazy var section8List: [MKSwiftTextFieldCellModel] = []
    private lazy var section9List: [MKBXDTxPowerCellModel] = []
    private lazy var section10List: [MKSwiftNormalTextCellModel] = []
    private lazy var headerList: [MKSwiftTableSectionLineHeaderModel] = []

    private lazy var dataModel: MKBXDAlarmModeConfigModel = {
        let m = MKBXDAlarmModeConfigModel()
        m.alarmType = pageType.rawValue
        return m
    }()

    // MARK: - Lifecycle

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        loadSectionDatas()          // ✅ 先加载 section 数据
        readDatasFromDevice()       // ✅ 再读设备数据
    }

    public override func rightButtonMethod() {
        saveDataToDevice()
    }

    // MARK: - Read

    private func readDatasFromDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        dataModel.readData(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.reloadSectionDatas()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func saveDataToDevice() {
        if !dataModel.advIsOn {
            var valid = true
            switch pageType {
            case .single:
                if !dataModel.doubleIsOn && !dataModel.longIsOn && !dataModel.inactivityIsOn { valid = false }
            case .double:
                if !dataModel.singleIsOn && !dataModel.longIsOn && !dataModel.inactivityIsOn { valid = false }
            case .long:
                if !dataModel.singleIsOn && !dataModel.doubleIsOn && !dataModel.inactivityIsOn { valid = false }
            case .abnormal:
                if !dataModel.singleIsOn && !dataModel.doubleIsOn && !dataModel.longIsOn { valid = false }
            }
            if !valid {
                let alert = MKSwiftAlertView()
                alert.addAction(MKSwiftAlertViewAction(title: "OK") {})
                alert.showAlert(title: "Warning!",
                                message: "*Please ensure that at lease 1 SLOT is enabled")
                return
            }
        }
        MKSwiftHudManager.shared.showHUD(with: "Config...", in: view, isPenetration: false)
        dataModel.configData(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Section Numbers

    private func loadSectionNumbers(section: Int) -> Int {
        if section == 0 { return section0List.count }
        if !dataModel.advIsOn { return 0 }
        if section == 1 { return section1List.count }
        if section == 2 { return 0 }   // 隐藏 deviceID
        if section == 3 { return section3List.count }
        if section == 4 { return section4List.count }
        if section == 5 { return section5List.count }
        if section == 6 {
            return dataModel.alarmMode ? section6List.count : 1
        }
        if section == 7 && dataModel.alarmMode {
            return pageType == .abnormal ? section7List.count : 0
        }
        if section == 8 && dataModel.alarmMode { return section8List.count }
        if section == 9 && dataModel.alarmMode { return section9List.count }
        if section == 10 && dataModel.alarmMode { return section10List.count }
        return 0
    }

    // MARK: - Cell

    private func loadCell(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = MKSwiftTextSwitchCell.initCellWithTableView(tableView)
            cell.dataModel = section0List[indexPath.row]
            cell.delegate = self
            return cell
        case 1:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section1List[indexPath.row]
            return cell
        case 2:
            let cell = MKBXDDeviceIDCell.initCellWithTableView(tableView)
            cell.dataModel = section2List[indexPath.row]
            cell.delegate = self
            return cell
        case 3:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section3List[indexPath.row]
            cell.delegate = self
            return cell
        case 4:
            let cell = MKSwiftNormalSliderCell.initCellWithTableView(tableView)
            cell.dataModel = section4List[indexPath.row]
            cell.delegate = self
            return cell
        case 5:
            let cell = MKBXDTxPowerCell.initCellWithTableView(tableView)
            cell.dataModel = section5List[indexPath.row]
            cell.delegate = self
            return cell
        case 6:
            let cell = MKSwiftTextSwitchCell.initCellWithTableView(tableView)
            cell.dataModel = section6List[indexPath.row]
            cell.delegate = self
            return cell
        case 7:
            let cell = MKBXDAbnormalInactivityTimeCell.initCellWithTableView(tableView)
            cell.dataModel = section7List[indexPath.row]
            cell.delegate = self
            return cell
        case 8:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section8List[indexPath.row]
            cell.delegate = self
            return cell
        case 9:
            let cell = MKBXDTxPowerCell.initCellWithTableView(tableView)
            cell.dataModel = section9List[indexPath.row]
            cell.delegate = self
            return cell
        default:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section10List[indexPath.row]
            return cell
        }
    }

    // MARK: - Load Section Datas

    private func loadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        loadSection2Datas()
        loadSection3Datas()
        loadSection4Datas()
        loadSection5Datas()
        loadSection6Datas()
        loadSection7Datas()
        loadSection8Datas()
        loadSection9Datas()
        loadSection10Datas()

        headerList = (0..<11).map { _ in MKSwiftTableSectionLineHeaderModel() }
        tableView.reloadData()
    }

    private func reloadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        loadSection2Datas()
        loadSection3Datas()
        loadSection4Datas()
        loadSection5Datas()
        loadSection6Datas()
        loadSection7Datas()
        loadSection8Datas()
        loadSection9Datas()
        loadSection10Datas()

        if headerList.isEmpty {
            headerList = (0..<11).map { _ in MKSwiftTableSectionLineHeaderModel() }
        }
        tableView.reloadData()
    }

    private func loadSection0Datas() {
        let m = MKSwiftTextSwitchCellModel()
        m.index = 0
        m.msg = "SLOT advertisement"
        m.isOn = dataModel.advIsOn
        section0List = [m]
    }

    private func loadSection1Datas() {
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Parameters"
        section1List = [m]
    }

    private func loadSection2Datas() {
        let m = MKBXDDeviceIDCellModel()
        m.deviceID = dataModel.deviceID
        section2List = [m]
    }

    private func loadSection3Datas() {
        let m = MKSwiftTextFieldCellModel()
        m.index = 0
        m.msg = "Adv interval"
        m.textPlaceholder = "1~500"
        m.textFieldType = .realNumberOnly
        m.textFieldValue = dataModel.advInterval
        m.maxLength = 3
        m.unit = "x20ms"
        section3List = [m]
    }

    private func loadSection4Datas() {
        let m = MKSwiftNormalSliderCellModel()
        m.index = 0
        m.msg = MKSwiftUIAdaptor.attributedString(
            ["Ranging data", "   (-100dBm~0dBm)"],
            fonts: [MKFont.font(15), MKFont.font(13)],
            colors: [MKColor.defaultText, UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1)]
        )
        m.sliderMinValue = -100
        m.sliderValue = dataModel.rangingData
        section4List = [m]
    }

    private func loadSection5Datas() {
        let m = MKBXDTxPowerCellModel()
        m.index = 0
        m.txPower = dataModel.txPower
        section5List = [m]
    }

    private func loadSection6Datas() {
        let m1 = MKSwiftTextSwitchCellModel()
        m1.index = 1
        m1.msg = "Alarm mode"
        m1.isOn = dataModel.alarmMode

        let m2 = MKSwiftTextSwitchCellModel()
        m2.index = 2
        m2.msg = "Stay advertising before triggered"
        m2.isOn = dataModel.stayAdv

        section6List = [m1, m2]
    }

    private func loadSection7Datas() {
        let m = MKBXDAbnormalInactivityTimeCellModel()
        m.time = dataModel.abnormalTime
        m.advTime = dataModel.alarmMode_advTime
        section7List = [m]
    }

    private func loadSection8Datas() {
        let m1 = MKSwiftTextFieldCellModel()
        m1.index = 1
        m1.msg = "Advertising time"
        m1.textPlaceholder = "1~65535"
        m1.textFieldType = .realNumberOnly
        m1.textFieldValue = dataModel.alarmMode_advTime
        m1.maxLength = 5
        m1.unit = "s"

        let m2 = MKSwiftTextFieldCellModel()
        m2.index = 2
        m2.msg = "Adv interval"
        m2.textPlaceholder = "1~500"
        m2.textFieldType = .realNumberOnly
        m2.textFieldValue = dataModel.alarmMode_advInterval
        m2.maxLength = 3
        m2.unit = "x20ms"

        section8List = [m1, m2]
    }

    private func loadSection9Datas() {
        let m = MKBXDTxPowerCellModel()
        m.index = 1
        m.txPower = dataModel.alarmMode_txPower
        section9List = [m]
    }

    private func loadSection10Datas() {
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Trigger notification type"
        m.showRightIcon = true
        section10List = [m]
    }

    // MARK: - UI

    private func loadSubViews() {
        switch pageType {
        case .single:   defaultTitle = "Single press mode"
        case .double:   defaultTitle = "Double press mode"
        case .long:     defaultTitle = "Long press mode"
        case .abnormal: defaultTitle = "Abnormal inactivity mode"
        }
        view.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        rightButton.setImage(UIImage(named: "bxd_slotSaveIcon.png"), for: .normal)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-MKLayout.safeAreaBottom)
        }
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDAlarmModeConfigController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { headerList.count }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadSectionNumbers(section: section)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 7 { return 95 }
        if indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 9 { return 60 }
        return 44
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // ✅ 动态返回 header 高度
        if section == 0 { return 10 }
        if dataModel.advIsOn && section == 1 { return 10 }
        if dataModel.alarmMode && section == 6 { return 10 }
        return 0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MKSwiftTableSectionLineHeader.dequeueHeader(with: tableView)
        if section < headerList.count {
            header.headerModel = headerList[section]
        }
        return header
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 10 && indexPath.row == 0 {
            let vc = MKBXDAlarmNotiTypeController()
            vc.pageType = MKBXDAlarmNotiTypeControllerType(rawValue: pageType.rawValue) ?? .single
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadCell(indexPath: indexPath)
    }
}

// MARK: - MKSwiftTextSwitchCellDelegate

extension MKBXDAlarmModeConfigController: MKSwiftTextSwitchCellDelegate {
    public func MKSwiftTextSwitchCellStatusChanged(isOn: Bool, index: Int) {
        if index == 0 {
            dataModel.advIsOn = isOn
            if !section0List.isEmpty { section0List[0].isOn = isOn }
            tableView.reloadData()
            return
        }
        if index == 1 {
            dataModel.alarmMode = isOn
            if !section6List.isEmpty { section6List[0].isOn = isOn }
            tableView.reloadData()
            return
        }
        if index == 2 {
            dataModel.stayAdv = isOn
            if section6List.count > 1 { section6List[1].isOn = isOn }
        }
    }
}

// MARK: - MKSwiftTextFieldCellDelegate

extension MKBXDAlarmModeConfigController: MKSwiftTextFieldCellDelegate {

    public func mkDeviceTextCellValueChanged(_ index: Int, textValue: String) {
        if index == 0 {
            dataModel.advInterval = textValue
            if !section3List.isEmpty { section3List[0].textFieldValue = textValue }
            return
        }
        if index == 1 {
            dataModel.alarmMode_advTime = textValue
            if !section8List.isEmpty { section8List[0].textFieldValue = textValue }
            if pageType == .abnormal, !section7List.isEmpty {
                section7List[0].advTime = textValue
                tableView.reloadSections(IndexSet(integer: 7), with: .none)
            }
            return
        }
        if index == 2 {
            dataModel.alarmMode_advInterval = textValue
            if section8List.count > 1 { section8List[1].textFieldValue = textValue }
        }
    }
}

// MARK: - MKSwiftNormalSliderCellDelegate

extension MKBXDAlarmModeConfigController: MKSwiftNormalSliderCellDelegate {

    public func mk_normalSliderValueChanged(_ value: Int, index: Int) {
        if index == 0 {
            dataModel.rangingData = value
            if !section4List.isEmpty { section4List[0].sliderValue = value }
        }
    }
}

// MARK: - MKBXDDeviceIDCellDelegate

extension MKBXDAlarmModeConfigController: MKBXDDeviceIDCellDelegate {

    public func bxd_deviceIDChanged(_ text: String) {
        dataModel.deviceID = text
        if !section2List.isEmpty { section2List[0].deviceID = text }
    }
}

// MARK: - MKBXDTxPowerCellDelegate

extension MKBXDAlarmModeConfigController: MKBXDTxPowerCellDelegate {

    public func bxd_txPowerChanged(_ index: Int, txPower: Int) {
        if index == 0 {
            dataModel.txPower = txPower
            if !section5List.isEmpty { section5List[0].txPower = txPower }
            return
        }
        if index == 1 {
            dataModel.alarmMode_txPower = txPower
            if !section9List.isEmpty { section9List[0].txPower = txPower }
        }
    }
}

// MARK: - MKBXDAbnormalInactivityTimeCellDelegate

extension MKBXDAlarmModeConfigController: MKBXDAbnormalInactivityTimeCellDelegate {

    public func bxd_abnormalInactivityTimeChanged(_ time: String) {
        dataModel.abnormalTime = time
        if !section7List.isEmpty { section7List[0].time = time }
    }
}
