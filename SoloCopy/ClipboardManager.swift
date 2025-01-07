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
    private let maxStarredItems = 5
    
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
    
    private func sortItems() {
        items.sort { (item1, item2) -> Bool in
            if item1.isStarred && !item2.isStarred {
                return true
            } else if !item1.isStarred && item2.isStarred {
                return false
            } else {
                return item1.createdAt > item2.createdAt
            }
        }
    }
    
    func addItem(text: String) {
        let newItem = ClipboardItem(text: text)
        DispatchQueue.main.async {
            if let existingIndex = self.items.firstIndex(where: { $0.text == text }) {
                // Eğer öğe yıldızlıysa, yıldızını koru
                let isStarred = self.items[existingIndex].isStarred
                self.items.remove(at: existingIndex)
                var updatedItem = newItem
                updatedItem.isStarred = isStarred
                self.items.insert(updatedItem, at: 0)
            } else {
                self.items.insert(newItem, at: 0)
            }
            
            if self.autoDeleteOldItems && self.items.count > self.maxStoredItems {
                // Yıldızlı öğeleri koru, yıldızsız en eski öğeleri sil
                let starredItems = self.items.filter { $0.isStarred }
                let unstarredItems = self.items.filter { !$0.isStarred }
                let keepUnstarredCount = self.maxStoredItems - starredItems.count
                let keptUnstarredItems = Array(unstarredItems.prefix(keepUnstarredCount))
                self.items = starredItems + keptUnstarredItems
            }
            
            self.sortItems()
            self.saveItems()
        }
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
        sortItems()
        saveItems()
    }
    
    func toggleStar(for item: ClipboardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let currentlyStarred = items[index].isStarred
            
            if !currentlyStarred {
                // Yıldızlamak istiyoruz, limit kontrolü yapalım
                let starredCount = items.filter { $0.isStarred }.count
                if starredCount >= maxStarredItems {
                    // Limit aşıldı, işlemi iptal et
                    return
                }
            }
            
            items[index].isStarred.toggle()
            sortItems()
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
            sortItems()
        }
    }
    
    func copyToClipboard(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func getStarredItemsCount() -> Int {
        return items.filter { $0.isStarred }.count
    }
    
    func canAddStarredItem() -> Bool {
        return getStarredItemsCount() < maxStarredItems
    }
} 