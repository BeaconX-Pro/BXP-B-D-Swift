//
//  MKBXDAlarmController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDAlarmController: MKSwiftBaseViewController {

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

    private let dataModel = MKBXDAlarmPageModel()

    // MARK: - Lifecycle

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readDatasFromDevice()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        loadSectionDatas()
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

    // MARK: - Load Datas

    private func loadSectionDatas() {
        loadSection0List()
        loadSection1List()
        tableView.reloadData()
    }

    private func loadSection0List() {
        let m1 = MKSwiftNormalTextCellModel()
        m1.leftMsg = "Single press mode"

        let m2 = MKSwiftNormalTextCellModel()
        m2.leftMsg = "Double press mode"

        let m3 = MKSwiftNormalTextCellModel()
        m3.leftMsg = "Long press mode"

        section0List = [m1, m2, m3]
    }

    private func loadSection1List() {
        let m = MKSwiftNormalTextCellModel()
        m.leftMsg = "Abnormal inactivity mode"
        section1List = [m]
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

extension MKBXDAlarmController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { 2 }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return section0List.count }
        if section == 1 {
            return MKBXDConnectManager.shared.threeSensor ? section1List.count : 0
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MKBXDAlarmModeConfigController()
        if indexPath.section == 1 {
            vc.pageType = .abnormal
        } else {
            vc.pageType = MKBXDAlarmModeConfigControllerType(rawValue: indexPath.row) ?? .single
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
        if indexPath.section == 0 {
            cell.dataModel = section0List[indexPath.row]
        } else {
            cell.dataModel = section1List[indexPath.row]
        }
        return cell
    }
}
