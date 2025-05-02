//
//  FamilyActivityPickerView.swift
//  Pods
//
//  Created by Chandra Abdul Fattah on 01/05/25.
//

import SwiftUI
import FamilyControls

struct FamilyActivityPickerView: View {
    @State private var selection = FamilyActivitySelection()
    @State private var noAppsAlert = false
    
    let onSelectionChanged: (FamilyActivitySelection) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Cancel and Save buttons
            HStack {
                Button(action: {
                    onCancel()
                }) {
                    Text("Cancel")
                        .font(.system(size: 20))
                        .fontWeight(Font.Weight.regular)
                        .foregroundColor(.black)
                }
                Spacer()
                Button(action: {
                    if selection.applications.isEmpty && selection.categories.isEmpty {
                        noAppsAlert = true
                    } else {
                        onSelectionChanged(selection)
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 20))
                        .fontWeight(Font.Weight.regular)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            // FamilyActivityPicker for app selection
            FamilyActivityPicker(selection: $selection)
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .interactiveDismissDisabled()
        .alert(isPresented: $noAppsAlert) {
            Alert(
                title: Text("No App/Category Selected"),
                message: Text("Please select at least 1 app/category.")
            )
        }
    }
}

struct FamilyActivityPickerViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = UIHostingController(rootView: FamilyActivityPickerView(
            onSelectionChanged: { selection in
                print(String(String(describing: selection)))
            },
            onCancel: {
                print("Cancel Pressed")
            }
        ))
        host.modalPresentationStyle = .formSheet // or .fullScreen, .pageSheet, etc.

        let rootVC = UIViewController()
        DispatchQueue.main.async {
            rootVC.present(host, animated: false, completion: nil)
        }
        return rootVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview {
    FamilyActivityPickerViewWrapper()
}
