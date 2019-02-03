//
//  AnimationConfiguration.swift
//  RxDataSources
//
//  Created by Esteban Torres on 5/2/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import Foundation
    import UIKit

    public typealias TableViewAnimationConfiguration = AnimationConfiguration<UITableView.Animation>
    
    /**
     Exposes custom animation styles for insertion, deletion and reloading behavior.
     */
    public struct AnimationConfiguration<Animation> {
        public let insertAnimation: Animation
        public let reloadAnimation: Animation
        public let deleteAnimation: Animation
    }
    
    public extension AnimationConfiguration where Animation == UITableView.Animation {
        
        init(insertAnimation: Animation = .automatic,
             reloadAnimation: Animation = .automatic,
             deleteAnimation: Animation = .automatic) {
            self.insertAnimation = insertAnimation
            self.reloadAnimation = reloadAnimation
            self.deleteAnimation = deleteAnimation
        }
    }
#endif
