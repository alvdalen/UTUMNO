//
//  BaseViewController.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 08.11.2026.
//

import UIKit

class BaseViewController<ViewType: UIView>: UIViewController, ViewLoadable {
    
    typealias MainView = ViewType
    
    override func loadView() {
        let customView = MainView()
        view = customView
    }
}
