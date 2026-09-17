//
//  MKBXDAlarmEventCountCell.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

private let buttonWidth: CGFloat = 55
private let buttonHeight: CGFloat = 30

public final class MKBXDAlarmEventCountCellModel: NSObject {
    public var index: Int = 0
    public var msg: String = ""
    public var count: String = ""
}

public protocol MKBXDAlarmEventCountCellDelegate: AnyObject {
    func bxd_alarmEvent_clearButtonPressed(_ index: Int)
}

public final class MKBXDAlarmEventCountCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDAlarmEventCountCellDelegate?

    public var dataModel: MKBXDAlarmEventCountCellModel? {
        didSet {
            msgLabel.text = dataModel?.msg ?? ""
            countLabel.text = dataModel?.count ?? ""
            setNeedsLayout()
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(13)
        label.numberOfLines = 0
        return label
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(13)
        label.text = "0"
        return label
    }()

    private lazy var clearButton: UIButton = {
        return MKSwiftUIAdaptor.createRoundedButton(title: "Clear",
                                                    target: self,
                                                    action: #selector(clearButtonPressed))
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(clearButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        clearButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(buttonWidth)
            make.centerY.equalTo(contentView)
            make.height.equalTo(buttonHeight)
        }
        countLabel.snp.remakeConstraints { make in
            make.right.equalTo(clearButton.snp.left).offset(-10)
            make.width.equalTo(100)
            make.centerY.equalTo(contentView)
            make.height.equalTo(buttonHeight)
        }
        let msgSize = NSString.mk_size(withText: msgLabel.text ?? "",
                                       andFont: msgLabel.font,
                                       andMaxSize: CGSize(width: MKScreen.width - 30 - 20 - 100 - buttonWidth, height: .greatestFiniteMagnitude))
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(countLabel.snp.left).offset(-15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(msgSize.height)
        }
    }

    @objc private func clearButtonPressed() {
        delegate?.bxd_alarmEvent_clearButtonPressed(dataModel?.index ?? 0)
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDAlarmEventCountCell {
        let identy = "MKBXDAlarmEventCountCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDAlarmEventCountCell {
            return cell
        }
        return MKBXDAlarmEventCountCell(style: .default, reuseIdentifier: identy)
    }
}
