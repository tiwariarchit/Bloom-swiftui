//
//  KeepAway.swift
//  quit_porn
//
//  Created by Archit Kumar  on 21/02/26.
//

import SwiftUI

struct KeepAwayScreen: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var eyesClosed = false
    @State private var headStraight = false
    @State private var countdown = 10
    @State private var isCompleted = false
    @State private var selectedDuration: TimeInterval = 10
    
    var body: some View {
        ZStack {
            
            // 👇 BINDING PASSED HERE
            ARKeepAwayView(
                eyesClosed: $eyesClosed,
                headStraight: $headStraight
            )
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                if isCompleted {
                    Text("Meditation Complete ✅")
                        .font(.title)
                        .bold()
                        .foregroundColor(.green)
                } else if eyesClosed {
                    VStack(spacing: 8) {
                        Text("Good. Stay Still 🧘")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
                        Text("\(countdown)")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Text("Close Your Eyes")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

