//
//  FamilyActivityPickerView.swift
//  Pods
//
//  Created by Chandra Abdul Fattah on 01/05/25.
//

import SwiftUI
import FamilyControls

// Custom font extension
extension Font {
    static func carbonBold(size: CGFloat) -> Font {
        return Font.custom("Carbon-Bold", size: size)
    }
}

struct FamilyActivityPickerView: View {
    @State private var selection = FamilyActivitySelection()
    @State private var noAppsAlert = false
    @State private var selectedTab: PickerTab = .apps
    @State private var searchText: String = ""
    
    let onSelectionChanged: (FamilyActivitySelection) -> Void
    let onCancel: () -> Void
    
    enum PickerTab {
        case apps
        case categories
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Cancel and Save buttons
            HStack {
                Button(action: {
                    onCancel()
                }) {
                    Text("Cancel")
                        .font(.carbonBold(size: 16))
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
                        .font(.carbonBold(size: 16))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            // Choose Item title with count
            HStack(spacing: 8) {
                Text("Choose Item")
                    .font(.carbonBold(size: 28))
                
                Text("(0/122)")
                    .font(.carbonBold(size: 28))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $searchText)
                    .font(.carbonBold(size: 16))
            }
            .padding(10)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Tabs for Apps and Categories
            HStack(spacing: 0) {
                // Apps Tab
                Button(action: {
                    selectedTab = .apps
                }) {
                    Text("Apps (0/122)")
                        .font(.carbonBold(size: 16))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == .apps ? Color.black : Color(.systemGray5))
                        .foregroundColor(selectedTab == .apps ? .white : .black)
                        .cornerRadius(8)
                }
                
                // Category Tab
                Button(action: {
                    selectedTab = .categories
                }) {
                    Text("Category (0/8)")
                        .font(.carbonBold(size: 16))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == .categories ? Color.black : Color(.systemGray5))
                        .foregroundColor(selectedTab == .categories ? .white : .black)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // FamilyActivityPicker for app selection
            FamilyActivityPicker(selection: $selection)
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
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
