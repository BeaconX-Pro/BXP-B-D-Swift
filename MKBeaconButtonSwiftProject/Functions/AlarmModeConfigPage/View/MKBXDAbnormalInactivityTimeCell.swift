//
//  MKBXDAbnormalInactivityTimeCell.swift
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

public final class MKBXDAbnormalInactivityTimeCellModel: NSObject {
    public var time: String = ""
    public var advTime: String = ""
}

// MARK: - Delegate

public protocol MKBXDAbnormalInactivityTimeCellDelegate: AnyObject {
    func bxd_abnormalInactivityTimeChanged(_ time: String)
}

// MARK: - Cell

public final class MKBXDAbnormalInactivityTimeCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDAbnormalInactivityTimeCellDelegate?

    public var dataModel: MKBXDAbnormalInactivityTimeCellModel? {
        didSet {
            guard let model = dataModel else { return }
            textField.text = model.time
            noteMsgLabel.text = "*After device keep static for \(model.time)s, abnormal inactivity alarm will be triggered and start advertising for \(model.advTime)s."
            setNeedsLayout()
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Abnormal inactivity time"
        return label
    }()

    private lazy var textField: MKSwiftTextField = {
        // ⚠️ 按工程实际 MKSwiftTextField 接口调整
        let tf = MKSwiftUIAdaptor.createTextField(text: "",
                                                        placeholder: "1~65535",
                                                        textType: .realNumberOnly)
        tf.maxLength = 5
        tf.textChangedBlock = { [weak self] text in
            guard let self = self else { return }
            self.noteMsgLabel.text = "*After device keep static for \(text)s, abnormal inactivity alarm will be triggered and start advertising for \(self.dataModel?.advTime ?? "")s."
            self.delegate?.bxd_abnormalInactivityTimeChanged(text)
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
        let noteSize = (noteMsgLabel.text ?? "").size(withFont: noteMsgLabel.font,
                                                      maxSize: CGSize(width: MKScreen.width - 30, height: .greatestFiniteMagnitude))
        noteMsgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.height.equalTo(noteSize.height)
        }
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDAbnormalInactivityTimeCell {
        let identy = "MKBXDAbnormalInactivityTimeCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDAbnormalInactivityTimeCell {
            return cell
        }
        return MKBXDAbnormalInactivityTimeCell(style: .default, reuseIdentifier: identy)
    }
}
