//
//  AppConfigs.swift
//  RCSceneVoiceRoomDemo
//
//  Created by 彭蕾 on 2022/5/27.
//

import Foundation
import RCSceneRoom

@objc public class AppConfigs: NSObject {
    @objc public static func config() {
        configRCKey()
        configBaseURL()
        configBusinessToken()
    }

    
    @objc public static func getRCKey() -> String {
        return Environment.rcKey
    }
    
    static func configRCKey() {
        Environment.rcKey = "pvxdm17jpw7ar"
    }
    
    static func configBaseURL() {
        Environment.url = URL(string: "https://rcrtc-api.rongcloud.net/")!
    }
    
    static func configBusinessToken() {
        Environment.businessToken = <#设置BusinessToken#>
    }
    
}
