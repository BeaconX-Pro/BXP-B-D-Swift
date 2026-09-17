//
//  MKBXDDismissConfigController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDDismissConfigController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        tv.tableHeaderView = headerView
        tv.separatorStyle = .none                   // ✅ 跟 SensorAdvancedController 一致
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0          // ✅ 跟 SensorAdvancedController 一致
        }
        if Int(MKBXDConnectManager.shared.deviceType) == 1 {
            tv.tableFooterView = makeTableFooterView()
        }
        return tv
    }()

    private lazy var headerView: MKBXDNotificationTypePickerView = {
        let view = MKBXDNotificationTypePickerView(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: 200))
        view.delegate = self
        view.dataModel = headerViewModel
        return view
    }()

    private lazy var headerViewModel: MKBXDNotificationTypePickerViewModel = {
        let m = MKBXDNotificationTypePickerViewModel()
        m.needButton = true
        m.msg = "Dismiss alarm"
        m.buttonTitle = "Dismiss"
        m.typeLabelMsg = "Dismiss alarm notification type"
        m.typeList = MKBXDConnectManager.shared.isCR
            ? ["Silent", "LED", "Vibration", "Buzzer", "LED+Vibration", "LED+Buzzer"]
            : ["Silent", "LED", "Buzzer", "LED+Buzzer"]
        return m
    }()

    // MARK: - Data

    private lazy var section0List: [MKSwiftNormalTextCellModel] = []
    private lazy var section1List: [MKSwiftTextFieldCellModel] = []
    private lazy var section2List: [MKSwiftNormalTextCellModel] = []
    private lazy var section3List: [MKSwiftTextFieldCellModel] = []
    private lazy var section4List: [MKSwiftNormalTextCellModel] = []
    private lazy var section5List: [MKSwiftTextFieldCellModel] = []
    private lazy var headerList: [MKSwiftTableSectionLineHeaderModel] = []

    private let dataModel = MKBXDDismissConfigModel()

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        loadSectionDatas()              // ✅ 先加载 section 数据
        readDataFromDevice()            // ✅ 再读设备数据
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
            self.reloadSectionDatas()
            self.headerView.updateNotificationType(self.dataModel.dismissAlarmNotiType)
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

    // MARK: - Private Helpers

    private var isCR: Bool { MKBXDConnectManager.shared.isCR }

    private func numberOfRows(section: Int) -> Int {
        if section == 0 || section == 1 {
            var need = false
            if dataModel.dismissAlarmNotiType == 1 { need = true }
            else if isCR && (dataModel.dismissAlarmNotiType == 4 || dataModel.dismissAlarmNotiType == 5) { need = true }
            else if !isCR && dataModel.dismissAlarmNotiType == 3 { need = true }
            if section == 0 { return need ? section0List.count : 0 }
            return need ? section1List.count : 0
        }
        if section == 2 || section == 3 {
            var need = false
            if isCR && (dataModel.dismissAlarmNotiType == 2 || dataModel.dismissAlarmNotiType == 4) { need = true }
            if section == 2 { return need ? section2List.count : 0 }
            return need ? section3List.count : 0
        }
        if section == 4 || section == 5 {
            var need = false
            if isCR && (dataModel.dismissAlarmNotiType == 3 || dataModel.dismissAlarmNotiType == 5) { need = true }
            else if !isCR && (dataModel.dismissAlarmNotiType == 2 || dataModel.dismissAlarmNotiType == 3) { need = true }
            if section == 4 { return need ? section4List.count : 0 }
            return need ? section5List.count : 0
        }
        return 0
    }

    /// ✅ 动态返回 header 高度：section 不显示时返回 0
    private func heightForHeader(section: Int) -> CGFloat {
        if section == 0 {
            var need = false
            if dataModel.dismissAlarmNotiType == 1 { need = true }
            else if isCR && (dataModel.dismissAlarmNotiType == 4 || dataModel.dismissAlarmNotiType == 5) { need = true }
            else if !isCR && dataModel.dismissAlarmNotiType == 3 { need = true }
            return need ? 10 : 0
        }
        if section == 2 {
            var need = false
            if isCR && (dataModel.dismissAlarmNotiType == 2 || dataModel.dismissAlarmNotiType == 4) { need = true }
            return need ? 10 : 0
        }
        if section == 4 {
            var need = false
            if isCR && (dataModel.dismissAlarmNotiType == 3 || dataModel.dismissAlarmNotiType == 5) { need = true }
            else if !isCR && (dataModel.dismissAlarmNotiType == 2 || dataModel.dismissAlarmNotiType == 3) { need = true }
            return need ? 10 : 0
        }
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
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "LED notification"
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
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Vibration notification"
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
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Buzzer notification"
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

    // MARK: - Footer

    private func makeTableFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: 80))
        footerView.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)

        let noteMsg = "*The  Dismiss alarm notification here mainly refers to the dismiss alarm notification setting in Advertising Mode under non-connected status."
        let noteSize = noteMsg.size(withFont: MKFont.font(12),
                                    maxSize: CGSize(width: MKScreen.width - 30, height: .greatestFiniteMagnitude))
        let noteLabel = UILabel(frame: CGRect(x: 15, y: 10, width: MKScreen.width - 30, height: noteSize.height))
        noteLabel.textColor = UIColor(red: 118/255.0, green: 118/255.0, blue: 118/255.0, alpha: 1)
        noteLabel.textAlignment = .left
        noteLabel.font = MKFont.font(12)
        noteLabel.text = noteMsg
        noteLabel.numberOfLines = 0
        footerView.addSubview(noteLabel)

        return footerView
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "Dismiss alarm configuration"
        setNavTitleFont(MKFont.font(13))
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

extension MKBXDDismissConfigController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { headerList.count }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows(section: section)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    /// ✅ 动态返回 header 高度
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeader(section: section)
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
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section0List[indexPath.row]
            return cell
        case 1:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section1List[indexPath.row]
            cell.delegate = self
            return cell
        case 2:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section2List[indexPath.row]
            return cell
        case 3:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section3List[indexPath.row]
            cell.delegate = self
            return cell
        case 4:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section4List[indexPath.row]
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

extension MKBXDDismissConfigController: MKSwiftTextFieldCellDelegate {

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

// MARK: - MKBXDNotificationTypePickerViewDelegate

extension MKBXDDismissConfigController: MKBXDNotificationTypePickerViewDelegate {

    public func bxd_notiTypePickerViewTypeChanged(_ type: Int) {
        dataModel.dismissAlarmNotiType = type
        tableView.reloadData()
    }

    public func bxd_notiTypePickerViewButtonPressed() {
        MKSwiftHudManager.shared.showHUD(with: "Config...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configDismissAlarm(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }
}
