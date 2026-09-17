//
//  MKBXDAlarmV2EventCell.swift
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

public final class MKBXDAlarmV2EventCellModel: NSObject {
    public var mainCount: String = ""
    public var subCount: String = ""
}

// MARK: - Delegate

public protocol MKBXDAlarmV2EventCellDelegate: AnyObject {
    func bxd_alarmV2EventCell_clearButtonPressed()
}

// MARK: - Cell

public final class MKBXDAlarmV2EventCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDAlarmV2EventCellDelegate?

    public var dataModel: MKBXDAlarmV2EventCellModel? {
        didSet {
            mainCountLabel.text = dataModel?.mainCount ?? ""
            subCountLabel.text = dataModel?.subCount ?? ""
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

    private lazy var clearButton: UIButton = {
        return MKSwiftUIAdaptor.createRoundedButton(title: "clear",
                                                    target: self,
                                                    action: #selector(clearButtonPressed))
    }()

    private lazy var mainBtnMsgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = "Main button"
        return label
    }()

    private lazy var mainCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(13)
        label.text = "0"
        return label
    }()

    private lazy var mainClicksLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = "Button Clicks"
        return label
    }()

    private lazy var subBtnMsgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = "Sub button"
        return label
    }()

    private lazy var subCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(13)
        label.text = "0"
        return label
    }()

    private lazy var subClicksLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = "Button Clicks"
        return label
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(clearButton)
        contentView.addSubview(mainBtnMsgLabel)
        contentView.addSubview(mainCountLabel)
        contentView.addSubview(mainClicksLabel)
        contentView.addSubview(subBtnMsgLabel)
        contentView.addSubview(subCountLabel)
        contentView.addSubview(subClicksLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(clearButton.snp.left).offset(-10)
            make.centerY.equalTo(clearButton)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        clearButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(45)
            make.top.equalTo(10)
            make.height.equalTo(30)
        }
        mainBtnMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(25)
            make.width.equalTo(80)
            make.centerY.equalTo(mainCountLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        mainCountLabel.snp.remakeConstraints { make in
            make.left.equalTo(mainBtnMsgLabel.snp.right).offset(5)
            make.width.equalTo(100)
            make.top.equalTo(clearButton.snp.bottom).offset(10)
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
        mainClicksLabel.snp.remakeConstraints { make in
            make.left.equalTo(mainCountLabel.snp.right).offset(5)
            make.right.equalTo(-25)
            make.centerY.equalTo(mainCountLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        subBtnMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(25)
            make.width.equalTo(80)
            make.centerY.equalTo(subCountLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        subCountLabel.snp.remakeConstraints { make in
            make.left.equalTo(mainBtnMsgLabel.snp.right).offset(5)
            make.width.equalTo(100)
            make.top.equalTo(mainCountLabel.snp.bottom).offset(10)
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
        subClicksLabel.snp.remakeConstraints { make in
            make.left.equalTo(subCountLabel.snp.right).offset(5)
            make.right.equalTo(-25)
            make.centerY.equalTo(subCountLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
    }

    @objc private func clearButtonPressed() {
        delegate?.bxd_alarmV2EventCell_clearButtonPressed()
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDAlarmV2EventCell {
        let identy = "MKBXDAlarmV2EventCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDAlarmV2EventCell {
            return cell
        }
        return MKBXDAlarmV2EventCell(style: .default, reuseIdentifier: identy)
    }
}
