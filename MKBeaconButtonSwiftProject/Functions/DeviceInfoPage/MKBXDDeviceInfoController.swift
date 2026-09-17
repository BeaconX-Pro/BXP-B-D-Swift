//
//  MKBXDDeviceInfoController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDDeviceInfoController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    // MARK: - Data

    private lazy var dataList: [MKSwiftNormalTextCellModel] = []
    private let dataModel = MKBXDDeviceInfoModel()

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        readDatasFromDevice()
    }

    // MARK: - Read

    private func readDatasFromDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        dataModel.readData(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.loadSectionDatas()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    // MARK: - Load Section Datas

    private func loadSectionDatas() {
        var list: [MKSwiftNormalTextCellModel] = []

        let m1 = MKSwiftNormalTextCellModel()
        m1.leftMsg = "Battery voltage"
        m1.rightMsg = dataModel.voltage + "mV"
        list.append(m1)

        if Int(MKBXDConnectManager.shared.deviceType) == 1 {
            // 新固件
            let m = MKSwiftNormalTextCellModel()
            m.leftMsg = "Battery Percentage"
            m.rightMsg = dataModel.batteryPercent + "%"
            list.append(m)
        }

        let m2 = MKSwiftNormalTextCellModel()
        m2.leftMsg = "MAC address"
        m2.rightMsg = dataModel.macAddress
        list.append(m2)

        let m3 = MKSwiftNormalTextCellModel()
        m3.leftMsg = "Product model"
        m3.rightMsg = dataModel.productMode
        list.append(m3)

        let m4 = MKSwiftNormalTextCellModel()
        m4.leftMsg = "Software version"
        m4.rightMsg = dataModel.software
        list.append(m4)

        let m5 = MKSwiftNormalTextCellModel()
        m5.leftMsg = "Firmware version"
        m5.rightMsg = dataModel.firmware
        list.append(m5)

        let m6 = MKSwiftNormalTextCellModel()
        m6.leftMsg = "Hardware version"
        m6.rightMsg = dataModel.hardware
        list.append(m6)

        let m7 = MKSwiftNormalTextCellModel()
        m7.leftMsg = "Manufacture date"
        m7.rightMsg = dataModel.manuDate
        list.append(m7)

        let m8 = MKSwiftNormalTextCellModel()
        m8.leftMsg = "Manufacturer"
        m8.rightMsg = dataModel.manu
        list.append(m8)

        dataList = list
        tableView.reloadData()
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "Device info"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-MKLayout.safeAreaBottom)
        }
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDDeviceInfoController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { 1 }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
        cell.dataModel = dataList[indexPath.row]
        return cell
    }
}
