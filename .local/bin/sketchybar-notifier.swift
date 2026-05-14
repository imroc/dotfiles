// sketchybar-notifier — sketchybar 事件驱动守护进程
//
// 功能：监听 macOS 系统事件，实时触发 sketchybar 自定义事件刷新对应 widget。
//       替代轮询方案，实现状态栏即时响应。
//       同时为关注的蓝牙设备发送系统通知（连接/断开/意外掉线）。
//
// 架构：每类系统事件对应一个 Observer 模块，统一通过 SketchyBar.trigger() 发送事件。
//       新增监听只需：1) 添加 Observer 类  2) 在 main 中初始化
//
// 当前监听：
//   - 输入法切换    → input_method_change
//   - 蓝牙连接/断开 → bt_{name}_status_change + 系统通知
//
// 编译：swiftc -O -framework IOBluetooth -o ~/.cache/sketchybar-notifier sketchybar-notifier.swift
// 服务：~/Library/LaunchAgents/com.roc.sketchybar-notifier.plist (launchd, KeepAlive)

import Cocoa
import IOBluetooth
import UserNotifications

// MARK: - 系统通知

enum Notify {
    /// 发送 macOS 系统通知
    /// - Parameters:
    ///   - title: 通知标题
    ///   - body: 通知正文
    ///   - sound: 系统音效名（Hero, Purr, Basso, Tink 等）
    static func send(title: String, body: String, sound: String = "default") {
        // 使用 osascript，兼容性最好且无需额外授权
        let script = """
            display notification "\(body)" with title "\(title)" sound name "\(sound)"
        """
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", script]
        try? task.run()
    }
}

// MARK: - SketchyBar 通信层

enum SketchyBar {
    static let path = "/opt/homebrew/bin/sketchybar"

    /// 触发一个 sketchybar 自定义事件
    static func trigger(_ event: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: path)
        task.arguments = ["--trigger", event]
        try? task.run()
    }

    /// 批量触发多个事件
    static func trigger(_ events: [String]) {
        for event in events {
            trigger(event)
        }
    }
}

// MARK: - 输入法切换监听
//
// 原理：macOS 在切换输入法时通过 DistributedNotificationCenter 广播
//       com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged 通知。
// 事件：input_method_change → sketchybar items/input_method

class InputMethodObserver {
    init() {
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"),
            object: nil, queue: .main
        ) { _ in
            SketchyBar.trigger("input_method_change")
        }
    }
}

// MARK: - 蓝牙设备连接/断开监听
//
// 原理：通过 IOBluetooth 框架注册全局连接通知，任意蓝牙设备连接时回调；
//       再对已连接设备注册断开通知。覆盖所有蓝牙设备的连接/掉线/关机场景。
// 事件：bt_{name}_status_change → sketchybar items/bt_devices
// 通知：关注列表中的设备连接/断开时发送系统通知
//
// 注意：需要在「系统设置 → 隐私与安全性 → 蓝牙」中授权本程序。

/// 蓝牙设备配置
/// - item: sketchybar item 名称，用于事件触发
/// - mac: 设备 MAC 地址（IOBluetooth 格式，用 - 分隔）
/// - name: 设备显示名称，用于系统通知
struct BluetoothDevice {
    let item: String
    let mac: String
    let name: String
}

class BluetoothObserver: NSObject {
    /// 关注的蓝牙设备列表
    /// 新增设备时同步在此添加，并在 sketchybar items/bt_devices 中添加对应条目
    static let devices: [BluetoothDevice] = [
        BluetoothDevice(item: "bt_headphone", mac: "64-b0-e8-fb-56-68", name: "HUAWEI FreeArc"),
        BluetoothDevice(item: "bt_keyboard",  mac: "f5-aa-e4-10-93-dd", name: "HHKB"),
        BluetoothDevice(item: "bt_mouse",     mac: "00-81-2a-94-bd-6c", name: "Magic Mouse"),
    ]

    override init() {
        super.init()
        IOBluetoothDevice.register(forConnectNotifications: self,
            selector: #selector(deviceConnected(_:device:)))
    }

    @objc func deviceConnected(_ notification: IOBluetoothUserNotification,
                                device: IOBluetoothDevice) {
        triggerSketchybar()
        notifyIfWatched(device: device, connected: true)
        // 注册该设备的断开通知
        device.register(forDisconnectNotification: self,
            selector: #selector(deviceDisconnected(_:device:)))
    }

    @objc func deviceDisconnected(_ notification: IOBluetoothUserNotification,
                                   device: IOBluetoothDevice) {
        triggerSketchybar()
        notifyIfWatched(device: device, connected: false)
    }

    /// 触发所有蓝牙设备的 sketchybar 事件
    private func triggerSketchybar() {
        SketchyBar.trigger(Self.devices.map { "\($0.item)_status_change" })
    }

    /// 如果是关注列表中的设备，发送系统通知
    private func notifyIfWatched(device: IOBluetoothDevice, connected: Bool) {
        let addr = device.addressString ?? ""
        // IOBluetooth 返回的 MAC 格式是 xx-xx-xx-xx-xx-xx，转为小写比较
        let normalizedAddr = addr.lowercased()

        guard let watched = Self.devices.first(where: { $0.mac == normalizedAddr }) else {
            return
        }

        if connected {
            Notify.send(title: watched.name, body: "已连接", sound: "Hero")
        } else {
            Notify.send(title: watched.name, body: "已断开连接", sound: "Purr")
        }
    }
}

// MARK: - 新增监听模板
//
// 1. 创建新的 Observer 类（参考上方 InputMethodObserver / BluetoothObserver）
// 2. 在下方 main 初始化区域添加实例
// 3. 在 sketchybar items/ 中添加对应的 --add event 和 --subscribe
// 4. 重新编译并重启服务：
//    launchctl kickstart -k gui/$(id -u)/com.roc.sketchybar-notifier

// MARK: - Main

let _im = InputMethodObserver()
let _bt = BluetoothObserver()

RunLoop.main.run()
