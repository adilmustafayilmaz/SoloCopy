//
//  ContentView.swift
//  SoloCopy
//
//  Created by Adil Mustafa Yılmaz on 6.01.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    @State private var showStarLimitAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Ara...", text: $clipboardManager.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(Color(.textBackgroundColor))
            
            // List of clipboard items
            ScrollViewReader { proxy in
                List {
                    ForEach(clipboardManager.filteredItems) { item in
                        ClipboardItemView(item: item, clipboardManager: clipboardManager, onStarLimitReached: {
                            showStarLimitAlert = true
                        })
                        .id(item.id)
                    }
                }
                .onChange(of: clipboardManager.items) { newItems in
                    if let firstItem = newItems.first {
                        withAnimation {
                            proxy.scrollTo(firstItem.id, anchor: .top)
                        }
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
        .alert("Favori Limiti", isPresented: $showStarLimitAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("En fazla 5 öğeyi favorilere ekleyebilirsiniz.")
        }
    }
}

struct ClipboardItemView: View {
    let item: ClipboardItem
    @ObservedObject var clipboardManager: ClipboardManager
    var onStarLimitReached: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.text)
                    .lineLimit(2)
                Text(item.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    if !item.isStarred && !clipboardManager.canAddStarredItem() {
                        onStarLimitReached()
                    } else {
                        clipboardManager.toggleStar(for: item)
                    }
                }) {
                    Image(systemName: item.isStarred ? "star.fill" : "star")
                        .foregroundColor(item.isStarred ? .yellow : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    clipboardManager.copyToClipboard(item.text)
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                if let index = clipboardManager.items.firstIndex(where: { $0.id == item.id }) {
                    Button(action: {
                        clipboardManager.removeItem(at: index)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
