//
//  AppDelegate.m
//  VFShoppingMall
//
//  Created by gushi on 16/9/27.
//  Copyright © 2016年 jinyuankeji. All rights reserved.
//

#import "AppDelegate.h"
#import "GSTabBarController.h"
#import "WXApi.h"
#import "payRequsestHandler.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    GSTabBarController * tabBarVC = [[GSTabBarController alloc]init];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabBarVC;
    
    //wxb4ba3c02aa476ea1
    //1.导入微信支付SDK，注册微信支付
    //2.甚至微信APPID为URL Schemes
    //3.发起支付，调起微信支付
    //4.处理支付结构
    [WXApi registerApp:APP_ID withDescription:@"com.goodboy.heyang"];
    
    return YES;
}
#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    //    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
    //        if (_delegate
    //            && [_delegate respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
    //            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
    //            [_delegate managerDidRecvMessageResponse:messageResp];
    //        }
    //    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
    //        if (_delegate
    //            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
    //            SendAuthResp *authResp = (SendAuthResp *)resp;
    //            [_delegate managerDidRecvAuthResponse:authResp];
    //        }
    //    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
    //        if (_delegate
    //            && [_delegate respondsToSelector:@selector(managerDidRecvAddCardResponse:)]) {
    //            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
    //            [_delegate managerDidRecvAddCardResponse:addCardResp];
    //        }
    //    }else
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg,*strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK（这个是将支付宝客户端的支付结果传回给SDK）
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService]
         processOrderWithPaymentResult:url
         standbyCallback:^(NSDictionary *resultDic)
         {
             NSLog(@" ------result = %@",resultDic);//返回的支付结果
         }];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark-微信支付

//+ (NSString *)jumpToBizPay {
//    //判断是否安装了微信
//    if (![WXApi isWXAppInstalled]) {
//        NSLog(@"没有安装微信");
//        return nil;
//    }
//    else if (![WXApi isWXAppSupportApi]){
//        NSLog(@"不支持微信支付");
//        return nil;
//    }
//    NSLog(@"安装了微信，而且微信支持支付");
//
//
//    //============================================================
//    // V3&V4支付流程实现
//    // 注意:参数配置请查看服务器端Demo
//    // 更新时间：2015年11月20日
//    //============================================================
//    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
//    //解析服务端返回json数据
//    NSError *error;
//    //加载一个NSURL对象
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    //将请求的url数据放到NSData对象中
//    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    if ( response != nil) {
//        NSMutableDictionary *dict = NULL;
//        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
//        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
//        NSLog(@"%@",dict);
//        NSLog(@"url:%@",urlString);
//        if(dict != nil){
//            NSMutableString *retcode = [dict objectForKey:@"retcode"];
//            if (retcode.intValue == 0){
//                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
//
//                //调起微信支付
//                PayReq* req             = [[PayReq alloc] init];
//                req.partnerId           = [dict objectForKey:@"partnerid"];
//                req.prepayId            = [dict objectForKey:@"prepayid"];
//                req.nonceStr            = [dict objectForKey:@"noncestr"];
//                req.timeStamp           = stamp.intValue;
//                req.package             = [dict objectForKey:@"package"];
//                req.sign                = [dict objectForKey:@"sign"];
//                [WXApi sendReq:req];
//                //日志输出
//                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
//                return @"";
//            }else{
//                return [dict objectForKey:@"retmsg"];
//            }
//        }else{
//            return @"服务器返回错误，未获取到json对象";
//        }
//    }else{
//        return @"服务器返回错误";
//    }
//}

//-(void)WXsendPay:(NSString *)odid payid:(NSString *)pid price:(float)moeny{
//    //判断是否安装了微信
//    if (![WXApi isWXAppInstalled]) {
//        NSLog(@"没有安装微信");
//        return ;
//    }
//    else if (![WXApi isWXAppSupportApi]){
//        NSLog(@"不支持微信支付");
//        return ;
//    }
//    NSLog(@"安装了微信，而且微信支持支付");
//
//
//    //创建支付签名对象
//    payRequsestHandler *req = [[payRequsestHandler alloc] init];
//    //初始化支付签名对象
//    [req init:APP_ID mch_id:MCH_ID];
//    //设置密钥
//    [req setKey:PARTNER_ID];
//
//    NSMutableDictionary *dict = [req sendPay:@"VF商城" odid:pid payid:odid moeny:moeny];
//
//    if(dict != nil){
//        NSMutableString *retcode = [dict objectForKey:@"retcode"];
//        if (retcode.intValue == 0){
//            NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
//
//            //调起微信支付
//            PayReq* req             = [[PayReq alloc] init];
//            req.partnerId           = [dict objectForKey:@"partnerid"];
//            req.prepayId            = [dict objectForKey:@"prepayid"];
//            req.nonceStr            = [dict objectForKey:@"noncestr"];
//            req.timeStamp           = stamp.intValue;
//            req.package             = [dict objectForKey:@"package"];
//            req.sign                = [dict objectForKey:@"sign"];
//            [WXApi sendReq:req];
//            //日志输出
//            NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
//        }else{
//
//            NSLog(@"%@",[dict objectForKey:@"retmsg"]);
//        }
//    }else{
//        NSLog(@"服务器返回错误，未获取到json对象");
//    }
//}

@end
