//
//  BeaconSweepViewController.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/9/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class BeaconSweepViewController: UIViewController, CLLocationManagerDelegate, UIWebViewDelegate {
    // required
    var uuid: UUID?
    var majorId: Int?
    var edgeId: Int?
    var startNode: Int?
    var endNode: Int?
    var beaconMinors = Set<Int>()
    // optional
    var nextURI: URL?
    var workerId: Int?
    var baseURL = "https://luzdeploy-prod.herokuapp.com"

    
    static let storyboardId = "BeaconSweeper"
    private let beaconManager = CLLocationManager()
    private var presentBeaconMinors = Set<Int>()
    private var isRangingBeacon = false
    private var beaconRegion: CLBeaconRegion!
    private var mapURL: URL? = nil
    
    @IBOutlet weak var startButton: UIButton?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var instructions: UILabel?
    
    func setupBeaconManager() {
        let authstate = CLLocationManager.authorizationStatus()
        if(authstate == .notDetermined){
            print("Not Authorised")
            self.beaconManager.requestAlwaysAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBeaconManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        beaconRegion = CLBeaconRegion(
            proximityUUID: self.uuid!,
            major: CLBeaconMajorValue(self.majorId!),
            identifier: "cmaccess"
        )
        
        self.mapURL = URL(string: "\(self.baseURL)/map/?advanced&hidden&edge=\(self.edgeId!)")!
        self.webView.loadRequest(URLRequest(url: mapURL!))
        self.statusLabel?.text = "Status: Not Scanning"
        self.instructions?.text = "Go to node \(self.startNode!) in the map above. Then press the start button below."
        self.startButton?.setTitle("Start scanning", for: .normal)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isRangingBeacon {
            self.beaconManager.stopRangingBeacons(in: self.beaconRegion)
            self.isRangingBeacon = false
        }
    }
    
    func doneWebhook() {
        var request = URLRequest(url: URL(string: "\(self.baseURL)/webhook")!)
        request.httpMethod = "POST"
        let post = "message=done&wid=\(self.workerId!)"
        var postData = post.data(using: .ascii)
        let postLength = String(describing: postData?.count)
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        Utility.makeRequest(request: request) { _ in
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func sendData() {
        var request = URLRequest(url: URL(string: "\(self.baseURL)/sweep-data")!)
        request.httpMethod = "POST"
        let missingBeaconsSet = self.beaconMinors.subtracting(self.presentBeaconMinors)
        let missingBeacons = missingBeaconsSet.map(String.init)
        let presentBeacons = self.presentBeaconMinors.map(String.init)
        var postString = "missing=" + missingBeacons.joined(separator: ",")
        postString += "&present=" + presentBeacons.joined(separator: ",")
        print("\(postString)")
        request.httpBody = postString.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        Utility.makeRequest(request: request);
    }
    
    
    @IBAction func buttonPressed() {
        if !self.isRangingBeacon {
            self.beaconManager.startRangingBeacons(in: self.beaconRegion)
            self.beaconManager.delegate = self
            self.beaconManager.pausesLocationUpdatesAutomatically = false
            self.isRangingBeacon = true
            self.statusLabel?.text = "Status: Scanning"
            self.instructions?.text = "Now walk to node \(self.endNode!) at the other end of the red path. Once there, press the stop button below."
            self.startButton?.setTitle("Stop scanning", for: .normal)
        }
        else {
            self.instructions?.text = "Thanks! Redirecting you back to LuzDeploy."
            self.statusLabel?.text = "Status: Uploading"
            self.sendData()
            self.startButton?.setTitle("Start scanning", for: .normal)
            if self.workerId != nil {
                self.doneWebhook()
            } else {
               _ = self.navigationController?.popViewController(animated: true)
            }
            if self.nextURI != nil {
                Utility.openURL(url: self.nextURI!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if !self.isRangingBeacon {
            return
        }
        if beacons.count > 0 {
            for beacon: CLBeacon in beacons {
                let minorId = Int(beacon.minor)
                if self.beaconMinors.contains(minorId) {
                    self.presentBeaconMinors.insert(minorId)
                }
            }
        }
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus: CLAuthorizationStatus) {
        print(CLLocationManager.authorizationStatus())
    }
}
