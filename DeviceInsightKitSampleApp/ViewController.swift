//
//  ViewController.swift
//  DeviceInsightKitSampleApp
//
//  Created by Toshihiko Arai on 2024/10/22.
//

import UIKit

class ViewController: UIViewController, DeviceInsightDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stressButton: UIButton!

    var deviceInsight: DeviceInsight!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DeviceInsightの初期化（5秒ごとにシステム情報を取得）
        deviceInsight = DeviceInsight(interval: 2.0)
        deviceInsight.delegate = self
        deviceInsight.startMonitoring()
        
        stressButton.addTarget(self, action: #selector(didTapStressButton), for: .touchUpInside)
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
    
    // ストレステスト用のボタンが押された時の処理
    @objc func didTapStressButton() {
        DispatchQueue.global(qos: .background).async {
            // CPUを消費する重い処理
            self.performHeavyComputation()
        }
    }

    // CPUやメモリを消費する処理
    func performHeavyComputation() {
        var array: [Int] = []
        for i in 0..<10_000_000 {
            array.append(i)
            if i % 100_000 == 0 {
                print("Processing \(i)...") // 大量の計算処理
            }
        }
        print("Completed heavy computation.")
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 監視を停止
        deviceInsight.stopMonitoring()
    }
}
