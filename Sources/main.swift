import AppKit
import ApplicationServices

// Never copy an old selection just because Terminal becomes active again.
struct SelectionGate {
    var context: String?
    var baseline: String?

    mutating func observe(context nextContext: String?, text: String?, dragging: Bool) -> String? {
        if context != nextContext {
            context = nextContext
            baseline = nil
        }
        guard nextContext != nil, let text = text, !dragging else { return nil }
        guard let previous = baseline else {
            baseline = text
            return nil
        }
        baseline = text
        return text != previous && !text.isEmpty ? text : nil
    }

    mutating func reset() { context = nil; baseline = nil }
}

func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    return AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success ? value : nil
}

func elementAttribute(_ element: AXUIElement, _ name: String) -> AXUIElement? {
    guard let value = attribute(element, name), CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }
    return (value as! AXUIElement)
}

func children(_ element: AXUIElement) -> [AXUIElement] {
    (attribute(element, kAXChildrenAttribute) as? [AXUIElement]) ?? []
}

// Bound the fallback search; AX calls go to another process and may time out.
func selectedText(in root: AXUIElement) -> String? {
    var queue = [root]
    var index = 0
    let deadline = ProcessInfo.processInfo.systemUptime + 0.1
    while index < queue.count && index < 64 && ProcessInfo.processInfo.systemUptime < deadline {
        let element = queue[index]
        index += 1
        if let text = attribute(element, kAXSelectedTextAttribute) as? String { return text }
        queue.append(contentsOf: children(element).prefix(max(0, 64 - queue.count)))
    }
    return nil
}

func shortcut(key: Int64, flags: CGEventFlags) -> (Int64, CGEventFlags)? {
    guard key == 123 || key == 124 else { return nil }
    let modifiers: CGEventFlags = [.maskCommand, .maskControl, .maskShift, .maskAlternate]
    let pressed = flags.intersection(modifiers)
    let remaining = flags.subtracting(modifiers)
    if pressed == .maskCommand {
        return (key == 123 ? 0 : 14, remaining.union(.maskControl))
    }
    if pressed == .maskControl {
        return (48, remaining.union(key == 123 ? [.maskControl, .maskShift] : .maskControl))
    }
    return nil
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var controlsWindow: NSWindow?
    var statusLabel: NSTextField?
    var eventTap: CFMachPort?
    var eventSource: CFRunLoopSource?
    var tapAttempted = false
    var timer: Timer?
    var gate = SelectionGate()
    var enabled = UserDefaults.standard.object(forKey: "copyEnabled") as? Bool ?? true
    var shortcutsEnabled = UserDefaults.standard.object(forKey: "shortcutsEnabled") as? Bool ?? true
    var targetPID: pid_t?
    var target: AXUIElement?
    var window: AXUIElement?
    var windowGeneration = 0
    var lastPermission: Bool?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AXUIElementSetMessagingTimeout(AXUIElementCreateSystemWide(), 0.08)
        for other in NSRunningApplication.runningApplications(withBundleIdentifier: "dev.local.TerminalCopyOnSelect")
            where other.processIdentifier != ProcessInfo.processInfo.processIdentifier { other.terminate() }
        timer = Timer(timeInterval: 0.15, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        timer?.tolerance = 0.04
        RunLoop.main.add(timer!, forMode: .common)
        tick()
        if !CommandLine.arguments.contains("--background") { showSettings() }
        if !AXIsProcessTrusted() { requestAccess() }
        if Bundle.main.url(forResource: "iTerm Dark", withExtension: "terminal") != nil,
           CommandLine.arguments.contains("--apply-theme") || !UserDefaults.standard.bool(forKey: "themeAttempted") {
            DispatchQueue.main.async { self.applyTheme() }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return true
    }

    @objc func toggle(_ sender: NSButton) {
        enabled = sender.state == .on
        UserDefaults.standard.set(enabled, forKey: "copyEnabled")
        gate.reset()
        updateStatus(trusted: AXIsProcessTrusted())
    }

    @objc func toggleShortcuts(_ sender: NSButton) {
        shortcutsEnabled = sender.state == .on
        UserDefaults.standard.set(shortcutsEnabled, forKey: "shortcutsEnabled")
    }

    var loginURL: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents/dev.local.ExtendedTerminal.plist")
    }

    @objc func toggleLogin(_ sender: NSButton) {
        do {
            if sender.state == .on {
                try FileManager.default.createDirectory(at: loginURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                let plist: [String: Any] = ["Label": "dev.local.ExtendedTerminal", "ProgramArguments": [Bundle.main.executableURL!.path, "--background"], "RunAtLoad": true]
                try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0).write(to: loginURL, options: .atomic)
            } else if FileManager.default.fileExists(atPath: loginURL.path) {
                try FileManager.default.removeItem(at: loginURL)
            }
        } catch { showError(error.localizedDescription) }
    }

    func showSettings() {
        if controlsWindow == nil {
            let panel = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 510, height: 340), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            panel.title = "Extended Terminal"
            panel.isReleasedWhenClosed = false
            panel.center()
            let content = panel.contentView!
            let title = NSTextField(labelWithString: "Extended Terminal")
            title.font = .boldSystemFont(ofSize: 22)
            title.frame = NSRect(x: 24, y: 289, width: 460, height: 30)
            content.addSubview(title)
            let status = NSTextField(labelWithString: "")
            status.frame = NSRect(x: 24, y: 253, width: 465, height: 25)
            content.addSubview(status)
            statusLabel = status
            let copy = NSButton(checkboxWithTitle: "Копировать выделенный текст", target: self, action: #selector(toggle(_:)))
            copy.state = enabled ? .on : .off
            copy.frame = NSRect(x: 24, y: 216, width: 465, height: 25)
            content.addSubview(copy)
            let keys = NSButton(checkboxWithTitle: "Ctrl + ←/→: вкладки; ⌘ + ←/→: начало/конец строки", target: self, action: #selector(toggleShortcuts(_:)))
            keys.state = shortcutsEnabled ? .on : .off
            keys.frame = NSRect(x: 24, y: 182, width: 470, height: 25)
            content.addSubview(keys)
            let login = NSButton(checkboxWithTitle: "Запускать при входе в систему", target: self, action: #selector(toggleLogin(_:)))
            login.state = FileManager.default.fileExists(atPath: loginURL.path) ? .on : .off
            login.frame = NSRect(x: 24, y: 148, width: 465, height: 25)
            content.addSubview(login)
            let access = NSButton(title: "Разрешить доступ…", target: self, action: #selector(requestAccess))
            access.frame = NSRect(x: 24, y: 98, width: 220, height: 32)
            content.addSubview(access)
            let theme = NSButton(title: "Применить тему Terminal", target: self, action: #selector(applyTheme))
            theme.frame = NSRect(x: 260, y: 98, width: 226, height: 32)
            content.addSubview(theme)
            let quit = NSButton(title: "Завершить Extended Terminal", target: self, action: #selector(quitApp))
            quit.frame = NSRect(x: 24, y: 31, width: 270, height: 32)
            content.addSubview(quit)
            controlsWindow = panel
        }
        updateStatus(trusted: AXIsProcessTrusted())
        controlsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Extended Terminal"
        alert.informativeText = message
        alert.runModal()
    }

    @objc func applyTheme() {
        guard let theme = Bundle.main.url(forResource: "iTerm Dark", withExtension: "terminal"),
              let scriptURL = Bundle.main.url(forResource: "ApplyTheme", withExtension: "applescript") else { return }
        UserDefaults.standard.set(true, forKey: "themeAttempted")
        do {
            let support = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Extended Terminal/Backups")
            try FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
            let domain = "com.apple.Terminal" as CFString
            var backup: [String: Any] = [:]
            for key in ["Window Settings", "Default Window Settings", "Startup Window Settings"] {
                if let value = CFPreferencesCopyAppValue(key as CFString, domain) { backup[key] = value }
            }
            let backupURL = support.appendingPathComponent("Terminal-\(UUID().uuidString).plist")
            try PropertyListSerialization.data(fromPropertyList: backup, format: .xml, options: 0).write(to: backupURL, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: backupURL.path)
            let path = theme.path.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
            let source = try String(contentsOf: scriptURL, encoding: .utf8).replacingOccurrences(of: "__THEME_PATH__", with: path)
            var error: NSDictionary?
            _ = NSAppleScript(source: source)?.executeAndReturnError(&error)
            if let error = error { showError("Не удалось применить тему. Разрешите Extended Terminal управлять Terminal в настройках «Автоматизация», затем нажмите «Применить тему Terminal».\n\n\(error)") }
        } catch { showError(error.localizedDescription) }
    }

    @objc func quitApp() { NSApp.terminate(nil) }

    @objc func requestAccess() {
        tapAttempted = false
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    func updateStatus(trusted: Bool) {
        statusLabel?.stringValue = !trusted ? "Нужен Универсальный доступ" : (eventTap == nil ? "Копирование доступно; клавиатура: нужен доступ" : "Работает в фоне, только в Terminal")
    }

    func installKeyboardTap() {
        guard eventTap == nil, !tapAttempted else { return }
        tapAttempted = true
        let mask = (CGEventMask(1) << CGEventType.keyDown.rawValue) | (CGEventMask(1) << CGEventType.keyUp.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, info in
            let owner = Unmanaged<AppDelegate>.fromOpaque(info!).takeUnretainedValue()
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                if let tap = owner.eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
                return Unmanaged.passUnretained(event)
            }
            guard owner.shortcutsEnabled,
                  NSWorkspace.shared.frontmostApplication?.bundleIdentifier == "com.apple.Terminal" else { return Unmanaged.passUnretained(event) }
            if let mapping = shortcut(key: event.getIntegerValueField(.keyboardEventKeycode), flags: event.flags) {
                event.setIntegerValueField(.keyboardEventKeycode, value: mapping.0)
                event.flags = mapping.1
            }
            return Unmanaged.passUnretained(event)
        }
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: mask, callback: callback, userInfo: Unmanaged.passUnretained(self).toOpaque())
        if let tap = eventTap {
            eventSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetMain(), eventSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }

    @objc func tick() {
        let trusted = AXIsProcessTrusted()
        if trusted && eventTap == nil { installKeyboardTap(); updateStatus(trusted: trusted) }
        if lastPermission != trusted { lastPermission = trusted; updateStatus(trusted: trusted) }
        guard trusted, enabled,
              let app = NSWorkspace.shared.frontmostApplication,
              app.bundleIdentifier == "com.apple.Terminal" else {
            gate.reset()
            target = nil
            targetPID = nil
            window = nil
            return
        }
        if targetPID != app.processIdentifier {
            targetPID = app.processIdentifier
            target = AXUIElementCreateApplication(app.processIdentifier)
        }
        guard let target = target,
              let focusedWindow = elementAttribute(target, kAXFocusedWindowAttribute) else { return }
        if window == nil || !CFEqual(window!, focusedWindow) {
            window = focusedWindow
            windowGeneration += 1
        }
        let context = "\(app.processIdentifier):\(windowGeneration)"
        let dragging = CGEventSource.buttonState(.combinedSessionState, button: .left)
        // Defer reading until the selection is complete, avoiding partial copies.
        guard !dragging else { return }
        let focused = elementAttribute(target, kAXFocusedUIElementAttribute)
        let text = focused.flatMap { selectedText(in: $0) } ?? selectedText(in: focusedWindow)
        guard NSWorkspace.shared.frontmostApplication?.processIdentifier == app.processIdentifier,
              !CGEventSource.buttonState(.combinedSessionState, button: .left) else { return }
        if let copy = gate.observe(context: context, text: text, dragging: false) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(copy, forType: .string)
        }
    }
}

func probe() {
    guard AXIsProcessTrusted() else {
        print("Accessibility permission: missing. Grant access to the application in System Preferences.")
        exit(2)
    }
    guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.Terminal").first else {
        print("Terminal is not running.")
        exit(3)
    }
    let target = AXUIElementCreateApplication(app.processIdentifier)
    AXUIElementSetMessagingTimeout(AXUIElementCreateSystemWide(), 0.1)
    guard let root = elementAttribute(target, kAXFocusedWindowAttribute) else {
        print("Terminal has no accessible focused window.")
        exit(4)
    }
    var queue: [(AXUIElement, Int)] = [(root, 0)]
    var index = 0
    var found = false
    while index < queue.count && index < 64 {
        let (element, depth) = queue[index]
        index += 1
        let role = attribute(element, kAXRoleAttribute) as? String ?? "?"
        let text = attribute(element, kAXSelectedTextAttribute) as? String
        found = found || text != nil
        print("\(String(repeating: "  ", count: depth))\(role): AXSelectedText \(text.map { "supported, \($0.count) characters" } ?? "unavailable")")
        queue.append(contentsOf: children(element).prefix(max(0, 64 - queue.count)).map { ($0, depth + 1) })
    }
    exit(found ? 0 : 5)
}

func selfTest() {
    var gate = SelectionGate()
    precondition(gate.observe(context: "A", text: "old selection", dragging: false) == nil)
    precondition(gate.observe(context: "A", text: "", dragging: false) == nil)
    precondition(gate.observe(context: "A", text: "partial", dragging: true) == nil)
    precondition(gate.observe(context: "A", text: "complete\n", dragging: false) == "complete\n")
    precondition(gate.observe(context: "A", text: "complete\n", dragging: false) == nil)
    precondition(gate.observe(context: "A", text: nil, dragging: false) == nil)
    precondition(gate.observe(context: "A", text: "complete\n", dragging: false) == nil)
    precondition(gate.observe(context: nil, text: nil, dragging: false) == nil)
    precondition(gate.observe(context: "A", text: "complete\n", dragging: false) == nil)
    precondition(gate.observe(context: "A", text: "new", dragging: false) == "new")
    precondition(gate.observe(context: "B", text: "another window", dragging: false) == nil)
    print("Selection gate: 11 checks passed.")
    precondition(shortcut(key: 123, flags: .maskCommand)?.0 == 0)
    precondition(shortcut(key: 124, flags: .maskCommand)?.0 == 14)
    precondition(shortcut(key: 123, flags: .maskControl)?.0 == 48)
    precondition(shortcut(key: 123, flags: .maskControl)?.1 == [.maskControl, .maskShift])
    precondition(shortcut(key: 124, flags: .maskControl)?.1 == .maskControl)
    precondition(shortcut(key: 123, flags: [.maskCommand, .maskShift]) == nil)
    precondition(shortcut(key: 123, flags: .maskAlternate) == nil)
    precondition(shortcut(key: 0, flags: .maskCommand) == nil)
    print("Keyboard mappings: 8 checks passed.")
}

if CommandLine.arguments.contains("--self-test") { selfTest(); exit(0) }
if CommandLine.arguments.contains("--probe") { probe() }
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
