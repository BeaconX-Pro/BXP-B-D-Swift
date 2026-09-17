//
//  MKBXDAlarmEventCRController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDAlarmEventCRController: MKSwiftBaseViewController {

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        tv.tableFooterView = makeTableFooterView()
        tv.tableHeaderView = tableHeaderView
        return tv
    }()

    private lazy var tableHeaderView: MKBXDAlarmSyncTimeView = {
        let view = MKBXDAlarmSyncTimeView(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: 90))
        view.delegate = self
        return view
    }()

    private lazy var dataList: [MKBXDAlarmEventCRModeCellModel] = []
    private lazy var headerList: [MKSwiftTableSectionLineHeaderModel] = []

    private let dataModel = MKBXDAlarmEventCRModel()

    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        return f
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        readDatasFromDevice()
    }

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

    private func readTimestamp() {
        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        MKBXDInterface.bxd_readDeviceTimestamp(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            let ts = Int64((result["timestamp"] as? String) ?? "0") ?? 0
            let date = Date(timeIntervalSince1970: TimeInterval(ts) / 1000.0)
            self.dataModel.timestamp = self.dateFormatter.string(from: date)
            self.tableHeaderView.updateTimestamp(self.dataModel.timestamp)
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func loadSectionDatas() {
        tableHeaderView.updateTimestamp(dataModel.timestamp)

        let headerModel = MKSwiftTableSectionLineHeaderModel()
        headerModel.text = "Advertising Mode"
        headerList = [headerModel]

        let m1 = MKBXDAlarmEventCRModeCellModel()
        m1.index = 0
        m1.msg = "Single press event count"
        m1.count = dataModel.singleCount

        let m2 = MKBXDAlarmEventCRModeCellModel()
        m2.index = 1
        m2.msg = "Double press event count"
        m2.count = dataModel.doubleCount

        let m3 = MKBXDAlarmEventCRModeCellModel()
        m3.index = 2
        m3.msg = "Long press event count"
        m3.count = dataModel.longCount

        dataList = [m1, m2, m3]
        tableView.reloadData()
    }

    private func loadSubViews() {
        defaultTitle = "Alarm event"
        view.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-MKLayout.safeAreaBottom)
        }
    }

    @objc private func longConnectionExport() {
        let vc = MKBXDExportEventDataController()
        vc.vcType = .connectionMode
        navigationController?.pushViewController(vc, animated: true)
    }

    private func makeTableFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: 80))
        footerView.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)

        let msgLabel = UILabel(frame: CGRect(x: 15, y: 10, width: MKScreen.width - 30, height: MKFont.font(15).lineHeight))
        msgLabel.textColor = MKColor.defaultText
        msgLabel.textAlignment = .left
        msgLabel.font = MKFont.font(15)
        msgLabel.text = "Long Connection Mode"
        footerView.addSubview(msgLabel)

        let alarmLabel = UILabel(frame: CGRect(x: 15, y: 10 + MKFont.font(15).lineHeight + 25, width: 130, height: MKFont.font(13).lineHeight))
        alarmLabel.textColor = MKColor.defaultText
        alarmLabel.textAlignment = .left
        alarmLabel.font = MKFont.font(15)
        alarmLabel.text = "Alarm event"
        footerView.addSubview(alarmLabel)

        let exportBtn = MKSwiftUIAdaptor.createRoundedButton(title: "Export",
                                                             target: self,
                                                             action: #selector(longConnectionExport))
        exportBtn.titleLabel?.font = MKFont.font(13)
        exportBtn.frame = CGRect(x: MKScreen.width - 15 - 60,
                                 y: 10 + MKFont.font(15).lineHeight + 10,
                                 width: 60,
                                 height: 35)
        footerView.addSubview(exportBtn)

        return footerView
    }
}

// MARK: - UITableView

extension MKBXDAlarmEventCRController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int { headerList.count }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? dataList.count : 0
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 90 }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 25 }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MKSwiftTableSectionLineHeader.dequeueHeader(with: tableView)
        if section < headerList.count { header.headerModel = headerList[section] }
        return header
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MKBXDAlarmEventCRModeCell.initCellWithTableView(tableView)
        cell.dataModel = dataList[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - MKBXDAlarmSyncTimeViewDelegate

extension MKBXDAlarmEventCRController: MKBXDAlarmSyncTimeViewDelegate {
    public func bxd_alarmSyncTimeButtonPressed() {
        let timeInterval = Date().timeIntervalSince1970
        let milliseconds = Int64(timeInterval * 1000)
        MKSwiftHudManager.shared.showHUD(with: "Sync...", in: view, isPenetration: false)
        MKBXDInterface.bxd_configDeviceTimestamp(milliseconds, sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.readTimestamp()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }
}

// MARK: - MKBXDAlarmEventCRModeCellDelegate

extension MKBXDAlarmEventCRController: MKBXDAlarmEventCRModeCellDelegate {
    public func bxd_alarmEventCRModeCell_clearBtnPressed(_ index: Int) {
        MKSwiftHudManager.shared.showHUD(with: "Loading...", in: view, isPenetration: false)
        switch index {
        case 0:
            MKBXDInterface.bxd_clearSinglePressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.singleCount = "0"
                self.dataList[0].count = self.dataModel.singleCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            })
        case 1:
            MKBXDInterface.bxd_clearDoublePressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.doubleCount = "0"
                self.dataList[1].count = self.dataModel.doubleCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            })
        case 2:
            MKBXDInterface.bxd_clearLongPressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.longCount = "0"
                self.dataList[2].count = self.dataModel.longCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            })
        default:
            break
        }
    }

    public func bxd_alarmEventCRModeCell_exportBtnPressed(_ index: Int) {
        let vc = MKBXDExportEventDataController()
        vc.vcType = index == 0 ? .single : (index == 1 ? .double : .long)
        navigationController?.pushViewController(vc, animated: true)
    }
}
