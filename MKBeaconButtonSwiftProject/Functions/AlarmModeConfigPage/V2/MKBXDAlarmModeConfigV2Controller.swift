//
//  MKBXDAlarmModeConfigV2Controller.swift
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

public enum MKBXDAlarmModeConfigV2ControllerType: Int {
    case single = 0
    case double = 1
    case long = 2
    case abnormal = 3
}

// MARK: - Controller

public final class MKBXDAlarmModeConfigV2Controller: MKSwiftBaseViewController {

    public var pageType: MKBXDAlarmModeConfigV2ControllerType = .single

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        return tv
    }()

    // MARK: - Data

    private lazy var section0List: [MKSwiftTextSwitchCellModel] = []
    private lazy var section1List: [MKBXDSlotFramePickCellModel] = []
    private lazy var section2List: [Any] = []
    private lazy var section3List: [MKBXDSlotParamCellModel] = []
    private lazy var section4List: [MKSwiftTextSwitchCellModel] = []
    private lazy var section5List: [MKBXDAbnormalInactivityTimeCellModel] = []
    private lazy var section6List: [MKSwiftTextFieldCellModel] = []
    private lazy var section7List: [MKBXDTxPowerCellModel] = []
    private lazy var section8List: [MKBXDTriggerTypeClickCellModel] = []
    private lazy var section9List: [MKBXDAlarmTypePickCellModel] = []
    private lazy var section10List: [MKSwiftTextFieldCellModel] = []
    private lazy var section11List: [MKSwiftTextFieldCellModel] = []
    private lazy var section12List: [MKSwiftTextFieldCellModel] = []
    private lazy var headerList: [MKSwiftTableSectionLineHeaderModel] = []

    private lazy var dataModel: MKBXDAlarmModeConfigV2Model = {
        let m = MKBXDAlarmModeConfigV2Model()
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
        loadSectionDatas()              // ✅ 先加载 section 数据
        readDataFromDevice()            // ✅ 再读设备数据
    }

    public override func rightButtonMethod() {
        saveDataToDevice()
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

    // MARK: - Private Helpers

    private var isCR: Bool { MKBXDConnectManager.shared.isCR }

    private func heightForRow(section: Int, row: Int) -> CGFloat {
        if section == 1 { return 130 }
        if section == 2 && row == 0 {
            if dataModel.slotType == .uid { return 120 }
            if dataModel.slotType == .beacon { return 160 }
            return 0
        }
        if section == 3 && row == 0 { return 180 }
        if section == 5 && row == 0 { return 95 }
        if section == 7 { return 60 }
        if section == 9 { return 180 }
        return 44
    }

    private func section10Need() -> Bool {
        if dataModel.alarmNotiType == 1 { return true }
        if isCR && (dataModel.alarmNotiType == 4 || dataModel.alarmNotiType == 5) { return true }
        if !isCR && dataModel.alarmNotiType == 3 { return true }
        return false
    }
    private func section11Need() -> Bool {
        if isCR && (dataModel.alarmNotiType == 2 || dataModel.alarmNotiType == 4) { return true }
        return false
    }
    private func section12Need() -> Bool {
        if isCR && (dataModel.alarmNotiType == 3 || dataModel.alarmNotiType == 5) { return true }
        if !isCR && (dataModel.alarmNotiType == 2 || dataModel.alarmNotiType == 3) { return true }
        return false
    }

    private func numberOfRows(section: Int) -> Int {
        if section == 0 { return section0List.count }
        if !dataModel.advIsOn { return 0 }
        if section == 1 { return section1List.count }
        if section == 2 { return dataModel.slotType == .alarmInfo ? 0 : section2List.count }
        if section == 3 { return section3List.count }
        if section == 4 { return dataModel.alarmMode ? section4List.count : 1 }
        if !dataModel.alarmMode { return 0 }
        if section == 5 { return pageType == .abnormal ? section5List.count : 0 }
        if section == 6 { return section6List.count }
        if section == 7 { return section7List.count }
        if section == 8 { return section8List.count }
        if dataModel.showTriggerType {
            if section == 9 { return section9List.count }
            if section == 10 { return section10Need() ? section10List.count : 0 }
            if section == 11 { return section11Need() ? section11List.count : 0 }
            if section == 12 { return section12Need() ? section12List.count : 0 }
        }
        return 0
    }

    private func heightForHeader(section: Int) -> CGFloat {
        if section == 0 { return 10 }
        if !dataModel.advIsOn { return 0 }
        if section == 1 || section == 2 || section == 3 || section == 4 || section == 8 { return 10 }
        if dataModel.alarmMode && dataModel.showTriggerType {
            if section == 10 { return section10Need() ? 25 : 0 }
            if section == 11 { return section11Need() ? 25 : 0 }
            if section == 12 { return section12Need() ? 25 : 0 }
        }
        return 0
    }

    // MARK: - Cell

    private func loadSection2Cell(row: Int) -> UITableViewCell {
        if dataModel.slotType == .uid {
            let cell = MKBXDSlotUIDCell.initCellWithTableView(tableView)
            if row < section2List.count, let model = section2List[row] as? MKBXDSlotUIDCellModel {
                cell.dataModel = model
            }
            cell.delegate = self
            return cell
        }
        if dataModel.slotType == .beacon {
            let cell = MKBXDSlotBeaconCell.initCellWithTableView(tableView)
            if row < section2List.count, let model = section2List[row] as? MKBXDSlotBeaconCellModel {
                cell.dataModel = model
            }
            cell.delegate = self
            return cell
        }
        return MKSwiftBaseCell(style: .default, reuseIdentifier: "MKBXDAlarmModeConfigV2ControllerCell")
    }

    private func loadCell(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = MKSwiftTextSwitchCell.initCellWithTableView(tableView)
            cell.dataModel = section0List[indexPath.row]
            cell.delegate = self
            return cell
        case 1:
            let cell = MKBXDSlotFramePickCell.initCellWithTableView(tableView)
            cell.dataModel = section1List[indexPath.row]
            cell.delegate = self
            return cell
        case 2:
            return loadSection2Cell(row: indexPath.row)
        case 3:
            let cell = MKBXDSlotParamCell.initCellWithTableView(tableView)
            cell.dataModel = section3List[indexPath.row]
            cell.delegate = self
            return cell
        case 4:
            let cell = MKSwiftTextSwitchCell.initCellWithTableView(tableView)
            cell.dataModel = section4List[indexPath.row]
            cell.delegate = self
            return cell
        case 5:
            let cell = MKBXDAbnormalInactivityTimeCell.initCellWithTableView(tableView)
            cell.dataModel = section5List[indexPath.row]
            cell.delegate = self
            return cell
        case 6:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section6List[indexPath.row]
            cell.delegate = self
            return cell
        case 7:
            let cell = MKBXDTxPowerCell.initCellWithTableView(tableView)
            cell.dataModel = section7List[indexPath.row]
            cell.delegate = self
            return cell
        case 8:
            let cell = MKBXDTriggerTypeClickCell.initCellWithTableView(tableView)
            cell.dataModel = section8List[indexPath.row]
            cell.delegate = self
            return cell
        case 9:
            let cell = MKBXDAlarmTypePickCell.initCellWithTableView(tableView)
            cell.dataModel = section9List[indexPath.row]
            cell.delegate = self
            return cell
        case 10:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section10List[indexPath.row]
            cell.delegate = self
            return cell
        case 11:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section11List[indexPath.row]
            cell.delegate = self
            return cell
        default:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section12List[indexPath.row]
            cell.delegate = self
            return cell
        }
    }

    // MARK: - Load Datas

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
        loadSection11Datas()
        loadSection12Datas()

        headerList = (0..<13).map { i in
            let model = MKSwiftTableSectionLineHeaderModel()
            if i == 10 { model.text = "LED notification" }
            else if i == 11 { model.text = "Vibration notification" }
            else if i == 12 { model.text = "Buzzer notification" }
            return model
        }
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
        loadSection11Datas()
        loadSection12Datas()

        if headerList.isEmpty {
            headerList = (0..<13).map { i in
                let model = MKSwiftTableSectionLineHeaderModel()
                if i == 10 { model.text = "LED notification" }
                else if i == 11 { model.text = "Vibration notification" }
                else if i == 12 { model.text = "Buzzer notification" }
                return model
            }
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
        let m = MKBXDSlotFramePickCellModel()
        m.frameType = dataModel.slotType
        section1List = [m]
    }

    private func loadSection2Datas() {
        section2List.removeAll()
        if dataModel.slotType == .uid {
            let m = MKBXDSlotUIDCellModel()
            m.namespaceID = dataModel.namespaceID
            m.instanceID = dataModel.instanceID
            section2List = [m]
        } else if dataModel.slotType == .beacon {
            let m = MKBXDSlotBeaconCellModel()
            m.major = dataModel.major
            m.minor = dataModel.minor
            m.uuid = dataModel.uuid
            section2List = [m]
        }
    }

    private func loadSection3Datas() {
        let m = MKBXDSlotParamCellModel()
        m.cellType = dataModel.slotType
        m.interval = dataModel.advInterval
        m.rssi = dataModel.rangingData
        m.txPower = dataModel.txPower
        section3List = [m]
    }

    private func loadSection4Datas() {
        let m1 = MKSwiftTextSwitchCellModel()
        m1.index = 1
        m1.msg = "Alarm mode"
        m1.isOn = dataModel.alarmMode

        let m2 = MKSwiftTextSwitchCellModel()
        m2.index = 2
        m2.msg = "Stay advertising before triggered"
        m2.isOn = dataModel.stayAdv

        section4List = [m1, m2]
    }

    private func loadSection5Datas() {
        let m = MKBXDAbnormalInactivityTimeCellModel()
        m.time = dataModel.abnormalTime
        m.advTime = dataModel.alarmMode_advTime
        section5List = [m]
    }

    private func loadSection6Datas() {
        let m1 = MKSwiftTextFieldCellModel()
        m1.index = 0
        m1.msg = "Advertising time"
        m1.textPlaceholder = "1~65535"
        m1.textFieldType = .realNumberOnly
        m1.textFieldValue = dataModel.alarmMode_advTime
        m1.maxLength = 5
        m1.unit = "s"

        let m2 = MKSwiftTextFieldCellModel()
        m2.index = 1
        m2.msg = "Adv interval"
        m2.textPlaceholder = "1~500"
        m2.textFieldType = .realNumberOnly
        m2.textFieldValue = dataModel.alarmMode_advInterval
        m2.maxLength = 3
        m2.unit = "x20ms"

        section6List = [m1, m2]
    }

    private func loadSection7Datas() {
        let m = MKBXDTxPowerCellModel()
        m.index = 0
        m.txPower = dataModel.alarmMode_txPower
        section7List = [m]
    }

    private func loadSection8Datas() {
        let m = MKBXDTriggerTypeClickCellModel()
        m.selected = dataModel.showTriggerType
        section8List = [m]
    }

    private func loadSection9Datas() {
        let m = MKBXDAlarmTypePickCellModel()
        m.triggerAlarmType = dataModel.alarmNotiType
        m.typeList = isCR
            ? ["Silent", "LED", "Vibration", "Buzzer", "LED+Vibration", "LED+Buzzer"]
            : ["Silent", "LED", "Buzzer", "LED+Buzzer"]
        section9List = [m]
    }

    private func loadSection10Datas() {
        let m1 = MKSwiftTextFieldCellModel()
        m1.index = 2
        m1.msg = "Blinking time"
        m1.textPlaceholder = "1~6000"
        m1.textFieldValue = dataModel.blinkingTime
        m1.textFieldType = .realNumberOnly
        m1.unit = "x100ms"
        m1.maxLength = 4

        let m2 = MKSwiftTextFieldCellModel()
        m2.index = 3
        m2.msg = "Blinking interval"
        m2.textPlaceholder = "0~100"
        m2.textFieldValue = dataModel.blinkingInterval
        m2.textFieldType = .realNumberOnly
        m2.unit = "x100ms"
        m2.maxLength = 3

        section10List = [m1, m2]
    }

    private func loadSection11Datas() {
        let m1 = MKSwiftTextFieldCellModel()
        m1.index = 4
        m1.msg = "Vibrating time"
        m1.textPlaceholder = "1~6000"
        m1.textFieldValue = dataModel.vibratingTime
        m1.textFieldType = .realNumberOnly
        m1.unit = "x100ms"
        m1.maxLength = 4

        let m2 = MKSwiftTextFieldCellModel()
        m2.index = 5
        m2.msg = "Vibrating interval"
        m2.textPlaceholder = "0~100"
        m2.textFieldValue = dataModel.vibratingInterval
        m2.textFieldType = .realNumberOnly
        m2.unit = "x100ms"
        m2.maxLength = 3

        section11List = [m1, m2]
    }

    private func loadSection12Datas() {
        let m1 = MKSwiftTextFieldCellModel()
        m1.index = 6
        m1.msg = "Ringing time"
        m1.textPlaceholder = "1~6000"
        m1.textFieldValue = dataModel.ringingTime
        m1.textFieldType = .realNumberOnly
        m1.unit = "x100ms"
        m1.maxLength = 4

        let m2 = MKSwiftTextFieldCellModel()
        m2.index = 7
        m2.msg = "Ringing interval"
        m2.textPlaceholder = "0~100"
        m2.textFieldValue = dataModel.ringingInterval
        m2.textFieldType = .realNumberOnly
        m2.unit = "x100ms"
        m2.maxLength = 3

        section12List = [m1, m2]
    }

    // MARK: - UI

    private func loadSubViews() {
        switch pageType {
        case .single:   defaultTitle = "Single press mode"
        case .double:   defaultTitle = "Double press mode"
        case .long:     defaultTitle = "Long press mode"
        case .abnormal: defaultTitle = "Abnormal inactivity mode"
        }
        setNavTitleFont(MKFont.font(15.0))
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

extension MKBXDAlarmModeConfigV2Controller: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { headerList.count }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows(section: section)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForRow(section: indexPath.section, row: indexPath.row)
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
        loadCell(indexPath: indexPath)
    }
}

// MARK: - MKSwiftTextSwitchCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKSwiftTextSwitchCellDelegate {
    public func MKSwiftTextSwitchCellStatusChanged(isOn: Bool, index: Int) {
        if index == 0 {
            dataModel.advIsOn = isOn
            if !section0List.isEmpty { section0List[0].isOn = isOn }
            tableView.reloadData()
            return
        }
        if index == 1 {
            dataModel.alarmMode = isOn
            if !section4List.isEmpty { section4List[0].isOn = isOn }
            tableView.reloadData()
            return
        }
        if index == 2 {
            dataModel.stayAdv = isOn
            if section4List.count > 1 { section4List[1].isOn = isOn }
        }
    }
}

// MARK: - MKSwiftTextFieldCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKSwiftTextFieldCellDelegate {

    public func mkDeviceTextCellValueChanged(_ index: Int, textValue: String) {
        if index == 0 {
            dataModel.alarmMode_advTime = textValue
            if !section6List.isEmpty { section6List[0].textFieldValue = textValue }
            if pageType == .abnormal, !section5List.isEmpty {
                section5List[0].advTime = textValue
                tableView.reloadSections(IndexSet(integer: 5), with: .none)
            }
            return
        }
        if index == 1 {
            dataModel.alarmMode_advInterval = textValue
            if section6List.count > 1 { section6List[1].textFieldValue = textValue }
            return
        }
        if index == 2 {
            dataModel.blinkingTime = textValue
            if !section10List.isEmpty { section10List[0].textFieldValue = textValue }
            return
        }
        if index == 3 {
            dataModel.blinkingInterval = textValue
            if section10List.count > 1 { section10List[1].textFieldValue = textValue }
            return
        }
        if index == 4 {
            dataModel.vibratingTime = textValue
            if !section11List.isEmpty { section11List[0].textFieldValue = textValue }
            return
        }
        if index == 5 {
            dataModel.vibratingInterval = textValue
            if section11List.count > 1 { section11List[1].textFieldValue = textValue }
            return
        }
        if index == 6 {
            dataModel.ringingTime = textValue
            if !section12List.isEmpty { section12List[0].textFieldValue = textValue }
            return
        }
        if index == 7 {
            dataModel.ringingInterval = textValue
            if section12List.count > 1 { section12List[1].textFieldValue = textValue }
        }
    }
}

// MARK: - MKBXDSlotFramePickCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKBXDSlotFramePickCellDelegate {

    public func bxd_slotFrameTypeChanged(_ frameType: MKBXDSlotType) {
        dataModel.slotType = frameType
        if !section1List.isEmpty { section1List[0].frameType = frameType }
        loadSection2Datas()
        tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }
}

// MARK: - MKBXDSlotBeaconCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKBXDSlotBeaconCellDelegate {

    public func bxd_advContent_majorChanged(_ major: String) {
        dataModel.major = major
        if let m = section2List.first as? MKBXDSlotBeaconCellModel { m.major = major }
    }
    public func bxd_advContent_minorChanged(_ minor: String) {
        dataModel.minor = minor
        if let m = section2List.first as? MKBXDSlotBeaconCellModel { m.minor = minor }
    }
    public func bxd_advContent_uuidChanged(_ uuid: String) {
        dataModel.uuid = uuid
        if let m = section2List.first as? MKBXDSlotBeaconCellModel { m.uuid = uuid }
    }
}

// MARK: - MKBXDSlotUIDCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKBXDSlotUIDCellDelegate {

    public func bxd_advContent_namespaceIDChanged(_ text: String) {
        dataModel.namespaceID = text
        if let m = section2List.first as? MKBXDSlotUIDCellModel { m.namespaceID = text }
    }
    public func bxd_advContent_instanceIDChanged(_ text: String) {
        dataModel.instanceID = text
        if let m = section2List.first as? MKBXDSlotUIDCellModel { m.instanceID = text }
    }
}

// MARK: - MKBXDSlotParamCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKBXDSlotParamCellDelegate {

    public func bxd_slotParam_advIntervalChanged(_ interval: String) {
        dataModel.advInterval = interval
        if !section3List.isEmpty { section3List[0].interval = interval }
    }
    public func bxd_slotParam_rssiChanged(_ rssi: Int) {
        dataModel.rangingData = rssi
        if !section3List.isEmpty { section3List[0].rssi = rssi }
    }
    public func bxd_slotParam_txPowerChanged(_ txPower: Int) {
        dataModel.txPower = txPower
        if !section3List.isEmpty { section3List[0].txPower = txPower }
    }
}

// MARK: - MKBXDAbnormalInactivityTimeCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKBXDAbnormalInactivityTimeCellDelegate {

    public func bxd_abnormalInactivityTimeChanged(_ time: String) {
        dataModel.abnormalTime = time
        if !section5List.isEmpty { section5List[0].time = time }
    }
}

// MARK: - MKBXDTxPowerCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKBXDTxPowerCellDelegate {

    public func bxd_txPowerChanged(_ index: Int, txPower: Int) {
        if index == 0 {
            dataModel.alarmMode_txPower = txPower
            if !section7List.isEmpty { section7List[0].txPower = txPower }
        }
    }
}

// MARK: - MKBXDTriggerTypeClickCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKBXDTriggerTypeClickCellDelegate {

    public func bxd_triggerTypeClickCell_pressed(_ selected: Bool) {
        dataModel.showTriggerType = selected
        if !section8List.isEmpty { section8List[0].selected = selected }
        let set = IndexSet(integersIn: 9..<13)
        tableView.reloadSections(set, with: .none)
    }
}

// MARK: - MKBXDAlarmTypePickCellDelegate

extension MKBXDAlarmModeConfigV2Controller: MKBXDAlarmTypePickCellDelegate {

    public func bxd_triggerAlarmTypeChanged(_ triggerAlarmType: Int) {
        dataModel.alarmNotiType = triggerAlarmType
        if !section9List.isEmpty { section9List[0].triggerAlarmType = triggerAlarmType }
        let set = IndexSet(integersIn: 10..<13)
        tableView.reloadSections(set, with: .none)
    }
}
