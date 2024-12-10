//
//  ComplaintListView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-12-02.
//

import SwiftUI

struct ComplaintListView: View {
    @ObservedObject var dbHelper = FireDBHelper.getInstance()
        
        var body: some View {
            VStack {
                Text("Track Complaints")
                    .font(.title)
                    .padding()
                
                List {
                    ForEach(dbHelper.complaintList, id: \.id) { complaint in
                        VStack(alignment: .leading) {
                            Text(complaint.subject)
                                .font(.headline)
                            Text("Message: \(complaint.message)")
                                .font(.subheadline)
                            Text("User ID: \(complaint.userId)")
                                .font(.caption)
                        }
                    }
                }
            }
            .onAppear {
                dbHelper.getUserComplaints()
            }
        }
    }
   
