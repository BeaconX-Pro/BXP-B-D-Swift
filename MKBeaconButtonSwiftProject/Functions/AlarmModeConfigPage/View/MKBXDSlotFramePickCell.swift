//
//  MKBXDSlotFramePickCell.swift
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

public final class MKBXDSlotFramePickCellModel: NSObject {
    public var frameType: MKBXDSlotType = .alarmInfo
}

// MARK: - Delegate

public protocol MKBXDSlotFramePickCellDelegate: AnyObject {
    func bxd_slotFrameTypeChanged(_ frameType: MKBXDSlotType)
}

// MARK: - Cell

public final class MKBXDSlotFramePickCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDSlotFramePickCellDelegate?

    public var dataModel: MKBXDSlotFramePickCellModel? {
        didSet {
            guard let model = dataModel else { return }
            pickerView.reloadAllComponents()
            frameType = model.frameType
            pickerView.selectRow(model.frameType.rawValue, inComponent: 0, animated: true)
        }
    }

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var leftIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_slotFrameType.png")
        return iv
    }()

    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Frame type"
        return label
    }()

    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.layer.masksToBounds = true
        picker.layer.borderColor = MKColor.navBar.cgColor
        picker.layer.borderWidth = 0.5
        picker.layer.cornerRadius = 4
        return picker
    }()

    private lazy var dataList: [String] = ["Alarm info", "UID", "iBeacon"]
    private var frameType: MKBXDSlotType = .alarmInfo

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(backView)
        backView.addSubview(leftIcon)
        backView.addSubview(typeLabel)
        backView.addSubview(pickerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        leftIcon.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.width.height.equalTo(22)
            make.centerY.equalTo(backView)
        }
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(leftIcon.snp.right).offset(15)
            make.width.equalTo(100)
            make.centerY.equalTo(backView)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        pickerView.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(100)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
        }
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDSlotFramePickCell {
        let identy = "MKBXDSlotFramePickCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDSlotFramePickCell {
            return cell
        }
        return MKBXDSlotFramePickCell(style: .default, reuseIdentifier: identy)
    }
}

// MARK: - UIPickerViewDataSource / Delegate

extension MKBXDSlotFramePickCell: UIPickerViewDataSource, UIPickerViewDelegate {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataList.count
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        30
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel: UILabel
        if let label = view as? UILabel {
            titleLabel = label
        } else {
            titleLabel = UILabel()
            titleLabel.textColor = MKColor.defaultText
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.textAlignment = .center
            titleLabel.font = MKFont.font(12)
        }
        if row == frameType.rawValue {
            titleLabel.attributedText = self.pickerView(pickerView, attributedTitleForRow: row, forComponent: component)
        } else {
            titleLabel.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        }
        return titleLabel
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < dataList.count else { return nil }
        return dataList[row]
    }

    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard row < dataList.count else { return nil }
        return MKSwiftUIAdaptor.createAttributedString(strings:[dataList[row]],
                                                 fonts: [MKFont.font(13)],
                                                 colors: [MKColor.navBar])
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        frameType = MKBXDSlotType(rawValue: row) ?? .alarmInfo
        pickerView.reloadAllComponents()
        delegate?.bxd_slotFrameTypeChanged(frameType)
    }
}
