//
//  NetworkMonitor.swift
//  CustomHLSMediaPlayer
//
//  Created by  Max on 06.10.2024.
//
import Network

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private var monitor: NWPathMonitor?
    private var queue = DispatchQueue(label: "NetworkMonitor")
    
    private var isMonitoring = false
    
    var didStartMonitoringHandler: (() -> Void)?
    var didStopMonitoringHandler: (() -> Void)?
    var netStatusChangeHandler: ((NWPath) -> Void)?
    
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    var interfaceType: NWInterface.InterfaceType? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.first?.type
    }
    
    var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }
    }
    
    var isExpensive: Bool {
        return monitor?.currentPath.isExpensive ?? false
    }
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)
        
        monitor?.pathUpdateHandler = { [weak self] path in
            self?.netStatusChangeHandler?(path)
        }
        
        isMonitoring = true
        didStartMonitoringHandler?()
    }
    
    func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        
        monitor.cancel()
        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
    
    deinit {
        stopMonitoring()
    }
}
