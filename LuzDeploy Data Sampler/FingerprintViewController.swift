//
//  FingerprintViewController.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/14/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreBluetooth

class FingerprintViewController: UIViewController, CLLocationManagerDelegate, UIWebViewDelegate, CBCentralManagerDelegate {

    // required
    var uuid: UUID?
    var majorId: Int?
    var fingerprintLocations: [FingerprintLocation]?

    // optional
    var nextURI: URL?
    var workerId: Int?
    var baseURL = "https://luzdeploy-staging.herokuapp.com"
    var fingerprintSampleTime = 5.0 // seconds
    
    private let beaconManager = CLLocationManager()
    private var bluetoothManager: CBCentralManager?
    private var isRangingBeacon = false
    private var beaconRegion: CLBeaconRegion?
    private var fingerprints = [Fingerprint]()
    private var currentLocation = 0
    private var currentFingerprint: Fingerprint?
    private var timeAtPress : Date?
    
    @IBOutlet weak var startButton: UIButton?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var instructions: UILabel?
    
    static let storyboardId = "Fingerprinter"
    
    func loadMap(forLocation location: FingerprintLocation) {
        let mapURL = URL(string: "\(self.baseURL)/map/?advanced&hidden&layer=\(location.floor)&lat=\(location.lat)&long=\(location.long)")!
        print("\(mapURL)")
        self.webView.loadRequest(URLRequest(url: mapURL))
    }
    
    func setupBeaconManager() {
        beaconRegion = CLBeaconRegion(
            proximityUUID: self.uuid ?? UUID(),
            major: CLBeaconMajorValue(self.majorId ?? 0),
            identifier: "cmaccess"
        )
        let authstate = CLLocationManager.authorizationStatus()
        if(authstate == .notDetermined){
            print("Not Authorised")
            self.beaconManager.requestAlwaysAuthorization()
        }
        self.beaconManager.delegate = self
        self.beaconManager.pausesLocationUpdatesAutomatically = false
        
        self.bluetoothManager = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBeaconManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareForNewFingerprint()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isRangingBeacon {
            self.beaconManager.stopRangingBeacons(in: self.beaconRegion!)
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
        Utility.makeRequest(request: request)
    }
    
    func sendData() {
        var request = URLRequest(url: URL(string: "\(self.baseURL)/fingerprint-data")!)
        do {
            print("\(self.fingerprints)")
            request.httpBody = try JSONSerialization.data(
                withJSONObject: self.fingerprints.map { $0.serialize()}
            )
            print("\(request.httpBody)")
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            Utility.makeRequest(request: request);
        } catch {
            return
        }
    }

    func updateButtonTitle(timer: Timer) {
        let elapsed = Date().timeIntervalSince(timeAtPress!)
        if elapsed < fingerprintSampleTime {
            let diff = Int(fingerprintSampleTime - elapsed) + 1
            self.startButton?.setTitle("\(diff) seconds", for: .normal)
        } else {
            timer.invalidate()
            self.samplingFinished()
        }
    }
    
    func samplingFinished() {
        saveFingerprint()
        self.currentLocation += 1
        if currentLocation >= (fingerprintLocations?.count)! {
            finish()
        } else {
            prepareForNewFingerprint()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != CBManagerState.poweredOn {
            let alert = UIAlertController(title: "Bluetooth Required", message: "Please turn bluetooth on to collect data", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.startButton?.isEnabled = false
        } else {
            self.startButton?.isEnabled = true
        }
    }
    
    @IBAction func buttonPressed() {
        self.isRangingBeacon = true
        beaconManager.startRangingBeacons(in: self.beaconRegion!)
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
        self.timeAtPress = Date()
        self.statusLabel?.text = "Status: Scanning"
        self.instructions?.text = "Now turn around in place slowly until the timer runs out."
        self.startButton?.isEnabled = false
    }
    
    func prepareForNewFingerprint() {
        let location = self.fingerprintLocations?[self.currentLocation]
        self.currentFingerprint = Fingerprint(
            location: location!,
            sample: []
        )
        self.loadMap(forLocation: location!)
        self.startButton?.isEnabled = true
        self.statusLabel?.text = "Status: Not Scanning"
        self.instructions?.text = "Go to the location marked on the map. Then press the button to scan for \(Int(self.fingerprintSampleTime)) seconds. You will be asked to turn while scanning."
        self.startButton?.setTitle("Start Sampling", for: .normal)
    }
    
    func finish() {
        self.instructions?.text = "Thanks! Redirecting you back to LuzDeploy."
        self.statusLabel?.text = "Status: Uploading"
        self.sendData()
        self.startButton?.setTitle("Start Sampling", for: .normal)
        if self.workerId != nil {
            self.doneWebhook()
        }
        _ = self.navigationController?.popViewController(animated: true)
        if self.nextURI != nil {
            Utility.openURL(url: self.nextURI!)
        }
    }
    
    func saveFingerprint() {
        print("\(self.currentFingerprint)")
        self.fingerprints.append(self.currentFingerprint!)
        self.currentFingerprint = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if !self.isRangingBeacon {
            return
        }
        if beacons.count > 0 {
            for beacon: CLBeacon in beacons {
                let dataPoint = (Int(beacon.minor), beacon.rssi)
                self.currentFingerprint?.sample.append(dataPoint)
            }
        }
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus: CLAuthorizationStatus) {
        print(CLLocationManager.authorizationStatus())
    }
}
