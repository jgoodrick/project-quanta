//
//  VanillaApp.swift
//  Core
//
//  Created by Joseph Goodrick on 2/1/25.
//

import SwiftUI
import StructuralModel

public struct VanillaApp: View {
    let entity: Entity = .entry(Entry.init(id: .mock(0)))
    
    public var body: some View {
        Text("\(entity.id)")
    }
}

#Preview {
    VanillaApp()
}
