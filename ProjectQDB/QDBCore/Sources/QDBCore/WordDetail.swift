//
//  WordDetail.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SharingGRDB
import SwiftUI
import SwiftUINavigation

struct WordDetail: View {
    let id: DB.Entry.ID

    var body: some View {
        Load(request) { value in
            VStack {
                Text(value.spelling.text)
                    .padding()
            }
            .navigationTitle("Detail: \(value.spelling.text)")
        }
    }

    var request: Request { .init(id: id) }
}

#Preview { let _ = DB.prepare()
    WordDetail(id: Mock.English.Entry.hello.id)
        .padding(200)
}
