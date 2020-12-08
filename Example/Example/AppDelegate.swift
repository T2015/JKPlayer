//
// project Example
// 
// Created By Junky on 2020/12/7
// email: <#Email#>
// github: <#github#>
//
// 
// 
// AppDelegate.swift
// desc: None






import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window?.rootViewController = ViewController()
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
    }
    

}

