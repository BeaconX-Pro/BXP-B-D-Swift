//
//  MKBXDAlarmEventController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDAlarmEventController: MKSwiftBaseViewController {

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        if Int(MKBXDConnectManager.shared.deviceType) == 1 {
            tv.tableFooterView = makeTableFooterView()
        }
        return tv
    }()

    private lazy var dataList: [MKBXDAlarmEventCountCellModel] = []

    private let dataModel = MKBXDAlarmEventModel()

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

    private func loadSectionDatas() {
        let m1 = MKBXDAlarmEventCountCellModel()
        m1.index = 0
        m1.msg = "Single press event count"
        m1.count = dataModel.singleCount

        let m2 = MKBXDAlarmEventCountCellModel()
        m2.index = 1
        m2.msg = "Double press event count"
        m2.count = dataModel.doubleCount

        let m3 = MKBXDAlarmEventCountCellModel()
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

    private func makeTableFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: 80))
        footerView.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)

        let noteMsg = "*The Alarm Count here mainly refers to the button press count in Advertising Mode under non-connected status."
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
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDAlarmEventController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int { 1 }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { dataList.count }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 90 }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MKBXDAlarmEventCountCell.initCellWithTableView(tableView)
        cell.dataModel = dataList[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - MKBXDAlarmEventCountCellDelegate

extension MKBXDAlarmEventController: MKBXDAlarmEventCountCellDelegate {

    public func bxd_alarmEvent_clearButtonPressed(_ index: Int) {
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
        default: break
        }
    }
}
