import SwiftUI

struct PanicSheetView: View {
    
    @Binding var selectedTab: Int
    var onRelapseConfirmed: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var showRelapseAlert = false
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            Text("Take a Breath")
                .font(.title.bold())
            
            Text("This urge will pass.\nChoose your next step wisely.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                selectedTab = 2
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "leaf.fill")
                    Text("Go to Meditate")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            Button {
                showRelapseAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Confirm Relapse")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            
            Button("💪 I Resisted") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
        .alert("Are you sure?", isPresented: $showRelapseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Reset Streak", role: .destructive) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                onRelapseConfirmed()
                dismiss()
            }
        } message: {
            Text("This will reset your current streak.")
        }
    }
}
