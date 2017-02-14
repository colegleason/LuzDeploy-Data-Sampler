//
//  Utility.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/9/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    static func makeRequest(request: URLRequest, completion: ((Data) -> Void)! = nil) {
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard error == nil else {
                print("error=\(error)")
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            print(responseData as NSData)
            if (completion != nil) {
                completion(responseData)
            }
        }
        task.resume()
    }
    
    static func openURL(url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:],
                                      completionHandler: {
                                        (success) in
                                        print("Open \(url): \(success)")
            })
        } else {
            let success = UIApplication.shared.openURL(url)
            print("Open \(url): \(success)")
        }
    }
    
    static func beaconListToSet(beaconList: String) -> Set<Int> {
        var result = Set<Int>()
        for split: String in beaconList.components(separatedBy: ",") {
            if split.contains("-") {
                var range = split.components(separatedBy: "-")
                let start = Int(range[0])!
                let end = Int(range[1])!
                for beaconId in start...end {
                    result.insert(beaconId)
                }
            }
            else {
                let beaconId = Int(split)
                result.insert(beaconId!)
            }
        }
        return result
    }
}
