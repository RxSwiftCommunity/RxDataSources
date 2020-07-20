//
//  TitleSteperTableViewCell.swift
//  RxDataSources
//
//  Created by Segii Shulga on 4/26/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit

class TitleSteperTableViewCell: UITableViewCell {

   @IBOutlet private weak var stepper: UIStepper!
   @IBOutlet private  weak var titleLabel: UILabel!

    func configure(title: String) {
        titleLabel.text = title
    }

}
