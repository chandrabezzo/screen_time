import Flutter
import UIKit

public class ScreenTimePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "screen_time", binaryMessenger: registrar.messenger())
    let instance = ScreenTimePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case MethodName.requestPermission:
            let args = call.arguments as! [String : Any]
            let permissionTypeInString = args[Argument.permissionType] as! String
            
            let permissionType = ScreenTimePermissionType(rawValue: permissionTypeInString)
            if(permissionType == nil){
                result(false)
            }
            else {
                Task {
                    let response = await ScreenTimeMethod.requestPermission(type: permissionType!)
                    result(response)
                }
            }
        case MethodName.permissionStatus:
            let args = call.arguments as! [String : Any]
            let permissionTypeInString = args[Argument.permissionType] as! String
            
            let permissionType = ScreenTimePermissionType(rawValue: permissionTypeInString)
            if(permissionType == nil){
                result(false)
            }
            else {
                Task {
                    let response = await ScreenTimeMethod.permissionStatus(type: permissionType!)
                    result(String(describing: response))
                }
            }
        case MethodName.showFamilyActivityPicker:
            ScreenTimeMethod.showFamilyActivityPicker(result: result)
        default:
          result(FlutterMethodNotImplemented)
    }
  }
}
