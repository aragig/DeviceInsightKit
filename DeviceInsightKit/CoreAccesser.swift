//
//  utils.swift
//  DeviceInsightKit
//
//  Created by Toshihiko Arai on 2024/10/22.
//

import UIKit

public class CoreAccesser {
    
    public init() {}
    
    // バッテリー残量の取得（整数で返す）
    public func getBatteryLevel() -> Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Int(UIDevice.current.batteryLevel * 100)
    }
    
    // バッテリーステータスの取得
    public func getBatteryState() -> String {
        switch UIDevice.current.batteryState {
        case .unknown: return "Unknown"
        case .unplugged: return "Unplugged"
        case .charging: return "Charging"
        case .full: return "Full"
        @unknown default: return "Unknown"
        }
    }
    
    // 空きディスク容量の取得（GBで返す）
    public func getFreeDiskSpace() -> String {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let capacity = values.volumeAvailableCapacityForImportantUsage {
                return String(format: "%.2f GB", Float(capacity) / (1024 * 1024 * 1024))
            } else {
                return "N/A"
            }
        } catch {
            return "Error retrieving disk space"
        }
    }
    
    // デバイス名の取得
    public func getDeviceName() -> String {
        return UIDevice.current.name
    }
    
    // システムバージョンの取得
    public func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    // メモリ使用量の取得（MBで返す）
    public func getMemoryUsage() -> Float {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            taskInfoPointer in
            taskInfoPointer.withMemoryRebound(to: integer_t.self, capacity: 1) {
                taskInfoOutPointer in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), taskInfoOutPointer, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            // メモリ使用量をMBに変換し、小数点以下1桁に丸めて返す
            let memoryUsageMB = Float(taskInfo.resident_size) / (1024 * 1024)
            return round(memoryUsageMB * 10) / 10
        } else {
            return 0
        }
    }
    
    // CPU使用率の取得（小数点以下1桁まで返す）
    public func getCPUUsage() -> Float {
        // カーネル処理の結果
        var result: Int32
        var threadList = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        var threadCount = UInt32(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)
        var threadInfo = thread_basic_info()

        // スレッド情報を取得
        result = withUnsafeMutablePointer(to: &threadList) {
            $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadCount)
            }
        }

        if result != KERN_SUCCESS { return 0 }

        // 各スレッドからCPU使用率を算出し合計を全体のCPU使用率とする
        let totalCPUUsage = (0 ..< Int(threadCount))
            // スレッドのCPU使用率を取得
            .compactMap { index -> Float? in
                var threadInfoCount = UInt32(THREAD_INFO_MAX)
                result = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadList[index], UInt32(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }
                // スレッド情報が取れない = 該当スレッドのCPU使用率を0とみなす(基本nilが返ることはない)
                if result != KERN_SUCCESS { return nil }
                let isIdle = threadInfo.flags == TH_FLAGS_IDLE
                // CPU使用率がスケール調整済みのため`TH_USAGE_SCALE`で除算し戻す
                return !isIdle ? (Float(threadInfo.cpu_usage) / Float(TH_USAGE_SCALE)) * 100 : nil
            }
            // 合計算出
            .reduce(0, +)
        
        // 小数点以下1桁に丸めて返す
        return round(totalCPUUsage * 10) / 10
    }
}
