//
//  MKBXDNotificationTypePickerView.swift
//  MKBeaconXDButton
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

private let pickerViewWidth: CGFloat = 110

// MARK: - Model

public final class MKBXDNotificationTypePickerViewModel: NSObject {
    /// 是否显示顶部按钮和按钮那一行的 label
    public var needButton: Bool = false
    /// 跟 button 一行的 msgLabel 显示内容（needButton=YES 有效）
    public var msg: String = ""
    /// 蓝色按钮标题（可以选择不显示）（needButton=YES 有效）
    public var buttonTitle: String = ""
    /// pickerView 一行的 label 显示内容
    public var typeLabelMsg: String = ""
    /// BXP-B-D:   @[@"Silent",@"LED",@"Buzzer",@"LED+Buzzer"]
    /// BXP-CR:    @[@"Silent",@"LED",@"Vibration",@"Buzzer",@"LED+Vibration",@"LED+Buzzer"]
    public var typeList: [String] = []
}

// MARK: - Delegate

public protocol MKBXDNotificationTypePickerViewDelegate: AnyObject {
    func bxd_notiTypePickerViewTypeChanged(_ type: Int)
    func bxd_notiTypePickerViewButtonPressed()
}

// MARK: - View

public final class MKBXDNotificationTypePickerView: UIView {

    public weak var delegate: MKBXDNotificationTypePickerViewDelegate?

    public var dataModel: MKBXDNotificationTypePickerViewModel? {
        didSet {
            guard let model = dataModel else { return }
            dataList.removeAll()
            dataList.append(contentsOf: model.typeList)
            msgLabel.text = model.msg
            dismissButton.setTitle(model.buttonTitle, for: .normal)
            msgLabel.isHidden = !model.needButton
            dismissButton.isHidden = !model.needButton
            lineView.isHidden = !model.needButton
            typeLabel.text = model.typeLabelMsg
            setNeedsLayout()
        }
    }

    // MARK: - Subviews

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        return label
    }()

    private lazy var dismissButton: UIButton = {
        return MKSwiftUIAdaptor.createRoundedButton(title: "",
                                                    target: self,
                                                    action: #selector(dismissButtonPressed))
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        return view
    }()

    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.numberOfLines = 0
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

    private var dataList: [String] = []
    private var alarmType: Int = 0

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(msgLabel)
        addSubview(dismissButton)
        addSubview(lineView)
        addSubview(typeLabel)
        addSubview(pickerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        let typeMsgSize = NSString.mk_size(withText: typeLabel.text ?? "",
                                           andFont: typeLabel.font,
                                           andMaxSize: CGSize(width: MKScreen.width - 3 * 15 - pickerViewWidth, height: .greatestFiniteMagnitude))
        if dataModel?.needButton == true {
            dismissButton.snp.remakeConstraints { make in
                make.right.equalTo(-15)
                make.width.equalTo(80)
                make.top.equalTo(10)
                make.height.equalTo(40)
            }
            msgLabel.snp.remakeConstraints { make in
                make.left.equalTo(15)
                make.right.equalTo(dismissButton.snp.left).offset(-15)
                make.centerY.equalTo(dismissButton)
                make.height.equalTo(MKFont.font(15).lineHeight)
            }
            lineView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(dismissButton.snp.bottom).offset(11)
                make.height.equalTo(10)
            }
            pickerView.snp.remakeConstraints { make in
                make.right.equalTo(-15)
                make.width.equalTo(pickerViewWidth)
                make.top.equalTo(lineView.snp.bottom).offset(10)
                make.bottom.equalTo(-10)
            }
            typeLabel.snp.remakeConstraints { make in
                make.left.equalTo(15)
                make.right.equalTo(pickerView.snp.left).offset(-15)
                make.centerY.equalTo(pickerView)
                make.height.equalTo(typeMsgSize.height)
            }
            return
        }
        typeLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(pickerView.snp.left).offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(typeMsgSize.height)
        }
        pickerView.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(pickerViewWidth)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
        }
    }

    // MARK: - Actions

    @objc private func dismissButtonPressed() {
        delegate?.bxd_notiTypePickerViewButtonPressed()
    }

    // MARK: - Public

    public func updateNotificationType(_ notiType: Int) {
        pickerView.reloadAllComponents()
        alarmType = notiType
        pickerView.selectRow(notiType, inComponent: 0, animated: true)
    }
}

// MARK: - UIPickerViewDataSource / Delegate

extension MKBXDNotificationTypePickerView: UIPickerViewDataSource, UIPickerViewDelegate {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

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
        if alarmType == row {
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
        return MKSwiftUIAdaptor.attributedString([dataList[row]],
                                                 fonts: [MKFont.font(13)],
                                                 colors: [MKColor.navBar])
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        alarmType = row
        pickerView.reloadAllComponents()
        delegate?.bxd_notiTypePickerViewTypeChanged(row)
    }
}
