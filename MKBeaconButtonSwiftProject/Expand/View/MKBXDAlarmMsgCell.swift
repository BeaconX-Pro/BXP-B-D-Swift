//
//  MKBXDAlarmMsgCell.swift
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

public final class MKBXDAlarmMsgCellModel: NSObject {
    public var msg: String = ""

    public func fetchCellHeight() -> CGFloat {
        let msgSize = NSString.mk_size(withText: msg,
                                       andFont: MKFont.font(13),
                                       andMaxSize: CGSize(width: MKScreen.width - 2 * 15, height: .greatestFiniteMagnitude))
        return msgSize.height + 20
    }
}

// MARK: - Cell

public final class MKBXDAlarmMsgCell: MKSwiftBaseCell {

    public weak var delegate: AnyObject?

    public var dataModel: MKBXDAlarmMsgCellModel? {
        didSet {
            msgLabel.text = dataModel?.msg ?? ""
            setNeedsLayout()
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 118/255.0, green: 118/255.0, blue: 118/255.0, alpha: 1)
        label.textAlignment = .left
        label.font = MKFont.font(13)
        label.numberOfLines = 0
        return label
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let msgSize = NSString.mk_size(withText: msgLabel.text ?? "",
                                       andFont: msgLabel.font,
                                       andMaxSize: CGSize(width: MKScreen.width - 2 * 15, height: .greatestFiniteMagnitude))
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(msgSize.height)
        }
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDAlarmMsgCell {
        let identy = "MKBXDAlarmMsgCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDAlarmMsgCell {
            return cell
        }
        return MKBXDAlarmMsgCell(style: .default, reuseIdentifier: identy)
    }
}
