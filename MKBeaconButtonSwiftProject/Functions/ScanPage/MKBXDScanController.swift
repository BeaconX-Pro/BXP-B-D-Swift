//
//  MKBXDScanController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit
@preconcurrency import CoreBluetooth

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI
import MKSwiftBleModule
import MKSwiftBeaconXCustomUI

// MARK: - Constants

private let localPasswordKey = "mk_bxd_passwordKey"
private let offset_X: CGFloat = 15
private let searchButtonHeight: CGFloat = 40
private let headerViewHeight: CGFloat = 90
private let kRefreshInterval: TimeInterval = 1.0

// MARK: - Controller

public final class MKBXDScanController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    private lazy var refreshIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_scan_refreshIcon.png")
        return iv
    }()

    private lazy var refreshButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
        return btn
    }()

    private lazy var searchButton: MKSwiftBXScanSearchButton = {
        let btn = MKSwiftBXScanSearchButton()
        btn.delegate = self
        return btn
    }()

    // MARK: - Data

    private lazy var dataList: [MKBXDScanDataModel] = []

    private lazy var buttonModel: MKSwiftBXScanSearchButtonModel = {
        let m = MKSwiftBXScanSearchButtonModel()
        m.placeholder = "Edit Filter"
        m.minSearchRssi = -100
        m.searchRssi = -100
        return m
    }()

    private var scanTimer: DispatchSourceTimer?

    /// RunLoop observer
    private var observerRef: CFRunLoopObserver?

    /// 扫描到新的设备不能立即刷新列表，降低刷新频率
    private var isNeedRefresh: Bool = false

    /// 保存当前密码输入框 ascii 字符部分
    private var asciiText: String = ""

    // MARK: - Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let ref = observerRef {
            CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), ref, .commonModes)
        }
        MKBXDCentralManager.shared.stopScan()
        MKBXDCentralManager.removeFromCentralList()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        startRefresh()
    }

    public override func rightButtonMethod() {
        // ⚠️ 按工程实际路由方式调整（CTMediator 或直接 push）
        let vc = MKBXDAboutController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UI

    private func loadSubViews() {
        view.backgroundColor = UIColor(red: 237/255.0, green: 243/255.0, blue: 250/255.0, alpha: 1)
        leftButton.isHidden = true
        rightButton.setImage(UIImage(named: "bxd_scanRightAboutIcon.png"), for: .normal)
        defaultTitle = "DEVICE(0)"

        let topView = UIView()
        topView.backgroundColor = UIColor(red: 237/255.0, green: 243/255.0, blue: 250/255.0, alpha: 1)
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.height.equalTo(searchButtonHeight + 2 * 15)
        }

        refreshButton.addSubview(refreshIcon)
        topView.addSubview(refreshButton)

        refreshIcon.snp.makeConstraints { make in
            make.centerX.equalTo(refreshButton)
            make.centerY.equalTo(refreshButton)
            make.width.height.equalTo(22)
        }
        refreshButton.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.width.height.equalTo(40)
            make.top.equalTo(15)
        }

        topView.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(refreshButton.snp.left).offset(-10)
            make.top.equalTo(15)
            make.height.equalTo(searchButtonHeight)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(view).offset(-(MKLayout.safeAreaBottom + 5))
        }
    }

    // MARK: - Start Refresh

    private func startRefresh() {
        searchButton.dataModel = buttonModel
        runloopObserver()
        MKBXDCentralManager.shared.delegate = self

        let firstInstall = UserDefaults.standard.object(forKey: "mk_bxd_firstInstall") as? Bool
        var afterTime: TimeInterval = 0.5
        if firstInstall == nil {
            // 第一次安装
            UserDefaults.standard.set(false, forKey: "mk_bxd_firstInstall")
            afterTime = 3.5
        }
        perform(#selector(refreshButtonPressed), with: nil, afterDelay: afterTime)
    }

    // MARK: - RunLoop Observer

    private func runloopObserver() {
        var timeInterval = Date().timeIntervalSince1970
        let ref = CFRunLoopObserverCreateWithHandler(
            CFAllocatorGetDefault().takeUnretainedValue(),
            CFRunLoopActivity.allActivities.rawValue,
            true,
            0
        ) { [weak self] _, activity in
            guard let self = self else { return }
            if activity == .beforeWaiting {
                // runloop 空闲的时候刷新，控制刷新频率
                let currentInterval = Date().timeIntervalSince1970
                if currentInterval - timeInterval < kRefreshInterval {
                    return
                }
                timeInterval = currentInterval
                if self.isNeedRefresh {
                    self.tableView.reloadData()
                    self.defaultTitle = "DEVICE(\(self.dataList.count))"
                    self.isNeedRefresh = false
                }
            }
        }
        if let ref = ref {
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), ref, .commonModes)
            observerRef = ref
        }
    }

    private func needRefreshList() {
        isNeedRefresh = true
        CFRunLoopWakeUp(CFRunLoopGetMain())
    }

    // MARK: - Scan

    @objc private func refreshButtonPressed() {
        if MKBXDCentralManager.shared.centralManager.state == .unauthorized {
            // 用户未授权
            showAuthorizationAlert()
            return
        }
        if MKBXDCentralManager.shared.centralManager.state == .poweredOff {
            // 用户关闭了系统蓝牙
            showBLEDisable()
            return
        }
        refreshButton.isSelected.toggle()
        refreshIcon.layer.removeAnimation(forKey: "mk_refreshAnimationKey")

        if !refreshButton.isSelected {
            // 停止扫描
            MKBXDCentralManager.shared.stopScan()
            return
        }

        dataList.removeAll()
        tableView.reloadData()
        // 刷新顶部设备数量
        defaultTitle = "DEVICE(\(dataList.count))"
        let refreshRotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        refreshRotationAnimation.toValue = Double.pi * 2.0
        refreshRotationAnimation.duration = 2.0
        refreshRotationAnimation.isCumulative = true
        refreshRotationAnimation.repeatCount = .infinity
        refreshRotationAnimation.isRemovedOnCompletion = false
        refreshIcon.layer.add(refreshRotationAnimation, forKey: "mk_refreshAnimationKey")
        MKBXDCentralManager.shared.startScan()
    }

    @objc private func startScanDevice() {
        refreshButton.isSelected = false
        refreshButtonPressed()
    }

    // MARK: - Update Data

    private func updateDataWithAdvModel(_ advData: MKBXDBaseAdvModel) {
        if advData.frameType == .unknown { return }

        if !(buttonModel.searchMac ?? "").isEmpty || !(buttonModel.searchName ?? "").isEmpty {
            // 如果打开了过滤
            if advData.rssi.intValue >= buttonModel.searchRssi && filterAdvDataWithSearchName(advData) {
                processAdvData(advData)
            }
            return
        }
        if buttonModel.searchRssi > buttonModel.minSearchRssi {
            // 开启 rssi 过滤
            if advData.rssi.intValue >= buttonModel.searchRssi {
                processAdvData(advData)
            }
            return
        }
        processAdvData(advData)
    }

    /// 通过设备名称和 mac 地址过滤设备
    private func filterAdvDataWithSearchName(_ advData: MKBXDBaseAdvModel) -> Bool {
        if let advDataModel = advData as? MKBXDAdvDataModel {
            // 广播包才有设备名称
            if advDataModel.deviceName.uppercased().contains((buttonModel.searchName ?? "").uppercased()) {
                return true
            }
        }
        if let respondData = advData as? MKBXDAdvRespondDataModel {
            // 回应包才有 mac 地址
            let mac = respondData.macAddress.replacingOccurrences(of: ":", with: "").uppercased()
            if mac.contains((buttonModel.searchMac ?? "").uppercased()) {
                return true
            }
        }
        let identy = advData.peripheral?.identifier.uuidString ?? ""
        let contain = dataList.contains { $0.identifier == identy }
        return contain
    }

    private func processAdvData(_ advData: MKBXDBaseAdvModel) {
        // 查看数据源中是否已经存在相关设备
        let identy = advData.peripheral?.identifier.uuidString ?? ""
        if let existModel = dataList.first(where: { $0.identifier == identy }) {
            // 已存在，替换或添加
            MKBXDScanPageAdopter.updateInfoCellModel(existModel, advData: advData)
            needRefreshList()
            return
        }
        // 不存在，加入到 dataList
        let deviceModel = MKBXDScanPageAdopter.parseBaseAdvDataToInfoModel(advData)
        dataList.append(deviceModel)
        needRefreshList()
    }

    // MARK: - Connect

    private func connectPeripheral(_ peripheral: CBPeripheral) {
        // 停止扫描
        refreshIcon.layer.removeAnimation(forKey: "mk_refreshAnimationKey")
        MKBXDCentralManager.shared.stopScan()
        if let timer = scanTimer {
            timer.cancel()
            scanTimer = nil
        }

        MKSwiftHudManager.shared.showHUD(with: "Reading...", in: view, isPenetration: false)
        MKBXDCentralManager.shared.readNeedPassword(with: peripheral, sucBlock: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                MKSwiftHudManager.shared.hide()
                if (result["state"] as? String) == "00" {
                    // 免密登录
                    self.connectDeviceWithoutPassword(peripheral)
                    return
                }
                self.connectDeviceWithPassword(peripheral)
            }
        }, failedBlock: { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                MKSwiftHudManager.shared.hide()
                self.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
                self.connectFailed()
            }
        })
    }

    private func connectDeviceWithPassword(_ peripheral: CBPeripheral) {
        let alert = MKSwiftAlertView()
        alert.addAction(MKSwiftAlertViewAction(title: "Cancel") { [weak self] in
            guard let self = self else { return }
            self.refreshButton.isSelected = false
            self.refreshButtonPressed()
        })
        alert.addAction(MKSwiftAlertViewAction(title: "OK") { [weak self] in
            self?.startConnectPeripheral(peripheral, needPassword: true)
        })

        let localPassword = UserDefaults.standard.string(forKey: localPasswordKey) ?? ""
        asciiText = localPassword
        let textField = MKSwiftAlertViewTextField(textValue: localPassword,
                                                  placeholder: "No more than 16 characters.",
                                                  textFieldType: .normal,
                                                  maxLength: 16) { [weak self] text in
            self?.asciiText = text
        }
        alert.addTextField(textField)
        alert.showAlert(title: "Enter password", message: "Please enter connection password.")
    }

    private func connectDeviceWithoutPassword(_ peripheral: CBPeripheral) {
        startConnectPeripheral(peripheral, needPassword: false)
    }

    private func startConnectPeripheral(_ peripheral: CBPeripheral, needPassword: Bool) {
        if needPassword {
            let password = asciiText
            guard !password.isEmpty else {
                view.showCentralToast("Password cannot be empty.")
                return
            }
            guard password.count <= 16 else {
                view.showCentralToast("No more than 16 characters.")
                return
            }
        }
        MKSwiftHudManager.shared.showHUD(with: "Connecting...", in: view, isPenetration: false)
        MKBXDConnectManager.shared.connectDevice(peripheral,
                                                  password: needPassword ? asciiText : "",
                                                  sucBlock: { [weak self] in
            guard let self = self else { return }
            if !self.asciiText.isEmpty && self.asciiText.count <= 16 {
                UserDefaults.standard.set(self.asciiText, forKey: localPasswordKey)
            }
            MKSwiftHudManager.shared.hide()
            MKSwiftBleLogManager.deleteLog(fileName: "Single press trigger event")
            MKSwiftBleLogManager.deleteLog(fileName: "Double press trigger event")
            MKSwiftBleLogManager.deleteLog(fileName: "Long press trigger event")
            self.perform(#selector(self.pushTabBarPage), with: nil, afterDelay: 0.6)
        }, failedBlock: { [weak self] error in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            self.connectFailed()
        })
    }

    @objc private func pushTabBarPage() {
        let vc = MKBXDTabBarController()
        vc.modalPresentationStyle = .fullScreen
        // ⚠️ 按工程实际 present 方式调整（HHTransition 对应 Swift 版）
        present(vc, animated: true) {
            vc.tabBarDelegate = self
        }
    }

    private func connectFailed() {
        refreshButton.isSelected = false
        refreshButtonPressed()
    }

    // MARK: - Alerts

    private func showAuthorizationAlert() {
        let alert = UIAlertController(title: "",
                                      message: "This function requires Bluetooth authorization, please enable MK Button permission in Settings-Privacy-Bluetooth.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showBLEDisable() {
        let alert = UIAlertController(title: "",
                                      message: "The current system of bluetooth is not available!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDScanController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        dataList.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = dataList[section]
        return model.advertiseList.count + 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // 第一个 row 固定为设备信息帧
            let cell = MKBXDScanDeviceDataCell.initCellWithTableView(tableView)
            cell.dataModel = dataList[indexPath.section]
            cell.delegate = self
            return cell
        }
        let model = dataList[indexPath.section]
        if indexPath.row - 1 < model.advertiseList.count {
            let dataModel = model.advertiseList[indexPath.row - 1] as? MKBXDScanFrameModel
            if let dataModel = dataModel {
                return MKBXDScanPageAdopter.loadCellWithTableView(tableView, dataModel: dataModel)
            }
        }
        return UITableViewCell(style: .default, reuseIdentifier: "MKBXDScanPageAdopterIdenty")
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return headerViewHeight
        }
        let model = dataList[indexPath.section]
        if indexPath.row - 1 < model.advertiseList.count,
           let dataModel = model.advertiseList[indexPath.row - 1] as? MKBXDScanFrameModel {
            return MKBXDScanPageAdopter.loadCellHeightWithDataModel(dataModel)
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0 : 5
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MKSwiftTableSectionLineHeader.dequeueHeader(with: tableView)
        let data = MKSwiftTableSectionLineHeaderModel()
        data.contentColor = UIColor(red: 237/255.0, green: 243/255.0, blue: 250/255.0, alpha: 1)
        header.headerModel = data
        return header
    }
}

// MARK: - MKSwiftBXScanSearchButtonDelegate

extension MKBXDScanController: MKSwiftBXScanSearchButtonDelegate {

    public func mk_bx_scanSearchButtonMethod() {
        // ⚠️ 按工程实际 Filter View 调用方式调整
        MKSwiftBXScanFilterView.showSearch(name: buttonModel.searchName,
                                     macAddress: buttonModel.searchMac,
                                     rssi: buttonModel.searchRssi) { [weak self] searchName, searchMacAddress, searchRssi in
            guard let self = self else { return }
            self.buttonModel.searchRssi = searchRssi
            self.buttonModel.searchName = searchName
            self.buttonModel.searchMac = searchMacAddress
            self.searchButton.dataModel = self.buttonModel

            self.refreshButton.isSelected = false
            self.refreshButtonPressed()
        }
    }

    public func mk_bx_scanSearchButtonClearMethod() {
        buttonModel.searchRssi = -100
        buttonModel.searchMac = ""
        buttonModel.searchName = ""
        refreshButton.isSelected = false
        refreshButtonPressed()
    }
}

// MARK: - MKBXDCentralManagerScanDelegate

extension MKBXDScanController: MKBXDCentralManagerScanDelegate {

    public func mk_bxd_receiveAdvData(_ deviceList: [MKBXDBaseAdvModel]) {
        for advModel in deviceList {
            updateDataWithAdvModel(advModel)
        }
    }

    public func mk_bxd_stopScan() {
        if refreshButton.isSelected {
            refreshIcon.layer.removeAnimation(forKey: "mk_refreshAnimationKey")
            refreshButton.isSelected = false
        }
    }

    public func mk_bxd_startScan() {}
}

// MARK: - MKBXDScanDeviceDataCellDelegate

extension MKBXDScanController: MKBXDScanDeviceDataCellDelegate {

    public func mk_bxd_connectPeripheral(_ peripheral: CBPeripheral) {
        connectPeripheral(peripheral)
    }
}

// MARK: - MKBXDTabBarControllerDelegate

extension MKBXDScanController: MKBXDTabBarControllerDelegate {

    public func mk_bxd_needResetScanDelegate(_ need: Bool) {
        if need {
            MKBXDCentralManager.shared.delegate = self
        }
        perform(#selector(startScanDevice), with: nil, afterDelay: need ? 1.0 : 0.1)
    }
}
