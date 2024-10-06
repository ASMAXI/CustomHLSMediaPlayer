//
//  CustomHLSMediaPlayer.swift
//  CustomHLSMediaPlayer
//
//  Created by  Max on 06.10.2024.
//

import AVFoundation
import Network
import UIKit

class CustomHLSMediaPlayer: UIView {
    
    // MARK: - Properties
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var playerItem: AVPlayerItem!
    private var url: URL!
    private var networkMonitor: NetworkMonitor!
    
    // MARK: - Initialization
    init(url: URL) {
        super.init(frame: .zero)
        self.url = url
        setupPlayer()
        setupNetworkMonitor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupPlayer() {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
    }
    
    private func setupNetworkMonitor() {
        networkMonitor = NetworkMonitor.shared
        networkMonitor.netStatusChangeHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                self.updateBitrateBasedOnNetwork(path)
            }
        }
    }
    
    private func updateBitrateBasedOnNetwork(_ path: NWPath) {
        // Estimate bandwidth based on network conditions
        let estimatedBandwidth: Double
        
        switch path.availableInterfaces.first?.type {
        case .wifi:
            estimatedBandwidth = 5_000_000 // 5 Mbps for WiFi
        case .cellular:
            estimatedBandwidth = 1_000_000 // 1 Mbps for Cellular
        default:
            estimatedBandwidth = 1_000_000 // Default to 1 Mbps
        }
        
        let preferredBitrate = estimatedBandwidth * 0.8 // Adjust as needed
        playerItem.preferredPeakBitRate = preferredBitrate
    }
    
    // MARK: - Public Methods
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func seek(to time: CMTime) {
        player.seek(to: time)
    }
    
    func setBitrateManually(_ bitrate: Double) {
        playerItem.preferredPeakBitRate = bitrate
    }
}
