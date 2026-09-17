//
//  MKBXDLogManager.swift
//  MKBeaconButtonSwiftProject
//
//  本地触发事件日志文件管理，对应 OC 版 MKBXDBaseLogManager。
//  日志文件位于沙盒 Documents 目录，文件名为 "/fileName.txt"。
//

import Foundation

public enum MKBXDBaseLogManager {

    /// 删除本地指定名称的日志文件
    /// - Parameter fileName: 文件名称（最终文件为 "/fileName.txt"）
    public static func deleteLog(withFileName fileName: String) {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                            .userDomainMask,
                                                            true).last ?? ""
        let filePath = directory + "/\(fileName).txt"
        try? FileManager.default.removeItem(atPath: filePath)
    }
}
