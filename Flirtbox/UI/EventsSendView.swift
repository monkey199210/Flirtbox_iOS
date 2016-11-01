//
//  EventsSendView.swift
//  Quokka
//
//  Created by Azamat Valitov on 27.10.15.
//  Copyright © 2015 Flirtbox. All rights reserved.
//

import UIKit

class EventsSendView: UIView {
    var otherView: UIView?
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        if hitView == self {
            return otherView
        }
        return hitView
    }
}
