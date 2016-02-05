//
//  AnimationConfiguration.swift
//  RxDataSources
//
//  Created by Esteban Torres on 5/2/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import Foundation

/**
   Exposes custom animation styles for insertion, deletion and reloading behavior.
*/
public struct AnimationConfiguration {
  let insertAnimation: UITableViewRowAnimation
  let reloadAnimation: UITableViewRowAnimation
  let deleteAnimation: UITableViewRowAnimation
  
  init(insertAnimation: UITableViewRowAnimation = .Automatic,
    reloadAnimation: UITableViewRowAnimation = .Automatic,
    deleteAnimation: UITableViewRowAnimation = .Automatic) {
      self.insertAnimation = insertAnimation
      self.reloadAnimation = reloadAnimation
      self.deleteAnimation = deleteAnimation
  }
}