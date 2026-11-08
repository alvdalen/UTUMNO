//
//  ViewLoadable.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 08.11.2026.
//

import UIKit

protocol ViewLoadable {
    associatedtype MainView: UIView
}

extension ViewLoadable where Self: UIViewController {
    var mainView: MainView {
        guard let customView = view as? MainView else {
            fatalError("Expected view to be of type \(MainView.self) but got \(type(of: view)) instead")
        }
        return customView
    }
}
