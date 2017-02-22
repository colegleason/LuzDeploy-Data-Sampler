//
//  AppDelegate.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/9/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        return true
    }
    
    
    func parseQueryString(_ query: String) -> [String: String] {
        var dict = [String: String]()
        let pairs = query.components(separatedBy: "&")
        for pair in pairs {
            let elements = pair.components(separatedBy: "=")
            let key = elements[0].removingPercentEncoding
            let val = elements[1].removingPercentEncoding
            dict[key!] = val
        }
        return dict
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("url recieved: \(url)")
        print("query string: \(url.query)")
        print("host: \(url.host)")
        print("url path: \(url.path)")
        let dict = self.parseQueryString(url.query!)
        print("query dict: \(dict)")
        if (url.host == "beaconsweeper") {
            self.runScanBeacons(dict)
        } else if (url.host == "datasampler") {
            self.runFingerprinting(dict)
        }
        
        return true
    }
    
    // luzdeploy://datasampler?major=65535&locations=3,-10,10;4,-9,9&wid=1
    func runFingerprinting(_ dict: [String: String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let fingerprinter = storyboard.instantiateViewController(withIdentifier: FingerprintViewController.storyboardId) as? FingerprintViewController {
            fingerprinter.uuid = UUID(uuidString: "F7826DA6-4FA2-4E98-8024-BC5B71E0893E")!
            fingerprinter.majorId = Int(dict["major"] ?? "")
            fingerprinter.fingerprintLocations = Utility.queryParamToLocations(param: dict["locations"] ?? "")
            fingerprinter.nextURI = URL(string: dict["next"] ?? "")
            fingerprinter.workerId = Int(dict["wid"] ?? "")
            if let baseUrl = dict["base"] {
                fingerprinter.baseURL = baseUrl
            }
            let tabVC = window?.rootViewController as? UITabBarController
            tabVC?.selectedIndex = 1
            let navVC: UINavigationController = tabVC?.selectedViewController as! UINavigationController
            navVC.pushViewController(fingerprinter, animated: true)
        }
    }
    
    // luzdeploy://beaconsweeper?major=65535&beacons=1,2&edge=1&start=1&end=2&wid=1
    func runScanBeacons(_ dict: [String: String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let beaconSweeper = storyboard.instantiateViewController(withIdentifier: BeaconSweepViewController.storyboardId) as? BeaconSweepViewController {
            
            beaconSweeper.uuid = UUID(uuidString: "F7826DA6-4FA2-4E98-8024-BC5B71E0893E")!
            beaconSweeper.majorId = Int(dict["major"] ?? "")
            beaconSweeper.beaconMinors = Utility.beaconListToSet(beaconList: dict["beacons"] ?? "")
            beaconSweeper.edgeId = Int(dict["edge"] ?? "")
            beaconSweeper.startNode = Int(dict["start"] ?? "")
            beaconSweeper.endNode = Int(dict["end"] ?? "")
            beaconSweeper.nextURI = URL(string: dict["next"] ?? "")
            beaconSweeper.workerId = Int(dict["wid"] ?? "")
            if let baseUrl = dict["base"] {
                beaconSweeper.baseURL = baseUrl
            }
            let tabVC = window?.rootViewController as? UITabBarController
            tabVC?.selectedIndex = 0
            let navVC: UINavigationController = tabVC?.selectedViewController as! UINavigationController
            navVC.pushViewController(beaconSweeper, animated: true)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

