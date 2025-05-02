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
        VStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center){
                Button(action : {
                    onCancel()
                }) {
                    Text("Cancel").foregroundColor(.blue)
                }
                Spacer()
                Button(action : {
                    if(selection.applications.isEmpty && selection.categories.isEmpty) {
                        noAppsAlert = true
                    } else {
                        onSelectionChanged(selection)
                    }
                }) {
                    Text("Save").foregroundColor(.blue)
                }
            }
            FamilyActivityPicker(selection: $selection)
                .padding(.all, 10)
        }
        .font(.body)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(EdgeInsets(top: 8, leading: 15, bottom: 20, trailing: 15))
        .foregroundColor(.white)
        
        .interactiveDismissDisabled()
        .alert(isPresented: $noAppsAlert) {
            Alert(
                title: Text("No Apps Selected"),
                message: Text("Please select at least 1 app.")
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
