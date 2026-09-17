//
//  MKBXDPowerSaveController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDPowerSaveController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
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
    private lazy var section1List: [MKBXDPowerSaveTriggerTimeCellModel] = []

    private let dataModel = MKBXDPowerSaveModel()

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
            MKSwiftHudManager.shared.hide()
            self?.reloadSectionDatas()
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

    // MARK: - Load Section Datas

    private func loadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        tableView.reloadData()
    }

    private func reloadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        tableView.reloadData()
    }

    private func loadSection0Datas() {
        let m = MKSwiftTextSwitchCellModel()
        m.index = 0
        m.msg = "Power saving mode"
        m.isOn = dataModel.isOn
        section0List = [m]
    }

    private func loadSection1Datas() {
        let m = MKBXDPowerSaveTriggerTimeCellModel()
        m.time = dataModel.triggerTime
        section1List = [m]
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "Power saving configuration"
        setNavTitleFont(MKFont.font(14.0))
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

extension MKBXDPowerSaveController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { 2 }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return section0List.count }
        if section == 1 { return dataModel.isOn ? section1List.count : 0 }
        return 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            // ✅ 动态计算（根据 note 文案长度）
            if indexPath.row < section1List.count {
                return section1List[indexPath.row].cellHeight()
            }
            return 60
        }
        return 44
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = MKSwiftTextSwitchCell.initCellWithTableView(tableView)
            cell.dataModel = section0List[indexPath.row]
            cell.delegate = self
            return cell
        }
        let cell = MKBXDPowerSaveTriggerTimeCell.initCellWithTableView(tableView)
        cell.dataModel = section1List[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - MKSwiftTextSwitchCellDelegate

extension MKBXDPowerSaveController: MKSwiftTextSwitchCellDelegate {
    public func MKSwiftTextSwitchCellStatusChanged(isOn: Bool, index: Int) {
        if index == 0 {
            dataModel.isOn = isOn
            if !section0List.isEmpty { section0List[0].isOn = isOn }
            tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
}

// MARK: - MKBXDPowerSaveTriggerTimeCellDelegate

extension MKBXDPowerSaveController: MKBXDPowerSaveTriggerTimeCellDelegate {

    public func bxd_powerSaveTriggerTimeChanged(_ time: String) {
        dataModel.triggerTime = time
        if !section1List.isEmpty { section1List[0].time = time }
        // ✅ 文案变化后，需要刷新该行高度
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
