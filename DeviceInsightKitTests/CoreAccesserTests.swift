//
//  CoreAccesserTests.swift
//  DeviceInsightKitTests
//
//  Created by Toshihiko Arai on 2024/10/22.
//

import XCTest
@testable import DeviceInsightKit

class CoreAccesserTests: XCTestCase {
    
    var coreAccesser: CoreAccesser!

    override func setUp() {
        super.setUp()
        // テスト対象のCoreAccesserインスタンスを生成
        coreAccesser = CoreAccesser()
    }

    override func tearDown() {
        // インスタンスの解放
        coreAccesser = nil
        super.tearDown()
    }

    // バッテリー残量の取得テスト
    func testGetBatteryLevel() {
        #if targetEnvironment(simulator)
        // シミュレーターではバッテリー情報を取得できないため、テストをスキップ
        print("Battery level test skipped on simulator")
        #else
        let batteryLevel = coreAccesser.getBatteryLevel()
        // バッテリー監視が有効な場合、結果が0〜100の間であることを確認
        XCTAssert(batteryLevel >= 0 && batteryLevel <= 100, "Battery level should be between 0 and 100")
        #endif
    }
    
    // バッテリーステータスの取得テスト
    func testGetBatteryState() {
        let batteryState = coreAccesser.getBatteryState()
        let validStates = ["Unknown", "Unplugged", "Charging", "Full"]
        // バッテリーステータスがいずれかの状態に含まれることを確認
        XCTAssertTrue(validStates.contains(batteryState), "Battery state should be one of the known states")
    }

    // 空きディスク容量の取得テスト
    func testGetFreeDiskSpace() {
        let freeDiskSpace = coreAccesser.getFreeDiskSpace()
        // 空きディスク容量が"Error"や"N/A"でないことを確認
        XCTAssertFalse(freeDiskSpace.contains("Error"), "Disk space retrieval should not return an error")
        XCTAssertFalse(freeDiskSpace == "N/A", "Disk space should not be N/A")
    }

    // デバイス名の取得テスト
    func testGetDeviceName() {
        let deviceName = coreAccesser.getDeviceName()
        // デバイス名が空でないことを確認
        XCTAssertFalse(deviceName.isEmpty, "Device name should not be empty")
    }

    // システムバージョンの取得テスト
    func testGetSystemVersion() {
        let systemVersion = coreAccesser.getSystemVersion()
        // システムバージョンが空でないことを確認
        XCTAssertFalse(systemVersion.isEmpty, "System version should not be empty")
    }
    
    // メモリ使用量の取得テスト
    func testGetMemoryUsage() {
        let memoryUsage = coreAccesser.getMemoryUsage()
        // メモリ使用量が0以上であることを確認
        XCTAssert(memoryUsage > 0, "Memory usage should be greater than 0")
    }
    
    // CPU使用率の取得テスト
    func testGetCPUUsage() {
        let cpuUsage = coreAccesser.getCPUUsage()
        // CPU使用率が0〜100の間であることを確認
        XCTAssert(cpuUsage >= 0 && cpuUsage <= 100, "CPU usage should be between 0 and 100")
    }
}
