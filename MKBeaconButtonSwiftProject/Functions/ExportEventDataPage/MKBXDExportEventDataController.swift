//
//  MKBXDExportEventDataController.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit
import MessageUI

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI
import MKSwiftBleModule

// MARK: - Page Type

public enum MKBXDExportEventDataControllerType: Int {
    case single = 0
    case double = 1
    case long = 2
    case connectionMode = 3
}

// MARK: - Controller

public final class MKBXDExportEventDataController: MKSwiftBaseViewController {

    public var vcType: MKBXDExportEventDataControllerType = .single

    // MARK: - Constants

    private let parseDataInterval: TimeInterval = 0.05

    // MARK: - Subviews

    private lazy var headerView: MKBXDSyncEventHeaderView = {
        let view = MKBXDSyncEventHeaderView()
        view.delegate = self
        view.modeMsg = vcType == .connectionMode ? "Button Clicks" : "Trigger mode"
        return view
    }()

    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = MKFont.font(13)
        tv.layoutManager.allowsNonContiguousLayout = false
        tv.isEditable = false
        tv.textColor = MKColor.defaultText
        return tv
    }()

    // MARK: - Data

    private lazy var dataList: [[String: Any]] = []
    private lazy var contentList: [[String: Any]] = []

    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        return f
    }()

    private var parseTimer: DispatchSourceTimer?

    // MARK: - Lifecycle

    deinit {
        parseTimer?.cancel()
        parseTimer = nil
        switch vcType {
        case .single:
            _ = MKBXDCentralManager.shared.notifySingleClickData(false)
        case .double:
            _ = MKBXDCentralManager.shared.notifyDoubleClickData(false)
        case .long:
            _ = MKBXDCentralManager.shared.notifyLongClickData(false)
        case .connectionMode:
            _ = MKBXDCentralManager.shared.notifyLongConnectClickData(false)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadSubViews()
        MKBXDCentralManager.shared.eventDelegate = self
    }

    // MARK: - UI

    private func loadSubViews() {
        switch vcType {
        case .double:           defaultTitle = "Double press event"
        case .long:             defaultTitle = "Long press event"
        case .connectionMode:   defaultTitle = "Alarm event"
        default:                defaultTitle = "Single press event"
        }
        view.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view).offset(MKLayout.topBarHeight)
            make.height.equalTo(100)
        }

        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(view).offset(-MKLayout.safeAreaBottom)
        }
    }

    // MARK: - Timer

    private func addTimerForRefresh() {
        parseTimer?.cancel()
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now(),
                       repeating: parseDataInterval)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.parseContentDatas()
            }
        }
        parseTimer = timer
        timer.resume()
    }

    // MARK: - Parse

    private func parseContentDatas() {
        guard !contentList.isEmpty else { return }
        let contentDic = contentList[0]
        contentList.removeFirst()

        guard let content = contentDic["content"] as? String,
              let alarmType = Int((contentDic["alarmType"] as? String) ?? "0") else {
            return
        }

        let timeValue = MKSwiftBleSDKAdopter.getDecimalWithHex(content, range: NSRange(location: 0, length: 16))
        let date = Date(timeIntervalSince1970: TimeInterval(timeValue) / 1000.0)
        let dateString = dateFormatter.string(from: date)

        var eventType = ""
        if alarmType == 0 || alarmType == 1 || alarmType == 2 {
            let type = MKSwiftBleSDKAdopter.getDecimalWithHex(content, range: NSRange(location: 16, length: 2))
            if type == 0 { eventType = "Single press mode" }
            else if type == 1 { eventType = "Double press mode" }
            else if type == 2 { eventType = "Long press mode" }
        } else {
            // Long Connection Mode
            eventType = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 16, length: 2))
        }

        let dic: [String: Any] = [
            "timestamp": dateString,
            "eventType": eventType
        ]
        dataList.append(dic)

        let space = alarmType > 2 ? "\t\t\t\t\t" : "\t\t\t"
        let text = "\n\(dateString)\(space)\(eventType)"
        textView.text = text + (textView.text ?? "")
    }

    // MARK: - Clear

    private func clearAllStatus() {
        MKSwiftHudManager.shared.showHUD(with: "Delete....", in: view, isPenetration: false)
        MKBXDExcelManager.deleteDataList(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.textView.text = ""
            self.dataList.removeAll()
            self.headerView.sync = false
            MKSwiftHudManager.shared.hide()
        }, failedBlock: { [weak self] _ in
            guard let self = self else { return }
            MKSwiftHudManager.shared.hide()
            self.textView.text = ""
            self.dataList.removeAll()
            self.headerView.sync = false
        })
    }

    // MARK: - Mail

    private func sharedExcel() {
        guard MFMailComposeViewController.canSendMail() else {
            if let url = URL(string: "MESSAGE://") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return
        }
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let path = (documentPath as NSString).appendingPathComponent("eventData.xlsx")
        guard FileManager.default.fileExists(atPath: path) else {
            view.showCentralToast("File not exist")
            return
        }
        guard let data = FileManager.default.contents(atPath: path) else {
            view.showCentralToast("Load file error")
            return
        }
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let bodyMsg = "APP Version: \(version) + + OS: \(UIDevice.current.systemVersion)"

        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["Development@mokotechnology.com"])
        mailComposer.setSubject("Feedback of mail")
        mailComposer.addAttachmentData(data, mimeType: "application/xlsx", fileName: "eventData.xlsx")
        mailComposer.setMessageBody(bodyMsg, isHTML: false)
        present(mailComposer, animated: true)
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension MKBXDExportEventDataController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
        if result == .sent {
            view.showCentralToast("send success")
        }
        dismiss(animated: true)
    }
}

// MARK: - MKBXDCentralManagerAlarmEventDelegate

extension MKBXDExportEventDataController: MKBXDCentralManagerAlarmEventDelegate {

    public func mk_bxd_receiveAlarmEventData(_ contentData: [String: Any]) {
        contentList.append(contentData)
    }
}

// MARK: - MKBXDSyncEventHeaderViewDelegate

extension MKBXDExportEventDataController: MKBXDSyncEventHeaderViewDelegate {

    public func bxd_syncEventHeaderView_syncBtnPressed(_ selected: Bool) {
        parseTimer?.cancel()
        parseTimer = nil

        if selected {
            textView.text = ""
            dataList.removeAll()
            contentList.removeAll()
            addTimerForRefresh()
        }

        switch vcType {
        case .single:
            _ = MKBXDCentralManager.shared.notifySingleClickData(selected)
        case .double:
            _ = MKBXDCentralManager.shared.notifyDoubleClickData(selected)
        case .long:
            _ = MKBXDCentralManager.shared.notifyLongClickData(selected)
        case .connectionMode:
            _ = MKBXDCentralManager.shared.notifyLongConnectClickData(selected)
        }
    }

    public func bxd_syncEventHeaderView_deleteBtnPressed() {
        switch vcType {
        case .single:
            MKBXDInterface.bxd_clearSinglePressEventData(sucBlock: { [weak self] in
                MKSwiftHudManager.shared.hide()
                _ = MKBXDCentralManager.shared.notifySingleClickData(false)
                self?.clearAllStatus()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            })
        case .double:
            MKBXDInterface.bxd_clearDoublePressEventData(sucBlock: { [weak self] in
                MKSwiftHudManager.shared.hide()
                _ = MKBXDCentralManager.shared.notifyDoubleClickData(false)
                self?.clearAllStatus()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            })
        case .long:
            MKBXDInterface.bxd_clearLongPressEventData(sucBlock: { [weak self] in
                MKSwiftHudManager.shared.hide()
                _ = MKBXDCentralManager.shared.notifyLongClickData(false)
                self?.clearAllStatus()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            })
        case .connectionMode:
            MKBXDInterface.bxd_clearLongConnectionModeEventData(sucBlock: { [weak self] in
                MKSwiftHudManager.shared.hide()
                _ = MKBXDCentralManager.shared.notifyLongConnectClickData(false)
                self?.clearAllStatus()
            }, failedBlock: { [weak self] error in
                MKSwiftHudManager.shared.hide()
                self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
            })
        }
    }

    public func bxd_syncEventHeaderView_exportBtnPressed() {
        MKSwiftHudManager.shared.showHUD(with: "Waiting...", in: view, isPenetration: false)
        MKBXDExcelManager.exportExcelWithEventDataList(dataList, sucBlock: { [weak self] in
            MKSwiftHudManager.shared.hide()
            self?.sharedExcel()
        }, failedBlock: { [weak self] error in
            MKSwiftHudManager.shared.hide()
            self?.view.showCentralToast((error as NSError).userInfo["errorInfo"] as? String ?? "")
        })
    }
}
