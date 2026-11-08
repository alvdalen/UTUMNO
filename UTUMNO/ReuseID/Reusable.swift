//
//  Reusable.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 08.11.2026.
//

protocol Reusable: AnyObject { }

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
