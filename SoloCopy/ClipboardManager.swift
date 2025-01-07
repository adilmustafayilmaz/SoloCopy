import Foundation
import AppKit
import SwiftUI

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var searchText: String = ""
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?
    
    @AppStorage("maxStoredItems") private var maxStoredItems: Int = 50
    @AppStorage("autoDeleteOldItems") private var autoDeleteOldItems: Bool = true
    
    init() {
        self.lastChangeCount = pasteboard.changeCount
        loadItems()
        startMonitoring()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    
    private func checkForChanges() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        
        if let newString = pasteboard.string(forType: .string) {
            addItem(text: newString)
        }
    }
    
    func addItem(text: String) {
        let newItem = ClipboardItem(text: text)
        DispatchQueue.main.async {
            if let existingIndex = self.items.firstIndex(where: { $0.text == text }) {
                self.items.remove(at: existingIndex)
            }
            
            self.items.insert(newItem, at: 0)
            
            if self.autoDeleteOldItems && self.items.count > self.maxStoredItems {
                let itemsToKeep = self.items.prefix(self.maxStoredItems)
                self.items = Array(itemsToKeep)
            }
            
            self.saveItems()
        }
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
        saveItems()
    }
    
    func toggleStar(for item: ClipboardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isStarred.toggle()
            if items[index].isStarred {
                let starredItem = items.remove(at: index)
                items.insert(starredItem, at: 0)
            }
            saveItems()
        }
    }
    
    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "savedItems")
        }
    }
    
    private func loadItems() {
        if let savedItems = UserDefaults.standard.data(forKey: "savedItems"),
           let decodedItems = try? JSONDecoder().decode([ClipboardItem].self, from: savedItems) {
            items = decodedItems
        }
    }
    
    func copyToClipboard(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
} 