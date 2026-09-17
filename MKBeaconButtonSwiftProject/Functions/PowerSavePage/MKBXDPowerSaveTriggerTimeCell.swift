//
//  MKBXDPowerSaveTriggerTimeCell.swift
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

public final class MKBXDPowerSaveTriggerTimeCellModel: NSObject {
    public var time: String = ""

    /// ✅ 动态计算 cell 高度
    public func cellHeight() -> CGFloat {
        // 顶部 offset + textField 高度 + note 顶部 offset + note 高度 + 底部 offset
        let topOffset: CGFloat = 15
        let textFieldHeight: CGFloat = 30
        let noteTopOffset: CGFloat = 10
        let bottomOffset: CGFloat = 15

        // note 文案
        let noteMsg = "*After device keep static for \(time)s, it will stop advertising and disable alarm mode to enter into power saving mode until device moves. "
        let noteSize = NSString.mk_size(withText: noteMsg,
                                        andFont: MKFont.font(11),
                                        andMaxSize: CGSize(width: MKScreen.width - 30, height: .greatestFiniteMagnitude))

        return topOffset + textFieldHeight + noteTopOffset + noteSize.height + bottomOffset
    }
}

// MARK: - Delegate

public protocol MKBXDPowerSaveTriggerTimeCellDelegate: AnyObject {
    func bxd_powerSaveTriggerTimeChanged(_ time: String)
}

// MARK: - Cell

public final class MKBXDPowerSaveTriggerTimeCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDPowerSaveTriggerTimeCellDelegate?

    public var dataModel: MKBXDPowerSaveTriggerTimeCellModel? {
        didSet {
            guard let model = dataModel else { return }
            textField.text = model.time
            noteMsgLabel.text = "*After device keep static for \(model.time)s, it will stop advertising and disable alarm mode to enter into power saving mode until device moves. "
            setNeedsLayout()
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Static trigger time"
        return label
    }()

    private lazy var textField: MKSwiftTextField = {
        let tf = MKSwiftUIAdaptor.createNormalTextField(text: "",
                                                        placeHolder: "1~65535",
                                                        textType: .realNumberOnly)
        tf.maxLength = 5
        tf.textChangedBlock = { [weak self] text in
            guard let self = self else { return }
            self.noteMsgLabel.text = "*After device keep static for \(text)s, it will stop advertising and disable alarm mode to enter into power saving mode until device moves. "
            self.setNeedsLayout()
            self.delegate?.bxd_powerSaveTriggerTimeChanged(text)
        }
        return tf
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(11)
        label.text = "s"
        return label
    }()

    private lazy var noteMsgLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = MKFont.font(11)
        label.numberOfLines = 0
        return label
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(textField)
        contentView.addSubview(unitLabel)
        contentView.addSubview(noteMsgLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        unitLabel.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(30)
            make.centerY.equalTo(textField)
            make.height.equalTo(MKFont.font(11).lineHeight)
        }
        textField.snp.remakeConstraints { make in
            make.right.equalTo(unitLabel.snp.left).offset(-5)
            make.width.equalTo(100)
            make.top.equalTo(15)
            make.height.equalTo(30)
        }
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(textField.snp.left).offset(-10)
            make.centerY.equalTo(textField)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        let noteSize = NSString.mk_size(withText: noteMsgLabel.text ?? "",
                                        andFont: noteMsgLabel.font,
                                        andMaxSize: CGSize(width: MKScreen.width - 30, height: .greatestFiniteMagnitude))
        noteMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.height.equalTo(noteSize.height)
        }
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDPowerSaveTriggerTimeCell {
        let identy = "MKBXDPowerSaveTriggerTimeCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDPowerSaveTriggerTimeCell {
            return cell
        }
        return MKBXDPowerSaveTriggerTimeCell(style: .default, reuseIdentifier: identy)
    }
}
