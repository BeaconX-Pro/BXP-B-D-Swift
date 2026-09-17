//
//  MKBXDAlarmEventModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDAlarmEventModel: NSObject {

    public var singleCount: String = ""
    public var doubleCount: String = ""
    public var longCount: String = ""

    public func readData(sucBlock: @escaping () -> Void,
                         failedBlock: @escaping (Error) -> Void) {
        readSingleCount(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readDoubleCount(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.readLongCount(sucBlock: {
                    sucBlock()
                }, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func readSingleCount(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readSinglePressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.singleCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readDoubleCount(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDoublePressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.doubleCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readLongCount(sucBlock: @escaping () -> Void,
                                failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readLongPressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.longCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }
}
