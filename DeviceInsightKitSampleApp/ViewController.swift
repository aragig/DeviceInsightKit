//
//  ViewController.swift
//  DeviceInsightKitSampleApp
//
//  Created by Toshihiko Arai on 2024/10/22.
//

import UIKit

class ViewController: UIViewController, DeviceInsightDelegate {
    
    @IBOutlet weak var textView: UITextView!

    var deviceInsight: DeviceInsight!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DeviceInsightの初期化（5秒ごとにシステム情報を取得）
        deviceInsight = DeviceInsight(interval: 5.0)
        deviceInsight.delegate = self
        deviceInsight.startMonitoring()
    }
    
    // DeviceInsightDelegateメソッド
    func didUpdateSystemInfo(_ systemInfo: SystemInfo) {
        // システム情報を文字列として整形
        let systemInfoText = """
        Battery Level  : \(systemInfo.batteryLevel)%
        Battery State  : \(systemInfo.batteryState)
        Free Disk Space: \(systemInfo.freeDiskSpace)
        Memory Usage   : \(systemInfo.memoryUsage)MB
        CPU Usage      : \(systemInfo.cpuUsage)%
        Device Name    : \(systemInfo.deviceName)
        System Version : \(systemInfo.systemVersion)
        """
        
        // メインスレッドでUIを更新
        DispatchQueue.main.async {
            self.textView.text = systemInfoText
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 監視を停止
        deviceInsight.stopMonitoring()
    }
}
