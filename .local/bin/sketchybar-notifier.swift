// sketchybar-notifier — sketchybar 事件驱动守护进程
//
// 功能：监听 macOS 系统事件，实时触发 sketchybar 自定义事件刷新对应 widget。
//       替代轮询方案，实现状态栏即时响应。
//
// 架构：每类系统事件对应一个 Observer 模块，统一通过 SketchyBar.trigger() 发送事件。
//       新增监听只需：1) 添加 Observer 类  2) 在 main 中初始化
//
// 当前监听：
//   - 输入法切换  → input_method_change
//   - 蓝牙连接/断开 → bt_headphone_status_change, bt_keyboard_status_change, bt_mouse_status_change
//
// 编译：swiftc -O -framework IOBluetooth -o ~/.local/bin/sketchybar-notifier sketchybar-notifier.swift
// 服务：~/Library/LaunchAgents/com.roc.sketchybar-notifier.plist (launchd, KeepAlive)

import Cocoa
import IOBluetooth

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
//
// 注意：需要在「系统设置 → 隐私与安全性 → 蓝牙」中授权本程序。

class BluetoothObserver: NSObject {
    /// sketchybar 中注册的蓝牙设备 item 名称列表
    /// 新增蓝牙设备 widget 时，同步在此添加名称
    static let items = ["bt_headphone", "bt_keyboard", "bt_mouse"]

    override init() {
        super.init()
        IOBluetoothDevice.register(forConnectNotifications: self,
            selector: #selector(deviceConnected(_:device:)))
    }

    @objc func deviceConnected(_ notification: IOBluetoothUserNotification,
                                device: IOBluetoothDevice) {
        notifySketchybar()
        // 注册该设备的断开通知
        device.register(forDisconnectNotification: self,
            selector: #selector(deviceDisconnected(_:device:)))
    }

    @objc func deviceDisconnected(_ notification: IOBluetoothUserNotification,
                                   device: IOBluetoothDevice) {
        notifySketchybar()
    }

    private func notifySketchybar() {
        SketchyBar.trigger(Self.items.map { "\($0)_status_change" })
    }
}

// MARK: - 新增监听模板
//
// 1. 创建新的 Observer 类（参考上方 InputMethodObserver / BluetoothObserver）
// 2. 在下方 main 初始化区域添加实例
// 3. 在 sketchybar items/ 中添加对应的 --add event 和 --subscribe
// 4. 重新编译并重启服务：
//    swiftc -O -framework IOBluetooth -o ~/.local/bin/sketchybar-notifier sketchybar-notifier.swift
//    launchctl kickstart -k gui/$(id -u)/com.roc.sketchybar-notifier

// MARK: - Main

let _im = InputMethodObserver()
let _bt = BluetoothObserver()

RunLoop.main.run()
