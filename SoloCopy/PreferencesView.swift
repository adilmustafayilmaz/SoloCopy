import SwiftUI

struct PreferencesView: View {
    @AppStorage("maxStoredItems") private var maxStoredItems: Int = 50
    @AppStorage("autoDeleteOldItems") private var autoDeleteOldItems: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ayarlar")
                .font(.title2)
                .padding(.top)
            
            Form {
                Section {
                    Stepper("Maksimum kayıt sayısı: \(maxStoredItems)", value: $maxStoredItems, in: 10...200, step: 10)
                    Toggle("Limit aşıldığında eski kayıtları otomatik sil", isOn: $autoDeleteOldItems)
                } header: {
                    Text("Genel Ayarlar")
                }
                
                Section {
                    Button("Başlangıçta Çalıştır Ayarları") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                } header: {
                    Text("Sistem")
                }
            }
            .formStyle(.grouped)
            
            Button("Kapat") {
                dismiss()
            }
            .padding(.bottom)
        }
        .frame(width: 400, height: 300)
    }
} 