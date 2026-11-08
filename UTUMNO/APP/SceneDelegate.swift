//
//  SceneDelegate.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 07.11.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        window?.overrideUserInterfaceStyle = .light
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        window?.rootViewController = HomeViewController()
    }
}
