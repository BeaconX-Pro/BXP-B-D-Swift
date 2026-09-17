//
//  MKBXDExcelManager.swift
//  MKBeaconXDButton
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 lovexiaoxia. All rights reserved.
//

import Foundation
import libxlsxwriter

public enum MKBXDExcelManager {

    // MARK: - Export

    /// 导出事件数据到 Excel
    /// - Parameters:
    ///   - list: 数据列表，每项含 `timestamp` / `eventType`
    ///   - sucBlock: 成功回调
    ///   - failedBlock: 失败回调
    public static func exportExcelWithEventDataList(_ list: [[String: Any]],
                                                    sucBlock: (() -> Void)?,
                                                    failedBlock: @escaping (Error) -> Void) {
        guard !list.isEmpty else {
            DispatchQueue.main.async {
                sucBlock?()
            }
            return
        }

        // 设置 excel 文件名和路径
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let path = (documentPath as NSString).appendingPathComponent("eventData.xlsx")

        // ✅ 用 strdup 保证 C 字符串生命周期覆盖整个 workbook 使用过程
        guard let cPath = strdup(path) else {
            let error = NSError(domain: "excelOperation",
                                code: -999,
                                userInfo: ["errorInfo": "Export Failed"])
            DispatchQueue.main.async {
                failedBlock(error)
            }
            return
        }
        defer { free(cPath) }

        // 创建新 xlsx 文件
        guard let workbook = workbook_new(cPath) else {
            let error = NSError(domain: "excelOperation",
                                code: -999,
                                userInfo: ["errorInfo": "Export Failed"])
            DispatchQueue.main.async {
                failedBlock(error)
            }
            return
        }

        // 创建 sheet
        guard let worksheet = workbook_add_worksheet(workbook, nil) else {
            workbook_close(workbook)
            let error = NSError(domain: "excelOperation",
                                code: -999,
                                userInfo: ["errorInfo": "Export Failed"])
            DispatchQueue.main.async {
                failedBlock(error)
            }
            return
        }

        // 设置列宽
        worksheet_set_column(worksheet, 0, 2, 50, nil)

        // 添加格式
        let format = workbook_add_format(workbook)
        format_set_bold(format)
        format_set_align(format, UInt8(LXW_ALIGN_VERTICAL_CENTER.rawValue))

        // 写入表头
        worksheet_write_string(worksheet, 0, 0, "timestamp", nil)
        worksheet_write_string(worksheet, 0, 1, "eventType", nil)

        // 写入数据
        for (index, dic) in list.enumerated() {
            let row = UInt32(index + 1)
            worksheet_write_string(worksheet, row, 0, (dic["timestamp"] as? String) ?? "", nil)
            worksheet_write_string(worksheet, row, 1, (dic["eventType"] as? String) ?? "", nil)
        }

        // 关闭并保存
        let errorCode = workbook_close(workbook)
        if errorCode != LXW_NO_ERROR {
            let error = NSError(domain: "excelOperation",
                                code: -999,
                                userInfo: ["errorInfo": "Export Failed"])
            DispatchQueue.main.async {
                failedBlock(error)
            }
            return
        }

        DispatchQueue.main.async {
            sucBlock?()
        }
    }

    // MARK: - Delete

    /// 删除已导出的 Excel 文件
    /// - Parameters:
    ///   - sucBlock: 成功回调（文件不存在也算成功）
    ///   - failedBlock: 失败回调
    public static func deleteDataList(sucBlock: (() -> Void)?,
                                      failedBlock: ((Error) -> Void)?) {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let path = (documentPath as NSString).appendingPathComponent("eventData.xlsx")

        // 文件不存在 → 直接成功
        guard FileManager.default.fileExists(atPath: path) else {
            DispatchQueue.main.async {
                sucBlock?()
            }
            return
        }

        do {
            try FileManager.default.removeItem(atPath: path)
            DispatchQueue.main.async {
                sucBlock?()
            }
        } catch {
            let nsError = NSError(domain: "excelOperation",
                                  code: -999,
                                  userInfo: ["errorInfo": "Delete Failed"])
            DispatchQueue.main.async {
                failedBlock?(nsError)
            }
        }
    }
}
