//
//  ImageTitleTableViewCell.swift
//  RxDataSources
//
//  Created by Segii Shulga on 4/26/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit

class ImageTitleTableViewCell: UITableViewCell {

   @IBOutlet private weak var cellImageView: UIImageView!
   @IBOutlet private weak var titleLabel: UILabel!

    func configure(image: UIImage, title: String) {
        cellImageView.image = image
        titleLabel.text = title
    }
}
