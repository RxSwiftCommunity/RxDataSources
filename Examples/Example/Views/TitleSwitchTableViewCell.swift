//
//  TitleSwitchTableViewCell.swift
//  RxDataSources
//
//  Created by Segii Shulga on 4/26/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit

class TitleSwitchTableViewCell: UITableViewCell {


   @IBOutlet private weak var switchControl: UISwitch!
   @IBOutlet private weak var titleLabel: UILabel!

    func configure(title: String, isEnabled: Bool) {
        switchControl.isOn = isEnabled
        titleLabel.text = title
    }
}
