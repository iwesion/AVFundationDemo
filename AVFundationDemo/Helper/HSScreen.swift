//
//  Screen.swift
//  xc
//
//  Created by wesion on 2021/8/17.
//

import UIKit

class HSScreen: NSObject {
    
    /// 获取状态栏高度
    /// - Returns:状态栏高度
    func statusBarHeight() -> CGFloat {
//        var statusBarHeight = 0.0
//        if #available(iOS 13.0, *){
//            let statusBarManager:UIStatusBarManager = UIApplication.shared.windows.first!.windowScene!.statusBarManager!
//            statusBarHeight = Double(Int(statusBarManager.statusBarFrame.size.height));
//        }
//        else {
//            statusBarHeight = Double(UIApplication.shared.statusBarFrame.size.height);
//        }
        
        return CGFloat(Double(UIApplication.shared.statusBarFrame.size.height))
    }
    
    /// 获取navBar高度
    /// - Returns: navBar高度
    func navBarHeight() -> CGFloat {
        return statusBarHeight()+44.0
    }
    
    /// 获取屏幕宽
    /// - Returns: CGFloat
    func width() -> CGFloat {
        return UIScreen.main.bounds.size.width;
    }
    
    ///获取屏高度
    /// - Returns: CGFloat
    func height() -> CGFloat {
        return UIScreen.main.bounds.size.height;
    }
    func tabbarHeight() -> CGFloat {
        
//        let tabBarHeight:CGFloat = UITabBarController.init().tabBar.frame.size.height;
        
        return 49.0 + safeAreaBottom()
    }
    
    func safeAreaBottom() -> CGFloat {
        return isPhoneX() ? 34 : 0
    }
 
    func isPhoneX() -> Bool {
      return  UIScreen.main.bounds.size.width >= 375 && UIScreen.main.bounds.size.height >= 812
    }
    
}
