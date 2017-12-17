//
//  Geofence.swift
//  GeofenceConsole
//
//  Created by AGDC Dev3 on 2017/12/17.
//  Copyright © 2017年 moaible. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

struct Geofence {
    
    typealias Degreese = Double
    typealias Radius = Double
    struct Location {
        var latitude: Degreese
        var longitude: Degreese
    }
    
    var identifier: String
    var radius: Radius
    var location: Location
}

extension Geofence {
    
    enum Error: Swift.Error {
        case permissionDenied
        case permissionRestricted
        case permissionNotDetermined
        case notFoundCurrentLocation
        case fetchFailedCurrentLocation(Swift.Error)
    }
    
    enum PermissionMode {
        case always
        case whenInAppUse
    }
    
    enum Accuracy {
        case best
        case nearestTenMeters
        case hundredMeters
        case kilometer
        case threeKilometers
    }
    
    enum State {
        case inside
        case outside
        case unknown
    }
}

extension Geofence.Error: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .permissionDenied:
            return "permission denied"
        case .permissionRestricted:
            return "permission restricted"
        case .permissionNotDetermined:
            return "permission not determined"
        case .notFoundCurrentLocation:
            return "not found current location"
        case .fetchFailedCurrentLocation(let error):
            return "fetch failed current location: \(error.localizedDescription)"
        }
    }
}

extension Geofence.PermissionMode: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .always:
            return "always"
        case .whenInAppUse:
            return "when in app use"
        }
    }
}

class GeofenceHandler: NSObject {
    
    var manager = CLLocationManager()
    
    var entringGeofence: ((String) -> Void)?
    
    var exitingGeofence: ((String) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = true
    }
    
    func ensurePermission() throws -> Geofence.PermissionMode {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .denied:
            throw Geofence.Error.permissionDenied
        case .restricted:
            throw Geofence.Error.permissionRestricted
        case .notDetermined:
            throw Geofence.Error.permissionNotDetermined
        case .authorizedAlways:
            return .always
        case .authorizedWhenInUse:
            return .whenInAppUse
        }
    }
    
    private var requestPermissionHandler: ((Geofence.PermissionMode?, Geofence.Error?) -> Void)?
    func requestPermission(
        mode: Geofence.PermissionMode,
        completion: @escaping ((Geofence.PermissionMode?, Geofence.Error?) -> Void) = { _, _ in })
    {
        requestPermissionHandler = { mode, error in
            completion(mode, error)
        }
        switch mode {
        case .always:
            manager.requestAlwaysAuthorization()
        case .whenInAppUse:
            manager.requestWhenInUseAuthorization()
        }
    }
    
//    private var fetchCurrentLocationHandler: ((Geofence.Location?, Geofence.Error?) -> Void)?
    func fetchCurrentLocation(completion: @escaping ((Geofence.Location?, Geofence.Error?) -> Void)) {
//        manager.startUpdatingLocation()
//        fetchCurrentLocationHandler = { location, error in
//            completion(location, error)
//        }
    }
    
//    private var fetchGeofenceStateHandler: ((Geofence.State) -> Void)?
    func fetchGeofenceState(withIdentifier identifier: String, completion: @escaping ((Geofence.State) -> Void)) {
//        guard let region = manager.monitoredRegions.first(where: { region in
//            region.identifier == identifier
//        }) else {
//            return
//        }
//        fetchGeofenceStateHandler = { state in
//            completion(state)
//        }
//        manager.requestState(for: region)
    }
    
    func allGeofenceID() -> [String] {
        return manager.monitoredRegions.map { $0.identifier }
    }
    
//    private var addGeofenceHandler: ((String?, Error?) -> Void)?
    func addGeofence(geofence: Geofence, completion: @escaping ((Error?) -> Void)) {
//        addGeofenceHandler = { identifier, error in
//            if let identifier = identifier {
//                NSLog("add geofence identifier: %@(%f, %f -- %f)",
//                      identifier, geofence.location.latitude, geofence.location.longitude, geofence.radius)
//            }
//            completion(error)
//        }
//        let center = CLLocationCoordinate2DMake(geofence.location.latitude, geofence.location.longitude)
//        let region = CLCircularRegion(center: center, radius: geofence.radius, identifier: geofence.identifier)
//        manager.startMonitoring(for: region)
    }
    
    func removeGeofence(identifier: String) {
        guard let region = manager.monitoredRegions.first(where: { region in
            region.identifier == identifier
        }) else {
            return
        }
        NSLog("remove geofence identifier: %@", identifier)
        manager.stopMonitoring(for: region)
    }
    
    func removeAllGeofence() {
        manager.monitoredRegions.forEach { [weak self] region in
            NSLog("remove geofence identifier: %@", region.identifier)
            self?.manager.stopMonitoring(for: region)
        }
    }
}

extension GeofenceHandler: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else {
            return
        }
        do {
            let mode = try ensurePermission()
            requestPermissionHandler?(mode, nil)
        } catch {
            precondition(error is Geofence.Error)
            requestPermissionHandler?(nil, error as? Geofence.Error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let clLocation = locations.last else {
//            fetchCurrentLocationHandler?(nil, .notFoundCurrentLocation)
//            return
//        }
//        let location = Geofence.Location(
//            latitude: clLocation.coordinate.latitude, longitude: clLocation.coordinate.longitude)
//        fetchCurrentLocationHandler?(location, nil)
//        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//        print("region: \(region.identifier) state: \(state)")
//        fetchGeofenceStateHandler?({
//            switch state {
//            case .outside:
//                return .outside
//            case .inside:
//                return .inside
//            case .unknown:
//                return .unknown
//            }
//        }())
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        fetchCurrentLocationHandler?(nil, .fetchFailedCurrentLocation(error))
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        addGeofenceHandler?(region.identifier, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
//        addGeofenceHandler?(region?.identifier, error)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        entringGeofence?(region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        exitingGeofence?(region.identifier)
    }
}

struct GeofenceBuilder {
    
    let handler = GeofenceHandler()
    
    init() {
        
    }
    
    var arrowsBackground: Bool {
        get {
            return handler.manager.allowsBackgroundLocationUpdates
        }
        set {
            handler.manager.allowsBackgroundLocationUpdates = newValue
        }
    }
    
    var reportDistance: Double {
        get {
            return handler.manager.distanceFilter
        }
        set {
            handler.manager.distanceFilter = newValue
        }
    }
    
    var accuracy: Geofence.Accuracy {
        get {
            switch handler.manager.desiredAccuracy {
            case kCLLocationAccuracyBestForNavigation:
                return .best
            case kCLLocationAccuracyNearestTenMeters:
                return .nearestTenMeters
            case kCLLocationAccuracyHundredMeters:
                return .hundredMeters
            case kCLLocationAccuracyKilometer:
                return .kilometer
            case kCLLocationAccuracyThreeKilometers:
                return .threeKilometers
            default:
                fatalError("not match CLLocationAccuracy value")
            }
        }
        set {
            handler.manager.desiredAccuracy = {
                switch newValue {
                case .best:
                    return kCLLocationAccuracyBestForNavigation
                case .nearestTenMeters:
                    return  kCLLocationAccuracyNearestTenMeters
                case .hundredMeters:
                    return  kCLLocationAccuracyHundredMeters
                case .kilometer:
                    return  kCLLocationAccuracyKilometer
                case .threeKilometers:
                    return  kCLLocationAccuracyThreeKilometers
                }
            }()
        }
    }
    
    func ensurePermission() throws -> Geofence.PermissionMode {
        return try handler.ensurePermission()
    }
    
    func requestPermission(
        mode: Geofence.PermissionMode,
        completion: @escaping ((Geofence.PermissionMode?, Geofence.Error?) -> Void) = { _, _ in })
    {
        handler.requestPermission(mode: mode, completion: completion)
    }
    
    func fetchCurrentLocation(completion: @escaping (Geofence.Location?, Geofence.Error?) -> Void) {
//        handler.fetchCurrentLocation(completion: completion)
    }
    
    func fetchGeofenceState(identifier: String, completion: @escaping ((Geofence.State) -> Void)) {
//        handler.fetchGeofen;ceState(withIdentifier: identifier, completion: completion)
    }
    
    func findAllGeofenceID() -> [String] {
        return handler.allGeofenceID()
    }
    
    func build(geofence: Geofence, completion: @escaping ((Error?) -> Void)) {
//        handler.addGeofence(geofence: geofence) { error in
//            completion(error)
//        }
    }
    
    func destroy(geofenceIdentifier: String) {
        handler.removeGeofence(identifier: geofenceIdentifier)
    }
    
    func destroyAll() {
        handler.removeAllGeofence()
    }
}
