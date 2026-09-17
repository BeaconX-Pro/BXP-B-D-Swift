//
//  MKBXDUpdateController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDUpdateController: MKSwiftBaseViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.tableHeaderView = makeTableHeader()
        return tv
    }()

    // MARK: - Data

    private lazy var dataList: [MKSwiftNormalTextCellModel] = []
    private lazy var dfuModule = MKBXDDFUModule()

    private var monitorQueue: DispatchQueue?
    private var monitorSource: DispatchSourceFileSystemObject?

    // MARK: - Lifecycle

    deinit {
        if let source = monitorSource {
            source.cancel()
            monitorSource = nil
        }
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
        loadFileList()
        startMonitoringDFUFiles()
    }

    // MARK: - UI

    private func loadSubViews() {
        defaultTitle = "OTA"
        rightButton.isHidden = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.bottom.equalTo(view).offset(-MKLayout.safeAreaBottom)
        }
    }

    private func makeTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: MKScreen.width, height: 60))
        headerView.backgroundColor = .white

        let selectBtn = MKSwiftUIAdaptor.createRoundedButton(title: "Select Firmware",
                                                             target: self,
                                                             action: #selector(selectBtnPressed))
        selectBtn.frame = CGRect(x: (MKScreen.width - 200) / 2, y: 10, width: 200, height: 40)
        headerView.addSubview(selectBtn)

        return headerView
    }

    // MARK: - Actions

    @objc private func selectBtnPressed() {
        let dataType = UTType("public.data") ?? .data
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [dataType])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    // MARK: - File List

    private func currentFileList() -> [String] {
        let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""
        do {
            return try FileManager.default.contentsOfDirectory(atPath: document)
        } catch {
            return []
        }
    }

    private func loadFileList() {
        let list = currentFileList()
        guard !list.isEmpty else { return }
        dataList.removeAll()
        for fileName in list {
            let model = MKSwiftNormalTextCellModel()
            model.leftMsg = fileName
            dataList.append(model)
        }
        tableView.reloadData()
    }

    // MARK: - File Monitor

    private func startMonitoringDFUFiles() {
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""
        let filedes = open(directoryPath, O_EVTONLY)
        guard filedes >= 0 else { return }

        let queue = DispatchQueue(label: "ZFileMonitorQueue")
        monitorQueue = queue

        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: filedes,
                                                                eventMask: .write,
                                                                queue: queue)
        source.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.loadFileList()
            }
        }
        source.setCancelHandler {
            close(filedes)
        }
        source.resume()
        monitorSource = source
    }

    // MARK: - DFU

    private func startDFUWithFilePath(_ filePath: String) {
        guard !filePath.isEmpty else {
            view.showCentralToast("Firmware cannot be empty!")
            return
        }

        // 抛出该通知，设备信息页面再次返回不需要读取任何数据了
        NotificationCenter.default.post(name: Notification.Name("mk_bxd_startDfuProcessNotification"), object: nil)

        leftButton.isEnabled = false
        MKSwiftHudManager.shared.showHUD(with: "Waiting...", in: view, isPenetration: false)

        dfuModule.updateWithFileUrl(filePath, progressBlock: { _ in
            // 可显示进度
        }, sucBlock: { [weak self] in
            guard let self = self else { return }
            MKSwiftHudManager.shared.showHUD(with: "Update firmware successfully!", in: self.view, isPenetration: false)
            self.perform(#selector(self.updateComplete), with: nil, afterDelay: 1.0)
        }, failedBlock: { [weak self] _ in
            guard let self = self else { return }
            MKSwiftHudManager.shared.showHUD(with: "Opps!DFU Failed. Please try again!", in: self.view, isPenetration: false)
            self.perform(#selector(self.updateComplete), with: nil, afterDelay: 1.0)
        })
    }

    @objc private func updateComplete() {
        leftButton.isEnabled = true
        MKSwiftHudManager.shared.hide()
        MKBXDCentralManager.sharedDealloc()
        NotificationCenter.default.post(name: Notification.Name("mk_bxd_centralDeallocNotification"), object: nil)
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MKBXDUpdateController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int { 1 }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let firmwareModel = dataList[indexPath.row]
        guard !firmwareModel.leftMsg.isEmpty else {
            view.showCentralToast("Firmware cannot be empty!")
            return
        }
        let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""
        let filePath = (document as NSString).appendingPathComponent(firmwareModel.leftMsg)
        startDFUWithFilePath(filePath)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MKSwiftNormalTextCell.initCellWithTableView(tableView)
        cell.dataModel = dataList[indexPath.row]
        return cell
    }
}

// MARK: - UIDocumentPickerDelegate

extension MKBXDUpdateController: UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController,
                               didPickDocumentsAt urls: [URL]) {
        guard let sourceURL = urls.first else { return }

        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""
        let fileName = sourceURL.lastPathComponent
        let destPath = (documentDir as NSString).appendingPathComponent(fileName)

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath) {
            try? fileManager.removeItem(atPath: destPath)
        }

        var success = false
        if sourceURL.startAccessingSecurityScopedResource() {
            do {
                try fileManager.copyItem(at: sourceURL, to: URL(fileURLWithPath: destPath))
                success = true
            } catch {
                success = false
            }
            sourceURL.stopAccessingSecurityScopedResource()
        }

        if success {
            startDFUWithFilePath(destPath)
        } else {
            view.showCentralToast("Failed to import firmware file!")
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // 用户取消选择，无需处理
    }
}
