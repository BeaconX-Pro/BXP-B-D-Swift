//
//  MKBXDAlarmEventDBCountCell.swift
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

public final class MKBXDAlarmEventDBCountCellModel: NSObject {
    public var index: Int = 0
    public var msg: String = ""
    public var mainCount: String = ""
    public var subCount: String = ""
}

public protocol MKBXDAlarmEventDBCountCellDelegate: AnyObject {
    func bxd_alarmEventDBCell_mainClearButtonPressed(_ index: Int)
    func bxd_alarmEventDBCell_subClearButtonPressed(_ index: Int)
}

public final class MKBXDAlarmEventDBCountCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDAlarmEventDBCountCellDelegate?

    public var dataModel: MKBXDAlarmEventDBCountCellModel? {
        didSet {
            msgLabel.text = dataModel?.msg ?? ""
            mainCountLabel.text = dataModel?.mainCount ?? ""
            subCountLabel.text = dataModel?.subCount ?? ""
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        return label
    }()

    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(13)
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

    private lazy var mainClearButton: UIButton = {
        return MKSwiftUIAdaptor.createRoundedButton(title: "Clear",
                                                    target: self,
                                                    action: #selector(mainClearButtonPressed))
    }()

    private lazy var subLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(13)
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

    private lazy var subClearButton: UIButton = {
        return MKSwiftUIAdaptor.createRoundedButton(title: "Clear",
                                                    target: self,
                                                    action: #selector(subClearButtonPressed))
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(mainLabel)
        contentView.addSubview(mainCountLabel)
        contentView.addSubview(mainClearButton)
        contentView.addSubview(subLabel)
        contentView.addSubview(subCountLabel)
        contentView.addSubview(subClearButton)
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
        mainClearButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(buttonWidth)
            make.top.equalTo(msgLabel.snp.bottom).offset(10)
            make.height.equalTo(buttonHeight)
        }
        mainLabel.snp.remakeConstraints { make in
            make.left.equalTo(30)
            make.width.equalTo(120)
            make.centerY.equalTo(mainClearButton)
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
        mainCountLabel.snp.remakeConstraints { make in
            make.right.equalTo(mainClearButton.snp.left).offset(-10)
            make.width.equalTo(150)
            make.centerY.equalTo(mainClearButton)
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
        subClearButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(buttonWidth)
            make.top.equalTo(mainClearButton.snp.bottom).offset(10)
            make.height.equalTo(buttonHeight)
        }
        subLabel.snp.remakeConstraints { make in
            make.left.equalTo(30)
            make.width.equalTo(120)
            make.centerY.equalTo(subClearButton)
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
        subCountLabel.snp.remakeConstraints { make in
            make.right.equalTo(subClearButton.snp.left).offset(-10)
            make.width.equalTo(150)
            make.centerY.equalTo(subClearButton)
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
    }

    @objc private func mainClearButtonPressed() {
        delegate?.bxd_alarmEventDBCell_mainClearButtonPressed(dataModel?.index ?? 0)
    }

    @objc private func subClearButtonPressed() {
        delegate?.bxd_alarmEventDBCell_subClearButtonPressed(dataModel?.index ?? 0)
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDAlarmEventDBCountCell {
        let identy = "MKBXDAlarmEventDBCountCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDAlarmEventDBCountCell {
            return cell
        }
        return MKBXDAlarmEventDBCountCell(style: .default, reuseIdentifier: identy)
    }
}
