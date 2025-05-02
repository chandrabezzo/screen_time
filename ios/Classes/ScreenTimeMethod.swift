//
//  ScreenTimeMethod.swift
//  Pods
//
//  Created by Chandra Abdul Fattah on 29/04/25.
//

import FamilyControls
import Flutter
import UIKit
import SwiftUI

class ScreenTimeMethod {
    static func requestPermission(
        type: ScreenTimePermissionType = ScreenTimePermissionType.appUsage
    ) async -> Bool {
        switch type {
            case ScreenTimePermissionType.appUsage,
                 ScreenTimePermissionType.accessibilitySettings,
                 ScreenTimePermissionType.drawOverlay:
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: FamilyControlsMember.individual)
                    print("Request Permission Launched")
                    return true
                } catch {
                    print("Request Permission Failed: \(error.localizedDescription)")
                    return false
                }
            case ScreenTimePermissionType.notification:
                do {
                    try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                    return true
                } catch {
                    return false
                }
        }
    }
    
    static func permissionStatus(type: ScreenTimePermissionType = ScreenTimePermissionType.appUsage) async -> ScreenTimePermissionStatus {
        switch type {
            case ScreenTimePermissionType.appUsage,
                 ScreenTimePermissionType.accessibilitySettings,
                 ScreenTimePermissionType.drawOverlay:
                let status = AuthorizationCenter.shared.authorizationStatus
                let statusEnum = status == .approved ? ScreenTimePermissionStatus.approved :
                    status == .denied ? ScreenTimePermissionStatus.denied : ScreenTimePermissionStatus.notDetermined
                return statusEnum
            case ScreenTimePermissionType.notification:
                return await withCheckedContinuation { continuation in
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        let status: ScreenTimePermissionStatus
                        switch settings.authorizationStatus {
                            case .authorized:
                                status = .approved
                            case .denied:
                                status = .denied
                            default:
                                status = .notDetermined
                        }
                        continuation.resume(returning: status)
                    }
                }
        }
    }
    
    static func showFamilyActivityPicker(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            // Create the SwiftUI view with a callback for when selection changes
            let pickerView = FamilyActivityPickerView { selection in
                // Convert the selection to a dictionary
                var resultDict: [String: Any] = [:]
                
                // Add applications
                let applications = selection.applications
                var applicationsDict: [[String: Any]] = []
                for application in applications {
                    applicationsDict.append([
                        "name": application.localizedDisplayName ?? "-",
                        "token": String(describing: application.token),
                    ])
                }
                resultDict["applications"] = applicationsDict
                
                // Add categories
                let categories = selection.categories
                var categoriesDict: [[String: Any]] = []
                for category in categories {
                    categoriesDict.append([
                        "name": category.localizedDisplayName ?? category.localizedDisplayName,
                        "token": String(describing: category.token)
                    ])
                }
                resultDict["categories"] = categoriesDict
                
                // Add webDomains
                let webDomains = selection.webDomains
                var webDomainsDict: [[String: Any]] = []
                for webDomain in webDomains {
                    webDomainsDict.append([
                        "name": webDomain.domain ?? "-",
                        "token": String(describing: webDomain.token)
                    ])
                }
                resultDict["webDomains"] = webDomainsDict
                
                // Dismiss the view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                } else if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                }
                
                // Return the result through the method channel
                result(resultDict)
            } onCancel: {
                // Dismiss the view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                } else if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                }

                var emptyDict: [String: Any] = [:]
                var emptyContents: [[String: Any]] = []
                emptyDict["applications"] = emptyContents
                emptyDict["categories"] = emptyContents
                emptyDict["webDomains"] = emptyContents
                result(emptyDict)
            }

            
            // Use UIHostingController to present the SwiftUI view in UIKit
            let hostingController = UIHostingController(rootView: pickerView)
            hostingController.modalPresentationStyle = .formSheet
            
            // Present the picker
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(hostingController, animated: true)
            } else if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                // Fallback for older iOS versions
                rootViewController.present(hostingController, animated: true)
            }
        }
    }
}
