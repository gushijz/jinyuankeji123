//
//  ViewController.m
//  微信支付Demo
//
//  Created by gushi on 16/10/25.
//  Copyright © 2016年 gushi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark-扩展分类Clicked
-(void)expandListBtn1Clicked{
    //    [self jumpToBizPay];
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString * timeStr =  [dateformatter stringFromDate:senddate];
    NSLog(@"%@",timeStr);
    
    [self WXsendPay:timeStr payid:timeStr price:0.02];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
#pragma mark-微信支付

- (NSString *)jumpToBizPay {
    //判断是否安装了微信
    if (![WXApi isWXAppInstalled]) {
        NSLog(@"没有安装微信");
        return nil;
    }
    else if (![WXApi isWXAppSupportApi]){
        NSLog(@"不支持微信支付");
        return nil;
    }
    NSLog(@"安装了微信，而且微信支持支付");
    
    
    //============================================================
    // V3&V4支付流程实现
    // 注意:参数配置请查看服务器端Demo
    // 更新时间：2015年11月20日
    //============================================================
    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
    //解析服务端返回json数据
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if ( response != nil) {
        NSMutableDictionary *dict = NULL;
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        
        NSLog(@"url:%@",urlString);
        if(dict != nil){
            NSMutableString *retcode = [dict objectForKey:@"retcode"];
            if (retcode.intValue == 0){
                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                req.partnerId           = [dict objectForKey:@"partnerid"];
                req.prepayId            = [dict objectForKey:@"prepayid"];
                req.nonceStr            = [dict objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.package             = [dict objectForKey:@"package"];
                req.sign                = [dict objectForKey:@"sign"];
                [WXApi sendReq:req];
                //日志输出
                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                return @"";
            }else{
                return [dict objectForKey:@"retmsg"];
            }
        }else{
            return @"服务器返回错误，未获取到json对象";
        }
    }else{
        return @"服务器返回错误";
    }
}
-(void)WXsendPay:(NSString *)odid payid:(NSString *)pid price:(float)moeny{
    //判断是否安装了微信
    if (![WXApi isWXAppInstalled]) {
        NSLog(@"没有安装微信");
        return ;
    }
    else if (![WXApi isWXAppSupportApi]){
        NSLog(@"不支持微信支付");
        return ;
    }
    NSLog(@"安装了微信，而且微信支持支付");
    
    
    //创建支付签名对象
    payRequsestHandler *req = [[payRequsestHandler alloc] init];
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    NSMutableDictionary *dict = [req sendPay:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] odid:pid payid:odid moeny:moeny];
    
    NSLog(@"%@",dict);
    if(dict != nil){
        NSMutableString *retcode = [dict objectForKey:@"retcode"];
        if (retcode.intValue == 0){
            NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
            
            //调起微信支付
            PayReq* req             = [[PayReq alloc] init];
            req.partnerId           = [dict objectForKey:@"partnerid"];
            req.prepayId            = [dict objectForKey:@"prepayid"];
            req.nonceStr            = [dict objectForKey:@"noncestr"];
            req.timeStamp           = stamp.intValue;
            req.package             = [dict objectForKey:@"package"];
            req.sign                = [dict objectForKey:@"sign"];
            [WXApi sendReq:req];
            //日志输出
            NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
        }else{
            
            NSLog(@"%@",[dict objectForKey:@"retmsg"]);
        }
    }else{
        NSLog(@"服务器返回错误，未获取到json对象");
    }
}
#pragma mark-支付宝支付

-(void)expandListBtn2Clicked{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString * timeStr =  [dateformatter stringFromDate:senddate];
    NSString * str = [NSString stringWithFormat:@"%@测试",timeStr];
    NSLog(@"%@",str);
    
    //    [self aliPay:timeStr money:0.02 type:1];
}

#pragma mark 支付宝

-(void)aliPay:(NSString *)odid money:(float)payMoney type:(int)payType{
    
    
    AliPayModel *order = [[AliPayModel alloc] init];
    order.partner = AliPartner;
    order.seller = AliSeller;
    
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString * timeStr =  [dateformatter stringFromDate:senddate];
    
    NSLog(@"%@",timeStr);
    //    order.tradeNO = self.payId; //订单ID（由商家自行制定）
    order.tradeNO = timeStr; //订单ID（由商家自行制定）
    
    
    order.productName = [NSString stringWithFormat:@"%@%@%@", @"黄蚬子", @"iOS支付，订单号:",odid]; //商品标题
    order.productDescription = [NSString stringWithFormat:@"订单编号：%@,%@", self.payId,odid]; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",payMoney]; //商品价格
    //回调地址
    order.notifyURL = [NSString stringWithFormat:@"http%%3A%%2F%%2F%@%%2FAlipay%%2Fiosnotify.aspx", HOST];
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    self.payId = nil;//每次支付都要重新获取
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(AliPrivateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        NSString *appScheme = @"AliPayHangJing";
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            int state = [[resultDic objectForKey:@"resultStatus"] intValue];
            NSNotification* notification;
            
            if (state == 9000) {
                
                notification = [NSNotification notificationWithName:APP_URL_COMBACK object:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }else if(state == 6001){
                
                //                notification = [NSNotification notificationWithName:APP_URL_COMBACK object:nil];
                //                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }else{
                //                notification = [NSNotification notificationWithName:@"AlipayCallBackError" object:nil];
                //                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
            
        }];
        
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
