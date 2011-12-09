//
//  VersionCheckUtil.m
//  MyNav
//
//  Created by 王 攀 on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "VersionCheckUtil.h"

@implementation VersionCheckUtil
@synthesize serverIpaUrl;
@synthesize needLatestAlert;

- (void)checkVersion {
    DLog(@"VersionCheckUtil.checkVersion...");  
    responseData = [[NSMutableData data] retain];
	NSString *url = [[NSString alloc] initWithString:@"http://fd.tourbox.me/getVersionInfo"];
	NSString *post = nil;  
	post = [[NSString alloc] initWithString:@""];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:url]];  
	[request setHTTPMethod:@"POST"]; 
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData];  
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
#pragma mark -
#pragma mark HTTP Response Methods
//HTTP Response - begin
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DLog(@"VersionCheckUtil.connectionDidFinishLoading...");
    /*
     更新检查响应 http:// fd.tourbox.me/getVersionInfo
     */
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
    
    DLog(@"getVersionInfo...");
    NSString *currentVersionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    DLog(@"%@", currentVersionStr);
    
    NSMutableDictionary *versionInfo = [json objectWithString:responseString error:&error];
    NSString *serverVersionStr = [versionInfo objectForKey:@"version"];
    NSString *serverIpaStr = [versionInfo objectForKey:@"ipa"];
    self.serverIpaUrl = serverIpaStr;
    NSString *serverChangelogStr = [versionInfo objectForKey:@"changelog"];
    
    if ([serverVersionStr doubleValue] > [currentVersionStr doubleValue]) {        
        CLMAlertView *alertView = [[CLMAlertView alloc] 
                                   initWithTitle:[[NSString alloc]initWithFormat:@"飞趣v%@上线了，更新内容：",serverVersionStr]
                                   message:serverChangelogStr
                                   delegate:self 
                                   cancelButtonTitle:@"取消"
                                   otherButtonTitles:@"确定", nil];
        alertView.detailTextlAligment = UITextAlignmentLeft;
        //改变alert的背景色
        //alertView.bgImage = [UIImage imageNamed:@"highlightBack.png"];
        [alertView show];
        [alertView release];
    } else {
        if (needLatestAlert) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您的客户端已经是最新版本啦！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    
    [connection release];	
    
}
//HTTP Response - end
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //NSString *url = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=314022946";
        
        NSString *url = self.serverIpaUrl;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
@end
