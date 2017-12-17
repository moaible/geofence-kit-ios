//
//  GeofenceConsoleViewController.swift
//  GeofenceConsole
//
//  Created by AGDC Dev3 on 2017/12/17.
//  Copyright © 2017年 moaible. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class GeofenceConsoleViewController: UIViewController {
    
    var builder = GeofenceBuilder()
    var arrowsBackground: Bool {
        get {
            return Defaults[.arrowsBackground]
        }
        set {
            Defaults[.arrowsBackground] = newValue
        }
    }
    var accuracySegmentIndex: Int {
        get {
            return Defaults[.accuracySegmentIndex]
        }
        set {
            
            Defaults[.accuracySegmentIndex] = newValue
        }
    }
    var reportDistanceValue: Float {
        get {
            if case .none = Defaults[.reportDistanceValue] {
                Defaults[.reportDistanceValue] = 100
            }
            return Float(Defaults[.reportDistanceValue]!)
        }
        set {
            Defaults[.reportDistanceValue] = Double(newValue)
        }
    }
    
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var arrowBackgroundSwitch: UISwitch!
    @IBOutlet weak var reportDistanceSlider: UISlider!
    @IBOutlet weak var reportDistanceLabel: UILabel!
    @IBOutlet weak var accuracySegment: UISegmentedControl!
    @IBOutlet weak var addGeofenceButton: UIButton!
    @IBOutlet weak var geofenceTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        geofenceTableView.delegate = self
        geofenceTableView.dataSource = self
        NotificationCenter.default.addObserver(
        forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil) { _ in
            self.configure()
        }
        builder.arrowsBackground = arrowsBackground
        builder.reportDistance = Double(reportDistanceValue)
        builder.accuracy = accuracy(at: accuracySegmentIndex)
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configure() {
        arrowBackgroundSwitch.isOn = arrowsBackground
        accuracySegment.selectedSegmentIndex = accuracySegmentIndex
        reportDistanceSlider.setValue(reportDistanceValue, animated: false)
        reportDistanceLabel.text = displayReportDistance(at: reportDistanceValue)
        
        do {
            let mode = try builder.ensurePermission()
            privacyLabel.text = mode.description
            enableUI(true)
        } catch {
            if case Geofence.Error.permissionNotDetermined = error {
                builder.requestPermission(mode: .always) { [weak self] mode, error in
                    if let mode = mode {
                        self?.privacyLabel.text = mode.description
                        self?.enableUI(true)
                    } else if let error = error {
                        self?.privacyLabel.text = error.description
                        self?.enableUI(false)
                    }
                }
                privacyLabel.text = "unset privacy"
            } else if let error = error as? Geofence.Error {
                privacyLabel.text = error.description
                enableUI(false)
            }
        }
    }
    
    func enableUI(_ isEnabled: Bool) {
        arrowBackgroundSwitch.isEnabled = isEnabled
        accuracySegment.isEnabled = isEnabled
        reportDistanceSlider.isEnabled = isEnabled
        reportDistanceLabel.isEnabled = isEnabled
        addGeofenceButton.isEnabled = isEnabled
    }
    
    func accuracy(at index: Int) -> Geofence.Accuracy {
        let accuracies: [Geofence.Accuracy] = [
            .threeKilometers,
            .kilometer,
            .hundredMeters,
            .nearestTenMeters,
            .best
        ]
        return accuracies[index]
    }
    
    func displayReportDistance(at value: Float) -> String? {
        return "\(value)".split(separator: ".").first.map(String.init)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButton(withTitle: "OK")
        alert.show()
    }
    
    // MARK: - Action
    
    @IBAction func didChangeArrowsBackgroundSwitch(_ sender: UISwitch) {
        arrowsBackground = sender.isOn
        builder.arrowsBackground = sender.isOn
        
    }
    
    @IBAction func didChangeReportDistanceSlider(_ sender: UISlider) {
        reportDistanceValue = sender.value
        reportDistanceLabel.text = displayReportDistance(at: sender.value)
        builder.reportDistance = Double(sender.value)
    }
    
    @IBAction func didChangeAccuracySegment(_ sender: UISegmentedControl) {
        accuracySegmentIndex = sender.selectedSegmentIndex
        builder.accuracy = accuracy(at: sender.selectedSegmentIndex)
    }
    
    @IBAction func didTapAddGeofenceButton(_ sender: UIButton) {
        enableUI(false)
        builder.fetchCurrentLocation { [weak self] (location, error) in
            if let error = error {
                self?.showAlert(title: "Failed", message: error.localizedDescription)
            } else if let location = location {
                print(location)
                self?.builder.build(geofence: Geofence(
                    identifier: "lat:\(location.latitude),lng:\(location.longitude)",
                    radius: 100,
                    location: location))
            }
            self?.geofenceTableView.reloadData()
            self?.enableUI(true)
        }
//        builder.fetchCurrentLocation { [weak self] (location, error) in
//            if let error = error {
//                self?.showAlert(title: "location error", message: error.localizedDescription)
//                return
//            }
//            self?.builder.build(geofence: .init(
//                identifier: "rad:100,lat:\(location!.latitude),lon:\(location!.longitude)",
//                radius: 100,
//                location: location!))
//            { [weak self] error in
//                self?.enableUI(true)
//                if let error = error {
//                    self?.showAlert(title: "追加エラー", message: error.localizedDescription)
//                }
//                self?.geofenceTableView.reloadData()
//            }
//        }
    }
    
    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GeofenceConsoleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "GeofenceConsoleViewController")
        let identifier = builder.findAllGeofenceID()[indexPath.row]
        cell.textLabel?.text = identifier
        cell.detailTextLabel?.text = "connecting..."
        builder.fetchGeofenceState(identifier: identifier) { state in
            cell.detailTextLabel?.text = "\(state)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return builder.findAllGeofenceID().count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
