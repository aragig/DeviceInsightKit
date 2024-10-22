//
//  DeviceInsight.swift
//  DeviceInsightKit
//
//  Created by Toshihiko Arai on 2024/10/22.
//

import UIKit



public protocol DeviceInsightDelegate: AnyObject {
    func didUpdateSystemInfo(_ systemInfo: SystemInfo)
}

public class DeviceInsight {
    
    private var coreAccesser: CoreAccesser
    private var timer: Timer?
    private var interval: TimeInterval
    public weak var delegate: DeviceInsightDelegate?
    
    public init(interval: TimeInterval = 60.0) {
        self.coreAccesser = CoreAccesser()
        self.interval = interval
    }
    
    public func startMonitoring() {
        // タイマーが既に存在する場合は無効化
        timer?.invalidate()
        
        // 新しいタイマーを作成して開始
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(fetchSystemInfo), userInfo: nil, repeats: true)
        timer?.fire() // タイマー開始と同時に最初のデータ取得
    }
    
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func fetchSystemInfo() {
        let batteryLevel = coreAccesser.getBatteryLevel()
        let batteryState = coreAccesser.getBatteryState()
        let freeDiskSpace = coreAccesser.getFreeDiskSpace()
        let deviceName = coreAccesser.getDeviceName()
        let systemVersion = coreAccesser.getSystemVersion()
        let memoryUsage = coreAccesser.getMemoryUsage()
        let cpuUsage = coreAccesser.getCPUUsage()
        
        // 構造体に各パラメータをまとめる
        let systemInfo = SystemInfo(
            batteryLevel: batteryLevel,
            batteryState: batteryState,
            freeDiskSpace: freeDiskSpace,
            deviceName: deviceName,
            systemVersion: systemVersion,
            memoryUsage: memoryUsage,
            cpuUsage: cpuUsage
        )
        
        // デリゲートにデータを渡す
        delegate?.didUpdateSystemInfo(systemInfo)
    }
}
