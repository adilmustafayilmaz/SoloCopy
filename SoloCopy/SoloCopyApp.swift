//
//  SoloCopyApp.swift
//  SoloCopy
//
//  Created by Adil Mustafa Yılmaz on 6.01.2025.
//

import SwiftUI
import ServiceManagement

@main
struct SoloCopyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            // Remove all default menu items
            CommandGroup(replacing: .appInfo) {}
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .pasteboard) {}
            CommandGroup(replacing: .undoRedo) {}
            CommandGroup(replacing: .systemServices) {}
            CommandGroup(replacing: .windowSize) {}
            CommandGroup(replacing: .windowList) {}
            CommandGroup(replacing: .help) {}
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var menu: NSMenu?
    var preferencesWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
        
        setupStatusItem()
        setupMenu()
        setupPopover()
        
        // Check if this is first launch
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            showStartupAlert()
        }
    }
    
    private func showStartupAlert() {
        let alert = NSAlert()
        alert.messageText = "Otomatik Başlatma"
        alert.informativeText = "SoloCopy'nin bilgisayarınız başlatıldığında otomatik olarak açılmasını ister misiniz?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Evet, Ayarları Aç")
        alert.addButton(withTitle: "Hayır")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openSystemSettings()
        }
    }
    
    private func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem?.button {
            statusButton.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "SoloCopy")
            statusButton.target = self
            statusButton.action = #selector(handleStatusItemClick)
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupMenu() {
        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: "Ayarlar", action: #selector(openPreferences), keyEquivalent: ","))
        menu?.addItem(NSMenuItem(title: "Başlangıçta Çalıştır", action: #selector(openStartupSettings), keyEquivalent: ""))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: "Çıkış", action: #selector(quit), keyEquivalent: "q"))
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
    }
    
    @objc func handleStatusItemClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        
        if event?.type == .rightMouseUp {
            menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height + 5), in: sender)
        } else {
            togglePopover()
        }
    }
    
    @objc func openPreferences() {
        if preferencesWindow == nil {
            let contentView = PreferencesView()
            let hostingController = NSHostingController(rootView: contentView)
            
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            
            preferencesWindow?.center()
            preferencesWindow?.title = "SoloCopy Ayarları"
            preferencesWindow?.contentViewController = hostingController
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openStartupSettings() {
        openSystemSettings()
    }
    
    func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
