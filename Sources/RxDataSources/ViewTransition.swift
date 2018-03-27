//
//  ViewTransition.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 10/22/17.
//  Copyright © 2017 kzaher. All rights reserved.
//

/// Transition between two view states
public enum ViewTransition<T> {
    /// animated transition
    case animated
    /// refresh view without animations
    case reload
    /// perform custom behavior
    case custom((T) -> Void)
}
