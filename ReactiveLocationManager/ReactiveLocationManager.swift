import ReactiveCocoa

public enum LocationError: ErrorType {
    case NoError, FailedFetching
}

typealias LocationObserver = Observer<CLLocation?, LocationError>

public final class ReactiveLocationManager: NSObject, CLLocationManagerDelegate {
    
    private var observer: LocationObserver?
    private var disposable: Disposable?
    private var singleUse = true
    
    private let locationManager = CLLocationManager()
    
    public func updates(single: Bool = true) -> SignalProducer<CLLocation?, LocationError> {
        singleUse = single
        return SignalProducer { [weak self] observer, disposable in
            self?.observer = observer
            self?.disposable = disposable
            self?.locationManager.delegate = self
            self?.locationManager.startUpdatingLocation()
        }
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        send((manager, locations.first as CLLocation!, nil))
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        send((manager, nil, .FailedFetching))
    }
}

private extension ReactiveLocationManager {
    func send(next: (CLLocationManager, CLLocation?, LocationError?)) {
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