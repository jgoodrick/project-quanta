//
//  NewEntryForm.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 6/29/25.
//

import SwiftUI

struct NewEntryForm: View {
    var body: some View {
        Text("New Entry Form")
    }
}

#Preview { let _ = DB.prepare()
    NewEntryForm()
}
