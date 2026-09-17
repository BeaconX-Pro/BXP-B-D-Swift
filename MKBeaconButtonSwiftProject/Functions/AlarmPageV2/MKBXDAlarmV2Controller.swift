//
//  MKBXDAlarmV2Controller.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDAlarmV2Controller: MKSwiftBaseViewController {

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
    private lazy var section2List: [MKBXDAlarmMsgCellModel] = []
    private lazy var section3List: [Any] = []
    private lazy var section4List: [MKSwiftNormalTextCellModel] = []
    private lazy var section5List: [MKBXDAlarmMsgCellModel] = []
    private lazy var headerList: [MKSwiftTableSectionLineHeaderModel] = []

    private let dataModel = MKBXDAlarmV2Model()

    // MARK: - Lifecycle

    deinit {
        _ = MKBXDCentralManager.shared.notifyLongConModeData(false)
        if MKBXDConnectManager.shared.doubleBtn {
            _ = MKBXDCentralManager.shared.notifySubClickData(false)
        }
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readDatasFromDevice()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        loadSectionDatas()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveLongConModeData(_:)),
                                               name: .mk_bxd_receiveLongConnectionModeDataNotification,
                                               object: nil)
        _ = MKBXDCentralManager.shared.notifyLongConModeData(true)

        if MKBXDConnectManager.shared.doubleBtn {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(receiveSubClickData(_:)),
                                                   name: .mk_bxd_receiveSubClickDataNotification,
                                                   object: nil)
            _ = MKBXDCentralManager.shared.notifySubClickData(true)
        }
    }

    public override func leftButtonMethod() {
        NotificationCenter.default.post(name: Notification.Name("mk_bxd_popToRootViewControllerNotification"), object: nil)
    }

    // MARK: - Read

    private func readDatasFromDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        dataModel.readData(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.updateCellValue()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func updateCellValue() {
        if section0List.count >= 3 {
            section0List[0].rightMsg = dataModel.singleIsOn ? "ON" : "OFF"
            section0List[1].rightMsg = dataModel.doubleIsOn ? "ON" : "OFF"
            section0List[2].rightMsg = dataModel.longIsOn ? "ON" : "OFF"
        }
        if !section1List.isEmpty {
            section1List[0].rightMsg = dataModel.inactivityIsOn ? "ON" : "OFF"
        }
        tableView.reloadData()
    }

    private func dismissAlarm() {
        MKSwiftHudManager.shared.showHUD(with: "Waiting...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configDismissAlarm(sucBlock: {
            MKSwiftHudManager.shared.hide()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Notification

    @objc private func receiveLongConModeData(_ note: Notification) {
        guard let dic = note.userInfo as? [String: Any] else { return }
        let count = (dic["count"] as? String) ?? "0"

        if MKBXDConnectManager.shared.doubleBtn {
            if let m = section3List.first as? MKBXDAlarmV2EventCellModel {
                m.mainCount = count
            }
        } else {
            if let m = section3List.first as? MKBXDAlarmEventCellModel {
                m.count = count
            }
        }
        tableView.reloadSections(IndexSet(integer: 3), with: .none)
    }

    @objc private func receiveSubClickData(_ note: Notification) {
        guard let dic = note.userInfo as? [String: Any] else { return }
        let count = (dic["count"] as? String) ?? "0"
        if let m = section3List.first as? MKBXDAlarmV2EventCellModel {
            m.subCount = count
        }
        tableView.reloadSections(IndexSet(integer: 3), with: .none)
    }

    // MARK: - Load Datas

    private func loadSectionDatas() {
        loadSection0List()
        loadSection1List()
        loadSection2List()
        loadSection3List()
        loadSection4List()
        loadSection5List()

        headerList = (0..<6).map { i in
            let m = MKSwiftTableSectionLineHeaderModel()
            if i == 0 { m.text = "Advertising Mode" }
            return m
        }
        tableView.reloadData()
    }

    private func loadSection0List() {
        let m1 = MKSwiftNormalTextCellModel()
        m1.leftMsg = "Single press mode"
        m1.showRightIcon = true

        let m2 = MKSwiftNormalTextCellModel()
        m2.leftMsg = "Double press mode"
        m2.showRightIcon = true

        let m3 = MKSwiftNormalTextCellModel()
        m3.leftMsg = "Long press mode"
        m3.showRightIcon = true

        section0List = [m1, m2, m3]
    }

    private func loadSection1List() {
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Abnormal inactivity mode"
        m.showRightIcon = true
        section1List = [m]
    }

    private func loadSection2List() {
        let m = MKBXDAlarmMsgCellModel()
        m.msg = "*Advertising mode mainly refers to the configuration of channel parameters for broadcasting in a non-connected state and the parameter settings related to alarm events, which are different from the parameters in long connection mode."
        section2List = [m]
    }

    private func loadSection3List() {
        if MKBXDConnectManager.shared.doubleBtn {
            let m = MKBXDAlarmV2EventCellModel()
            m.mainCount = "0"
            m.subCount = "0"
            section3List = [m]
        } else {
            let m = MKBXDAlarmEventCellModel()
            m.count = "0"
            section3List = [m]
        }
    }

    private func loadSection4List() {
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Alarm Type Setting"
        m.showRightIcon = true
        section4List = [m]
    }

    private func loadSection5List() {
        let m = MKBXDAlarmMsgCellModel()
        m.msg = "*Long connection mode mainly refers to the parameter settings related to alarm events and event monitoring display in a long connection state. To ensure the beacon can be connected, you need to make sure that at least one slot is enabled in Advertising Mode setting, allowing the device to continue broadcasting while in a non-connected state"
        section5List = [m]
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "ALARM"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-(MKLayout.safeAreaBottom + 49))
        }
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDAlarmV2Controller: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { headerList.count }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return section0List.count }
        if section == 1 { return MKBXDConnectManager.shared.threeSensor ? section1List.count : 0 }
        if section == 2 { return section2List.count }
        if section == 3 { return section3List.count }
        if section == 4 { return section4List.count }
        if section == 5 { return section5List.count }
        return 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            // section2List 已经是 [MKBXDAlarmMsgCellModel]，直接访问
            let m = section2List[indexPath.row]
            return m.fetchCellHeight()
        }
        if indexPath.section == 3 {
            return MKBXDConnectManager.shared.doubleBtn ? 110 : 80
        }
        if indexPath.section == 5 {
            let m = section5List[indexPath.row]
            return m.fetchCellHeight()
        }
        return 44
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 3 { return 25 }
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
        if indexPath.section == 0 {
            let vc = MKBXDAlarmModeConfigV2Controller()
            vc.pageType = MKBXDAlarmModeConfigV2ControllerType(rawValue: indexPath.row) ?? .single
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        if indexPath.section == 1 {
            let vc = MKBXDAlarmModeConfigV2Controller()
            vc.pageType = .abnormal
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        if indexPath.section == 4 {
            let vc = MKBXDAlarmNotiTypeController()
            vc.pageType = .longConnMode
            navigationController?.pushViewController(vc, animated: true)
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
            let cell = MKBXDAlarmMsgCell.initCellWithTableView(tableView)
            cell.dataModel = section2List[indexPath.row]
            return cell
        case 3:
            if MKBXDConnectManager.shared.doubleBtn {
                let cell = MKBXDAlarmV2EventCell.initCellWithTableView(tableView)
                if let m = section3List[indexPath.row] as? MKBXDAlarmV2EventCellModel {
                    cell.dataModel = m
                }
                cell.delegate = self
                return cell
            }
            let cell = MKBXDAlarmEventCell.initCellWithTableView(tableView)
            if let m = section3List[indexPath.row] as? MKBXDAlarmEventCellModel {
                cell.dataModel = m
            }
            cell.delegate = self
            return cell
        case 4:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section4List[indexPath.row]
            return cell
        default:
            let cell = MKBXDAlarmMsgCell.initCellWithTableView(tableView)
            cell.dataModel = section5List[indexPath.row]
            return cell
        }
    }
}

// MARK: - MKBXDAlarmEventCellDelegate

extension MKBXDAlarmV2Controller: MKBXDAlarmEventCellDelegate {

    public func bxd_alarmEventCell_clearButtonPressed() {
        dismissAlarm()
    }
}

// MARK: - MKBXDAlarmV2EventCellDelegate

extension MKBXDAlarmV2Controller: MKBXDAlarmV2EventCellDelegate {

    public func bxd_alarmV2EventCell_clearButtonPressed() {
        dismissAlarm()
    }
}
