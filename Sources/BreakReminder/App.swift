import AppKit
import Foundation

struct BreakClock {
    var workSeconds: TimeInterval = 25 * 60
    var breakSeconds: TimeInterval = 5 * 60
    var deadline: Date
    var onBreak = false
    var paused = false
    var remaining: TimeInterval = 0
    init(now: Date) { deadline = now.addingTimeInterval(25 * 60) }
    mutating func toggle(now: Date) {
        if paused { deadline = now.addingTimeInterval(remaining); paused = false }
        else { remaining = max(0, deadline.timeIntervalSince(now)); paused = true }
    }
    mutating func snooze(now: Date) { onBreak = false; paused = false; deadline = now.addingTimeInterval(5 * 60) }
    mutating func restart(minutes: Int, now: Date) { workSeconds = TimeInterval(minutes * 60); onBreak = false; paused = false; deadline = now.addingTimeInterval(workSeconds) }
    mutating func tick(now: Date) -> Bool {
        guard !paused, now >= deadline else { return false }
        onBreak.toggle(); deadline = now.addingTimeInterval(onBreak ? breakSeconds : workSeconds); return true
    }
    func seconds(now: Date) -> Int { Int(ceil(max(0, paused ? remaining : deadline.timeIntervalSince(now)))) }
}
@MainActor final class Delegate: NSObject, NSApplicationDelegate {
    var item: NSStatusItem!
    var timer: Timer?
    var clock = BreakClock(now: Date())
    var panel: NSPanel?
    let message = NSTextField(labelWithString: "")
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let menu = NSMenu()
        func add(_ title: String, _ action: Selector) { let entry = NSMenuItem(title: title, action: action, keyEquivalent: ""); entry.target = self; menu.addItem(entry) }
        add("Pause / resume", #selector(pause))
        add("Snooze for 5 minutes", #selector(snooze))
        add("Work for 25 minutes", #selector(work25))
        add("Work for 50 minutes", #selector(work50))
        menu.addItem(.separator()); add("Quit", #selector(quit)); item.menu = menu
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }
        update()
    }
    func update() {
        let now = Date()
        if clock.tick(now: now) {
            if clock.onBreak { showBreak() } else { panel?.orderOut(nil) }
        }
        let seconds = clock.seconds(now: now)
        item.button?.title = String(format: "%@ %02d:%02d", clock.paused ? "Ⅱ" : clock.onBreak ? "Break" : "Focus", seconds / 60, seconds % 60)
        message.stringValue = "Time for a short break.\n\(seconds / 60)m \(seconds % 60)s remaining"
    }
    func showBreak() {
        if panel == nil {
            let window = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 420, height: 190), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.title = "A moment away"; window.isReleasedWhenClosed = false; window.level = .floating
            message.frame = NSRect(x: 25, y: 85, width: 370, height: 65); message.font = .systemFont(ofSize: 22); message.maximumNumberOfLines = 3; window.contentView?.addSubview(message)
            let button = NSButton(title: "Snooze 5 minutes", target: self, action: #selector(snooze)); button.frame = NSRect(x: 110, y: 25, width: 200, height: 35); window.contentView?.addSubview(button)
            panel = window
        }
        panel?.center(); panel?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true); NSSound.beep()
    }
    @objc func pause() { clock.toggle(now: Date()); update() }
    @objc func snooze() { clock.snooze(now: Date()); panel?.orderOut(nil); update() }
    @objc func work25() { clock.restart(minutes: 25, now: Date()); panel?.orderOut(nil); update() }
    @objc func work50() { clock.restart(minutes: 50, now: Date()); panel?.orderOut(nil); update() }
    @objc func quit() { timer?.invalidate(); NSApp.terminate(nil) }
}
@main struct BreakReminder {
@MainActor static func main() {
if CommandLine.arguments.contains("--self-test") {
    let now = Date(timeIntervalSince1970: 0); var clock = BreakClock(now: now)
    precondition(clock.seconds(now: now) == 1500)
    clock.toggle(now: now.addingTimeInterval(60)); precondition(clock.seconds(now: now.addingTimeInterval(600)) == 1440)
    clock.toggle(now: now.addingTimeInterval(600)); precondition(clock.tick(now: now.addingTimeInterval(2040))); precondition(clock.onBreak)
    clock.snooze(now: now.addingTimeInterval(2040)); precondition(!clock.onBreak && clock.seconds(now: now.addingTimeInterval(2040)) == 300)
    print("Pause/resume, phase transition, and snooze checks passed")
} else {
    let app = NSApplication.shared; let delegate = Delegate(); app.delegate = delegate; app.run()
}
}
}
