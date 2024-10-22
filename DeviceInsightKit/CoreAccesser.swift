//
//  utils.swift
//  DeviceInsightKit
//
//  Created by Toshihiko Arai on 2024/10/22.
//

import UIKit

public struct SystemInfo {
    let batteryLevel: Int
    let batteryState: String
    let freeDiskSpace: String
    let deviceName: String
    let systemVersion: String
    let memoryUsage: Float
    let cpuUsage: Float
}

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
            // iOS 12では volumeAvailableCapacityKey を使用
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let capacity = values.volumeAvailableCapacity {
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
        var result: Int32
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()

        // スレッド情報を取得
        result = task_threads(mach_task_self_, &threadList, &threadCount)
        if result != KERN_SUCCESS { return 0 }

        var totalCPUUsage: Float = 0
        // 各スレッドからCPU使用率を算出し合計を全体のCPU使用率とする
        for index in 0..<Int(threadCount) {
            var threadInfo = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)

            result = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threadList![index], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }

            if result != KERN_SUCCESS { continue }

            let isIdle = (threadInfo.flags & TH_FLAGS_IDLE) != 0
            if !isIdle {
                totalCPUUsage += (Float(threadInfo.cpu_usage) / Float(TH_USAGE_SCALE)) * 100
            }
        }

        // 使用後にスレッドリストのメモリを解放
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadList), vm_size_t(threadCount * UInt32(MemoryLayout<thread_t>.size)))

        // 小数点以下1桁に丸めて返す
        return round(totalCPUUsage * 10) / 10
    }
}
