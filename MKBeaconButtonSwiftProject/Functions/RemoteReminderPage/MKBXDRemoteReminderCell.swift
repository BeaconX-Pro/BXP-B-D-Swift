//
//  MKBXDRemoteReminderCell.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - Model

public final class MKBXDRemoteReminderCellModel: NSObject {
    public var msg: String = ""
    public var index: Int = 0
}

// MARK: - Delegate

public protocol MKBXDRemoteReminderCellDelegate: AnyObject {
    func bxd_remindButtonPressed(_ index: Int)
}

// MARK: - Cell

public final class MKBXDRemoteReminderCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDRemoteReminderCellDelegate?

    public var dataModel: MKBXDRemoteReminderCellModel? {
        didSet {
            msgLabel.text = dataModel?.msg ?? ""
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        return label
    }()

    private lazy var remindButton: UIButton = {
        return MKSwiftUIAdaptor.createRoundedButton(title: "Remind",
                                                    target: self,
                                                    action: #selector(remindButtonPressed))
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(remindButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        remindButton.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(60)
            make.centerY.equalTo(contentView)
            make.height.equalTo(35)
        }
        msgLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(remindButton.snp.left).offset(-15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
    }

    @objc private func remindButtonPressed() {
        delegate?.bxd_remindButtonPressed(dataModel?.index ?? 0)
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDRemoteReminderCell {
        let identy = "MKBXDRemoteReminderCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDRemoteReminderCell {
            return cell
        }
        return MKBXDRemoteReminderCell(style: .default, reuseIdentifier: identy)
    }
}
