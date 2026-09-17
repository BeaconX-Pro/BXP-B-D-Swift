//
//  MKBXDAccelerationController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDAccelerationController: MKSwiftBaseViewController {

    private lazy var headerView: MKBXDAccelerationHeaderView = {
        let header = MKBXDAccelerationHeaderView(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: 55))
        header.delegate = self
        return header
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        tv.delegate = self
        tv.dataSource = self
        tv.tableHeaderView = makeTableHeaderView()
        return tv
    }()

    private lazy var section0List: [MKSwiftNormalTextCellModel] = []
    private lazy var section1List: [MKSwiftTextButtonCellModel] = []
    private lazy var section2List: [MKSwiftTextFieldCellModel] = []

    private let dataModel = MKBXDAccelerationModel()

    deinit {
        _ = MKBXDCentralManager.shared.notifyThreeAxisData(false)
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        readDataFromDevice()
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(receiveAxisDatas(_:)),
                                              name: .mk_bxd_receiveThreeAxisDataNotification,
                                              object: nil)
    }

    // MARK: - Save

    public override func rightButtonMethod() {
        MKSwiftHudManager.shared.showHUD(with: "Config...", in: view, isPenetration: false)
        dataModel.config(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast("Success")
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    @objc private func receiveAxisDatas(_ note: Notification) {
        guard let dic = note.userInfo as? [String: Any] else { return }
        let x = (dic["x-Data"] as? String) ?? "N/A"
        let y = (dic["y-Data"] as? String) ?? "N/A"
        let z = (dic["z-Data"] as? String) ?? "N/A"
        headerView.updateData(xData: x, yData: y, zData: z)
    }

    private func readDataFromDevice() {
        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        dataModel.read(sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.loadSectionDatas()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }

    private func loadSectionDatas() {
        loadSection0Datas()
        loadSection1Datas()
        loadSection2Datas()
        updateMotionThresholdUnit()
        tableView.reloadData()
    }

    private func loadSection0Datas() {
        let model = MKSwiftNormalTextCellModel()
        model.leftMsg = "Sensor parameters"
        section0List = [model]
    }

    private func loadSection1Datas() {
        let model1 = MKSwiftTextButtonCellModel()
        model1.index = 0
        model1.msg = "Full-scale"
        model1.dataList = ["±2g", "±4g", "±8g", "±16g"]
        model1.dataListIndex = dataModel.scale

        let model2 = MKSwiftTextButtonCellModel()
        model2.index = 1
        model2.msg = "Sampling rate"
        model2.dataList = ["1hz", "10hz", "25hz", "50hz", "100hz"]
        model2.dataListIndex = dataModel.samplingRate

        section1List = [model1, model2]
    }

    private func loadSection2Datas() {
        let model = MKSwiftTextFieldCellModel()
        model.index = 0
        model.msg = "Motion threshold"
        model.textFieldValue = dataModel.threshold
        model.textPlaceholder = "1 ~ 2048"
        model.textFieldType = .realNumberOnly
        model.maxLength = 4
        section2List = [model]
    }

    private func updateMotionThresholdUnit() {
        guard !section2List.isEmpty else { return }
        let model = section2List[0]
        switch dataModel.scale {
        case 0: model.unit = "x 1mg"
        case 1: model.unit = "x 2mg"
        case 2: model.unit = "x 4mg"
        case 3: model.unit = "x 12mg"
        default: break
        }
    }

    private func loadSubViews() {
        defaultTitle = "3-axis accelerometer"
        rightButton.setImage(UIImage(named: "bxd_slotSaveIcon.png"), for: .normal)
        view.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-MKLayout.safeAreaBottom)
        }
    }

    private func makeTableHeaderView() -> UIView {
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: 65))
        tempView.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        tempView.addSubview(headerView)
        return tempView
    }
}

// MARK: - UITableView

extension MKBXDAccelerationController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int { 3 }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return section0List.count
        case 1: return section1List.count
        case 2: return section2List.count
        default: return 0
        }
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 44 }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
            cell.dataModel = section0List[indexPath.row]
            return cell
        case 1:
            let cell = MKSwiftTextButtonCell.initCellWithTableView(tableView)
            cell.dataModel = section1List[indexPath.row]
            cell.delegate = self
            return cell
        default:
            let cell = MKSwiftTextFieldCell.initCellWithTableView(tableView)
            cell.dataModel = section2List[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - Delegates

extension MKBXDAccelerationController: MKSwiftTextButtonCellDelegate {
    public func MKSwiftTextButtonCellSelected(index: Int, dataListIndex: Int, value: String) {
        if index == 0 {
            dataModel.scale = dataListIndex
            section1List[0].dataListIndex = dataListIndex
            updateMotionThresholdUnit()
            tableView.reloadData()
            return
        }
        if index == 1 {
            dataModel.samplingRate = dataListIndex
            section1List[1].dataListIndex = dataListIndex
        }
    }
}

extension MKBXDAccelerationController: MKSwiftTextFieldCellDelegate {
    public func mkDeviceTextCellValueChanged(_ index: Int, textValue: String) {
        if index == 0 {
            dataModel.threshold = textValue
            section2List[0].textFieldValue = textValue
        }
    }
}

extension MKBXDAccelerationController: MKBXDAccelerationHeaderViewDelegate {
    public func bxd_updateThreeAxisNotifyStatus(_ notify: Bool) {
        _ = MKBXDCentralManager.shared.notifyThreeAxisData(notify)
    }
}
