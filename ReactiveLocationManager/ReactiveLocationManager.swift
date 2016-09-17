import CoreLocation
import ReactiveSwift

public enum LocationError: Error {
    case noError, failedFetching
}

typealias LocationObserver = Observer<CLLocation?, LocationError>

public final class ReactiveLocationManager: NSObject, CLLocationManagerDelegate {
    
    fileprivate var observer: LocationObserver?
    fileprivate var disposable: Disposable?
    fileprivate var singleUse = true
    
    fileprivate let locationManager = CLLocationManager()
    
    public func updates(_ single: Bool = true) -> SignalProducer<CLLocation?, LocationError> {
        singleUse = single
        return SignalProducer { [weak self] observer, disposable in
            self?.observer = observer
            self?.disposable = disposable
            self?.locationManager.delegate = self
            self?.locationManager.startUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        send((manager, locations.first as CLLocation!, nil))
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        send((manager, nil, .failedFetching))
    }
}

private extension ReactiveLocationManager {
    func send(_ next: (CLLocationManager, CLLocation?, LocationError?)) {
        if singleUse { next.0.stopUpdatingLocation() }
        guard let observer = observer else { return }
        if let error = next.2 {
            observer.sendFailed(error)
        } else if let location = next.1 {
            observer.sendNext(location)
        }
        if singleUse { disposable?.dispose() }
    }
}
