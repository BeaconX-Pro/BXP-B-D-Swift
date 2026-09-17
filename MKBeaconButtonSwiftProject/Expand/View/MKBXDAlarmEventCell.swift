//
//  MKBXDAlarmEventCell.swift
//  MKBeaconXDButton
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - Model

public final class MKBXDAlarmEventCellModel: NSObject {
    public var count: String = ""
}

// MARK: - Delegate

public protocol MKBXDAlarmEventCellDelegate: AnyObject {
    func bxd_alarmEventCell_clearButtonPressed()
}

// MARK: - Cell

public final class MKBXDAlarmEventCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDAlarmEventCellDelegate?

    public var dataModel: MKBXDAlarmEventCellModel? {
        didSet {
            eventCountLabel.text = dataModel?.count ?? ""
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Long Connection Mode"
        return label
    }()

    private lazy var alarmEventLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = "Alarm Events"
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

    private lazy var clicksLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = "Button Clicks"
        return label
    }()

    private lazy var clearButton: UIButton = {
        return MKSwiftUIAdaptor.createRoundedButton(title: "clear",
                                                    target: self,
                                                    action: #selector(clearButtonPressed))
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(alarmEventLabel)
        contentView.addSubview(eventCountLabel)
        contentView.addSubview(clicksLabel)
        contentView.addSubview(clearButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(10)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        alarmEventLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(80)
            make.centerY.equalTo(clearButton)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        eventCountLabel.snp.remakeConstraints { make in
            make.left.equalTo(alarmEventLabel.snp.right).offset(5)
            make.width.equalTo(100)
            make.centerY.equalTo(clearButton)
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
        clicksLabel.snp.remakeConstraints { make in
            make.left.equalTo(eventCountLabel.snp.right).offset(5)
            make.right.equalTo(clearButton.snp.left).offset(-5)
            make.centerY.equalTo(clearButton)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        clearButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(45)
            make.top.equalTo(msgLabel.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
    }

    @objc private func clearButtonPressed() {
        delegate?.bxd_alarmEventCell_clearButtonPressed()
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDAlarmEventCell {
        let identy = "MKBXDAlarmEventCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDAlarmEventCell {
            return cell
        }
        return MKBXDAlarmEventCell(style: .default, reuseIdentifier: identy)
    }
}
