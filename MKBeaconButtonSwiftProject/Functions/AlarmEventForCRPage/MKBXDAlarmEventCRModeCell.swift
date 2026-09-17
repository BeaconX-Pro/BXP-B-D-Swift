//
//  MKBXDAlarmEventCRModeCell.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public final class MKBXDAlarmEventCRModeCellModel: NSObject {
    public var index: Int = 0
    public var msg: String = ""
    public var count: String = ""
}

public protocol MKBXDAlarmEventCRModeCellDelegate: AnyObject {
    func bxd_alarmEventCRModeCell_clearBtnPressed(_ index: Int)
    func bxd_alarmEventCRModeCell_exportBtnPressed(_ index: Int)
}

public final class MKBXDAlarmEventCRModeCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDAlarmEventCRModeCellDelegate?

    public var dataModel: MKBXDAlarmEventCRModeCellModel? {
        didSet {
            msgLabel.text = dataModel?.msg ?? ""
            eventCountLabel.text = dataModel?.count ?? ""
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        return label
    }()

    private lazy var eventCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(13)
        label.text = "0"
        return label
    }()

    private lazy var clearButton: UIButton = {
        let btn = MKSwiftUIAdaptor.createRoundedButton(title: "clear",
                                                       target: self,
                                                       action: #selector(clearButtonPressed))
        btn.titleLabel?.font = MKFont.font(13)
        return btn
    }()

    private lazy var exportButton: UIButton = {
        let btn = MKSwiftUIAdaptor.createRoundedButton(title: "Export",
                                                       target: self,
                                                       action: #selector(exportButtonPressed))
        btn.titleLabel?.font = MKFont.font(13)
        return btn
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(eventCountLabel)
        contentView.addSubview(clearButton)
        contentView.addSubview(exportButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(eventCountLabel.snp.left).offset(-5)
            make.top.equalTo(10)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        eventCountLabel.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(80)
            make.centerY.equalTo(msgLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        exportButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(60)
            make.top.equalTo(msgLabel.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        clearButton.snp.remakeConstraints { make in
            make.right.equalTo(exportButton.snp.left).offset(-15)
            make.width.equalTo(45)
            make.centerY.equalTo(exportButton)
            make.height.equalTo(30)
        }
    }

    @objc private func clearButtonPressed() {
        delegate?.bxd_alarmEventCRModeCell_clearBtnPressed(dataModel?.index ?? 0)
    }

    @objc private func exportButtonPressed() {
        delegate?.bxd_alarmEventCRModeCell_exportBtnPressed(dataModel?.index ?? 0)
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDAlarmEventCRModeCell {
        let identy = "MKBXDAlarmEventCRModeCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDAlarmEventCRModeCell {
            return cell
        }
        return MKBXDAlarmEventCRModeCell(style: .default, reuseIdentifier: identy)
    }
}
