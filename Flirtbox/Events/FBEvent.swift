//
//  FBEvent.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 05.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import Signals

class FBEvent {
    private static let sharedEvent = FBEvent()
    
    //Authenticated
    private let onAuthenticatedSignal = Signal<(Bool)>()
    class func authenticated(success: Bool) {
        sharedEvent.onAuthenticatedSignal.fire(success)
    }
    class func onAuthenticated() -> Signal<(Bool)> {
        return sharedEvent.onAuthenticatedSignal
    }
    
    //MainPictSaved
    private let onMainPictSaved = Signal<(Bool)>()
    class func mainPickSaved(success: Bool) {
        sharedEvent.onMainPictSaved.fire(success)
    }
    class func onMainPictChanged() -> Signal<(Bool)> {
        return sharedEvent.onMainPictSaved
    }
    
    //PicturesSorted
    private let onPictChanged = Signal<(Bool)>()
    class func pictChanged(success: Bool) {
        sharedEvent.onPictChanged.fire(success)
    }
    class func onPicturesChanged() -> Signal<(Bool)> {
        return sharedEvent.onPictChanged
    }
    
    //ProfileUpdated
    private let onProfileUpdate = Signal<(Bool)>()
    class func profileUpdated(success: Bool) {
        sharedEvent.onProfileUpdate.fire(success)
    }
    class func onProfileUpdated() -> Signal<(Bool)> {
        return sharedEvent.onProfileUpdate
    }
    
    //ProfileReceived
    private let onProfileReceivedSignal = Signal<(FBUser)>()
    class func profileReceived(profile: FBUser) {
        sharedEvent.onProfileReceivedSignal.fire(profile)
    }
    class func onProfileReceived() -> Signal<(FBUser)> {
        return sharedEvent.onProfileReceivedSignal
    }
}