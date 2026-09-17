
import SwiftUI

struct TimeSelectionSheet: View {
    
    @Binding var selectedDuration: Int
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Select Meditation Time")
                .font(.title2.bold())
            
            Picker("Duration", selection: $selectedDuration) {
                ForEach(10...300, id: \.self) { value in
                    if value % 10 == 0 {
                        Text("\(value) sec").tag(value)
                    }
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            
            Button("Start Meditation") {
                onStart()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
    }
}
