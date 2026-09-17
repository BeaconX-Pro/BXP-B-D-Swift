//
//  MKBXDAlarmEventDBController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDAlarmEventDBController: MKSwiftBaseViewController {

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

    private lazy var dataList: [MKBXDAlarmEventDBCountCellModel] = []

    private let dataModel = MKBXDAlarmEventDBDataModel()

    deinit {
        print("MKBXDAlarmEventDBController销毁")
    }

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
        let m1 = MKBXDAlarmEventDBCountCellModel()
        m1.index = 0
        m1.msg = "Single press count"
        m1.mainCount = dataModel.singleMainCount
        m1.subCount = dataModel.singleSubCount

        let m2 = MKBXDAlarmEventDBCountCellModel()
        m2.index = 1
        m2.msg = "Double press count"
        m2.mainCount = dataModel.doubleMainCount
        m2.subCount = dataModel.doubleSubCount

        let m3 = MKBXDAlarmEventDBCountCellModel()
        m3.index = 2
        m3.msg = "Long press count"
        m3.mainCount = dataModel.longMainCount
        m3.subCount = dataModel.longSubCount

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

    private func showErrorToast(_ error: Error) {
        view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDAlarmEventDBController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int { 1 }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { dataList.count }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 130 }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MKBXDAlarmEventDBCountCell.initCellWithTableView(tableView)
        cell.dataModel = dataList[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - MKBXDAlarmEventDBCountCellDelegate

extension MKBXDAlarmEventDBController: MKBXDAlarmEventDBCountCellDelegate {

    public func bxd_alarmEventDBCell_mainClearButtonPressed(_ index: Int) {
        MKSwiftHudManager.shared.showHUD(with: "Loading...", in: view, isPenetration: false)
        switch index {
        case 0:
            // 单击（主按键）
            MKBXDInterface.bxd_clearSinglePressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.singleMainCount = "0"
                self.dataList[0].mainCount = self.dataModel.singleMainCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.showErrorToast(error)
            })
        case 1:
            // 双击（主按键）
            MKBXDInterface.bxd_clearDoublePressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.doubleMainCount = "0"
                self.dataList[1].mainCount = self.dataModel.doubleMainCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.showErrorToast(error)
            })
        case 2:
            // 长按（主按键）
            MKBXDInterface.bxd_clearLongPressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.longMainCount = "0"
                self.dataList[2].mainCount = self.dataModel.longMainCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.showErrorToast(error)
            })
        default:
            break
        }
    }

    public func bxd_alarmEventDBCell_subClearButtonPressed(_ index: Int) {
        MKSwiftHudManager.shared.showHUD(with: "Loading...", in: view, isPenetration: false)
        switch index {
        case 0:
            // 单击（副按键）
            MKBXDInterface.bxd_clearSubButtonSinglePressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.singleSubCount = "0"
                self.dataList[0].subCount = self.dataModel.singleSubCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.showErrorToast(error)
            })
        case 1:
            // 双击（副按键）
            MKBXDInterface.bxd_clearSubButtonDoublePressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.doubleSubCount = "0"
                self.dataList[1].subCount = self.dataModel.doubleSubCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.showErrorToast(error)
            })
        case 2:
            // 长按（副按键）
            MKBXDInterface.bxd_clearSubButtonLongPressEventData(sucBlock: { [weak self] in
                guard let self = self else { return }
                MKSwiftHudManager.shared.hide()
                self.dataModel.longSubCount = "0"
                self.dataList[2].subCount = self.dataModel.longSubCount
                MKBXDExcelManager.deleteDataList(sucBlock: nil, failedBlock: nil)
                self.tableView.reloadData()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.showErrorToast(error)
            })
        default:
            break
        }
    }
}
