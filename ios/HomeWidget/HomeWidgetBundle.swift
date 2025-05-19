//
//  HomeWidgetBundle.swift
//  HomeWidget
//
//  Created by Shrit Shrivastava on 20/05/25.
//

import WidgetKit
import SwiftUI

@main
struct HomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeWidget()
        HomeWidgetControl()
        HomeWidgetLiveActivity()
    }
}
