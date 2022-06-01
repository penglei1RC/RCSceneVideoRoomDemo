//
//  OCCallBridge.swift
//  RCSceneVideoRoomDemo
//
//  Created by 彭蕾 on 2022/6/1.
//

import Foundation
import RCSceneRoom
import RCSceneVideoRoom
import UIKit

@objc class LoginBridge: NSObject {
    @objc static func login(phone: String, name: String, completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString;
        let api = RCLoginService.login(mobile: phone,
                                       code: "123456",
                                       userName: name,
                                       portrait: nil,
                                       deviceId: deviceId,
                                       region: "+86",
                                       platform: "mobile")
        loginProvier.request(api) { result in
            switch result.map(RCSceneWrapper<User>.self) {
            case let .success(wrapper):
                
                guard let user = wrapper.data else {
                    let ocErr = NSError(domain: "login", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapper.msg ?? "登录失败"])
                    completion(false, ocErr)
                    return
                }
                UserDefaults.standard.set(user: user)
                UserDefaults.standard.set(authorization: user.authorization)
                UserDefaults.standard.set(rongCloudToken: user.imToken)
                UserDefaults.standard.set(mobile: phone)
                completion(true, nil)
            case let .failure(error):
                let ocErr = NSError(domain: "login", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
                completion(false, ocErr)
            }
        }
    }
    
    @objc static func isLogin() -> Bool {
        guard let token = UserDefaults.standard.rongToken() else {
            return false
        }
        return token.count > 0
    }
    
    @objc static func logout() {
        UserDefaults.standard.clearLoginStatus()
    }
    
    @objc static func userDefaultsSavedToken() -> String {
        UserDefaults.standard.rongToken()  ?? ""
    }
    
    @objc static func userDefaultsSavedMobile() -> String {
        UserDefaults.standard.mobile()  ?? ""
    }

    @objc static func userDefaultsSavedName() -> String {
        UserDefaults.standard.loginUser()?.userName  ?? ""
    }

}

@objc class VideoRoomBridge:NSObject {
    static let shared = VideoRoomBridge()
    
    var rooms: [RCSceneRoom]?
    
    struct VoiceRoomList: Codable {
        let totalCount: Int
        let rooms: [RCSceneRoom]
        let images: [String]
    }
    
   @objc static func roomList(completion: @escaping (_ rooms: [RoomListRoomModel]?, _ error: NSError?) -> Void) {
        roomProvider.request(.roomList(type: 3, page: 1, size: 20)) { result in
            switch result {
            case let .success(dataResponse):
                let wrapper = try! JSONDecoder().decode(RCSceneWrapper<VoiceRoomList>.self, from: dataResponse.data)
                SceneRoomManager.shared.backgrounds = wrapper.data?.images ?? [""]
                self.shared.rooms = wrapper.data?.rooms
                
                let ocRoomlist = RCNetResponseWrapper.yy_model(withJSON: dataResponse.data)
                completion(ocRoomlist?.data.rooms, nil)

            case let .failure(error):
                let ocErr = NSError(domain: "getRoomList", code: -2, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
                completion(nil, ocErr)
            }
        }
    }
    
    @objc static func createRoom(fromVC: UIViewController) {
       let controller = RCVideoRoomController()
       controller.modalTransitionStyle = .coverVertical
       controller.modalPresentationStyle = .overFullScreen
        fromVC.present(controller, animated: true)
    }
    
    @objc static func joinVoiceRoom(roomId: String, fromVC: UIViewController) {
        guard let roomInfo = self.shared.rooms?.filter({ $0.roomId == roomId }).first else {
            return
        }
        let controller = RCVideoRoomController(room: roomInfo)
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .overFullScreen
        fromVC.present(controller, animated: true)
    }
}
