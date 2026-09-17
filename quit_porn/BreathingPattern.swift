//
//  BreathingPattern.swift
//  quit_porn
//
//  Created by Archit Kumar  on 20/02/26.
//

import Foundation

struct BreathingPattern: Identifiable {
    let id = UUID()
    let name: String
    let inhale: Int
    let hold: Int
    let exhale: Int
    let holdAfterExhale: Int
}
