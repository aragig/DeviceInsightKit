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
        // 初回時に一回キックする
        fetchSystemInfo()
        // 新しいタイマーを作成して開始
        
        DispatchQueue.main.async { // タイマーはメインスレッドでないと実行されない
            self.timer = Timer.scheduledTimer(timeInterval: self.interval, target: self, selector: #selector(self.fetchSystemInfo), userInfo: nil, repeats: true)
            self.timer?.fire() // タイマー開始と同時に最初のデータ取得
        }
        // 以下は、タイマーをバックグラウンドスレッドで実行する例
//        DispatchQueue.global(qos: .background).async { // バックグラウンドスレッドで実行
//            self.timer = Timer(timeInterval: self.interval, target: self, selector: #selector(self.fetchSystemInfo), userInfo: nil, repeats: true)
//            
//            // タイマーをバックグラウンドスレッドのRunLoopに追加
//            RunLoop.current.add(self.timer!, forMode: .common)
//            RunLoop.current.run() // RunLoopを開始してタイマーを動作させる
//            
//            // タイマー開始と同時に最初のデータ取得
//            self.timer?.fire()
//        }
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
