//
//  UMSNSService.h
//  SNS
//
//  Created by liu yu on 9/15/11.
//  Copyright 2011 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol UMSNSOauthDelegate;
@protocol UMSNSDataSendDelegate;

/*
 All the possible returned result after share to the sns platform
 */

typedef enum {
    UMReturnStatusTypeUpdated = 0,      //success update a new status or send a prvate message
    UMReturnStatusTypeRepeated,         //repeated send, when the current status content is the same to the last one in certain time
    UMReturnStatusTypeFileToLarge,      //image file to be shared is too large, just check the file size, and the uplimit is 2M
    UMReturnStatusTypeExtendSendLimit,  //sending time extend the allowed limit per hour
    UMReturnStatusTypeUnknownError      //sending failed for network problem, platform error or others
} UMReturnStatusType;

/*
 All the supported platform currently
 */

typedef enum {
    UMShareToTypeRenr = 0,              //renren
    UMShareToTypeSina,                  //sina weibo
    UMShareToTypeTenc                   //tencent weibo
} UMShareToType;

/** 
 
 UMSNSService SDK 
 
 */

@interface UMSNSService : NSObject

/** @name Delegate Setting APIs */

/** 
 
 This method set the dalegate for oauth progress, if set, related method defined in protocol UMSNSOauthDelegate will be called 
 when oauth finished successfully or failed, else just return from the oauth view.
 
 @param delegate delegate for UMSNSOauth
 
 */

+ (void) setOauthDelegate:(id<UMSNSOauthDelegate>)delegate;

/** 
 
 This method set the dalegate for data send progress, if set, related method defined in protocol UMSNSDataSendDelegate 
 will be called when data send finished, else nothing happened
 
 @param delegate delegate for UMSNSDataSend
 
 */

+ (void) setDataSendDelegate:(id<UMSNSDataSendDelegate>)delegate;

#pragma mark -
#pragma mark - Default Share

/** @name ShareTextWithoutTemplate */

/** 
 
 This method share message to renren, and the shared message will become a new status
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  newStatus message to be shared
 
 */

+ (void) shareToRenr:(UIViewController *)viewController andAppkey:(NSString *)appkey andStatus:(NSString *)newStatus;

/** 
 
 This method share message to sina weibo, and the shared message will become a new weibo
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  newStatus message to be shared
 
 */

+ (void) shareToSina:(UIViewController *)viewController andAppkey:(NSString *)appkey andStatus:(NSString *)newStatus;

/** 
 
 This method share message to tencent, and the shared message will become a new weibo
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  newStatus message to be shared
 
 */

+ (void) shareToTenc:(UIViewController *)viewController andAppkey:(NSString *)appkey andStatus:(NSString *)newStatus;

/** @name ShareImageAndTextWithoutTemplate */

/** 
 
 This method share image and message to renren, and the image will uploaded to the user Album
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  newStatus message to be shared
 @param  imgPath path for the image to be shared
 
 */

+ (void) shareToRenr:(UIViewController *)viewController andAppkey:(NSString *)appkey andStatus:(NSString *)newStatus andImgPath:(NSString *)imgPath;

/** 
 
 This method share image and message to sina weibo, and the image and message become a new weibo
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  newStatus message to be shared
 @param  imgPath path for the image to be shared
 
 */

+ (void) shareToSina:(UIViewController *)viewController andAppkey:(NSString *)appkey andStatus:(NSString *)newStatus andImgPath:(NSString *)imgPath;

/** 
 
 This method share image and message to tencent weibo, and the image and message become a new weibo
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  newStatus message to be shared
 @param  imgPath path for the image to be shared
 
 */

+ (void) shareToTenc:(UIViewController *)viewController andAppkey:(NSString *)appkey andStatus:(NSString *)newStatus andImgPath:(NSString *)imgPath;

/** @name ShareTextUsingTemplate */

/** 
 
 This method share message to renren, and the shared message will become a new status
 content of the message get according to the share template set on www.umeng.com and shareMap
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  shareMap used to fill the share template
 
 */

+ (void) shareToRenr:(UIViewController *)viewController andAppkey:(NSString *)appkey andShareMap:(NSDictionary *)shareMap;

/** 
 
 This method share message to sina weibo, and the shared message will become a new status
 content of the message get according to the share template set on www.umeng.com and shareMap
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  shareMap used to fill the share template
 
 */

+ (void) shareToSina:(UIViewController *)viewController andAppkey:(NSString *)appkey andShareMap:(NSDictionary *)shareMap;

/** 
 
 This method share message to tencent weibo, and the shared message will become a new status
 content of the message get according to the share template set on www.umeng.com and shareMap
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  shareMap used to fill the share template
 
 */

+ (void) shareToTenc:(UIViewController *)viewController andAppkey:(NSString *)appkey andShareMap:(NSDictionary *)shareMap;

/** @name ShareImageAndTextUsingTemplate */

/** 
 
 This method share image and message to renren
 content of the message get according to the share template set on www.umeng.com and shareMap
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  shareMap used to fill the share template
 @param  imgPath path of the image to be shared
 
 */

+ (void) shareToRenr:(UIViewController *)viewController andAppkey:(NSString *)appkey andShareMap:(NSDictionary *)shareMap andImgPath:(NSString *)imgPath;

/** 
 
 This method share image and message to sina weibo
 content of the message get according to the share template set on www.umeng.com and shareMap
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  shareMap used to fill the share template
 @param  imgPath path of the image to be shared
 
 */

+ (void) shareToSina:(UIViewController *)viewController andAppkey:(NSString *)appkey andShareMap:(NSDictionary *)shareMap andImgPath:(NSString *)imgPath;

/** 
 
 This method share image and message to tencent weibo
 content of the message get according to the share template set on www.umeng.com and shareMap
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 @param  shareMap used to fill the share template
 @param  imgPath path of the image to be shared
 
 */

+ (void) shareToTenc:(UIViewController *)viewController andAppkey:(NSString *)appkey andShareMap:(NSDictionary *)shareMap andImgPath:(NSString *)imgPath;

#pragma mark -
#pragma mark - Data Interface

/** @name Oauth APIs*/
/** 
 
 This method guide user to do the renren oauth 
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 
 */

+ (void) oauthRenr:(id) viewController andAppkey:(NSString *)appkey;

/** 
 
 This method guide user to do the sina weibo oauth 
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 
 */

+ (void) oauthSina:(id) viewController andAppkey:(NSString *)appkey;

/** 
 
 This method guide user to do the tencent weibo oauth 
 
 @param  viewController current view controller
 @param  appkey appkey get from www.umeng.com
 
 */

+ (void) oauthTenc:(id) viewController andAppkey:(NSString *)appkey;

/** @name RebindAccount */

/** 
 
 This method guide user to change the binded sina weibo account
 
 @param  viewController currrent view controller
 @param  appkey appkey get from www.umeng.com
 
 */

+ (void) reBindingSinaAccount:(id) viewController andAppkey:(NSString *)appkey;

/** 
 
 This method guide user to change the binded renren account
 
 @param  viewController currrent view controller
 @param  appkey appkey get from www.umeng.com
 
 */

+ (void) reBindingRenrAccount:(id) viewController andAppkey:(NSString *)appkey;

/** 
 
 This method guide user to change the binded tencent weibo account
 
 @param  viewController currrent view controller
 @param  appkey appkey get from www.umeng.com
 
 */

+ (void) reBindingTencAccount:(id) viewController andAppkey:(NSString *)appkey;

/** @name SNS Share Data interface */

/** 
 
 This method share a string object to sns platform we support currently, Return a UMReturnStatusType variable
 
 @param  to the share to platform
 @param  appkey appkey get from umeng.com
 @param  uid mark for a oauthed user, can get from the oauth delegate method or getUid method
 @param  newStatus content to be shared
 @param  error nil if successfully finished, else error occured

 @return UMReturnStatusType
 */
+ (UMReturnStatusType) update:(UMShareToType)to andAppkey:(NSString *)appkey andUid:(NSString *)uid andStatus:(NSString *)newStatus error:(NSError *)error;

/** 
 
 This method share a string object to sns platform we support currently, 
 the string content is filled according to the share template set at umeng.com and the shareMap object, Return a UMReturnStatusType variable
 
 @param  to the share to platform
 @param  appkey appkey get from umeng.com
 @param  uid mark for a oauthed user, can get from the oauth delegate method or getUid method
 @param  shareMap used to fill the share template, share content will be the filled template accroding to the shareMap
 @param  error nil if successfully finished, else error occured

 @return UMReturnStatusType
 */
+ (UMReturnStatusType) update:(UMShareToType)to andAppkey:(NSString *)appkey andUid:(NSString *)uid andShareMap:(NSDictionary *)shareMap error:(NSError *)error;

/** 
 
 This method share a image and a string object as the description to sns platform we support currently, Return a UMReturnStatusType variable
 
 @param  to the share to platform
 @param  appkey appkey get from umeng.com
 @param  uid mark for a oauthed user, can get from the oauth delegate method or getUid method
 @param  newStatus content to be shared
 @param  imgPath path of the image be shared
 @param  error nil if successfully finished, else error occured

 @return UMReturnStatusType
 */
+ (UMReturnStatusType) update:(UMShareToType)to andAppkey:(NSString *)appkey andUid:(NSString *)uid andStatus:(NSString *)newStatus andImgPath:(NSString *)imgPath error:(NSError *)error;

/** 
 
 This method share a image and a string object as the description to sns platform we support currently
 the string content is filled according to the share template set at umeng.com and the shareMap object, Return a UMReturnStatusType variable
 
 @param  to the share to platform
 @param  appkey appkey get from umeng.com
 @param  uid mark for a oauthed user, can get from the oauth delegate method or getUid method
 @param  shareMap used to fill the share template, share content will be the filled template accroding to the shareMap
 @param  imgPath path of the image be shared
 @param  error nil if successfully finished, else error occured

 @return UMReturnStatusType
 */
+ (UMReturnStatusType) update:(UMShareToType)to andAppkey:(NSString *)appkey andUid:(NSString *)uid andShareMap:(NSDictionary *)shareMap andImgPath:(NSString *)imgPath error:(NSError *)error;

#pragma mark -
#pragma mark - Other Utils Interface
/** @name SNS Share Utils APIs */

/** 
 
 This method return the hot topics of the sns platform currently, Return a NSString array variable, autorelease
 
 @param  userPlatform platform releated to the uid
 @param  appkey appkey get from umeng.com
 @param  uid mark for a oauthed user, can get from the oauth delegate method or getUid method
 @param  error nil if successfully finished, else error occured

 @return A NSString array, nil when error occured
 */
+ (NSArray *)  getHotTopicsList:(UMShareToType)userPlatform andAppkey:(NSString *)appkey andUid:(NSString *)uid error:(NSError *)error;

/** 
 
 This method return the share template set at www.umeng.com for the selected platform, Return a NSString variable, autorelease
 
 @param  appkey appkey get from umeng.com
 @param  to platform type
 @param  error nil if successfully finished, else error occured

 @return template set on www.umeng.com, can set different template for different platform, nil when error occured
 */
+ (NSString *) getShareTemplate:(NSString *)appkey andForPlatform:(UMShareToType)to error:(NSError *)error;

/** 
 
 This method return the uid for the current user for the selected platform, Return a NSString variable, autorelease
 
 @param  appkey appkey get from umeng.com
 @param  to platform type
 @param  error nil if successfully finished, else error occured

 @return mark for a oauthed user, nil when error occured
 */
+ (NSString *) getUid:(NSString *)appkey andForPlatform:(UMShareToType)to error:(NSError *)error;

/** 
 
 This method return the nickname for the current user for the selected platform, Return a NSString variable, autorelease
 
 @param  appkey appkey get from umeng.com
 @param  uid mark for a oauthed user, can get from the oauth delegate method or getUid method
 @param  to platform releated to the uid
 @param  error nil if successfully finished, else error occured

 @return nickname related to the current binded account, nil when error occured
 */
+ (NSString *) getCurrentNickName:(NSString *)appkey andUid:(NSString *) uid andForPlatform:(UMShareToType) to error:(NSError *)error;

/** 
 
 This method send private message for a list of users for the selected platform, Return a NSString variable, autorelease
 
 @param  appkey appkey get from umeng.com
 @param  uid mark for a oauthed user, can get from the oauth delegate method or getUid method
 @param  invitedUid uid of user to be invited
 @param  inviteContent invitation content
 @param  to platform releated to the uid
 @param  error nil if successfully finished, else error occured
 
 @return result, nil when error occured
 */
+ (NSString *) sendInvitation:(NSString *)appkey andUid:(NSString *)uid andInvitedUid:(NSString *)invitedUid andInviteContent:(NSString *)inviteContent andToPlatform:(UMShareToType) to error:(NSError *)error;

/** 
 
 This method return the friends list for the uid for the selected platform
 the keys of the returned dictionary is the friend ids, while the value the nicknames, Return a NSDictionary object, autorelease
 
 @param  userPlatform platform releated to the uid
 @param  appkey appkey get from umeng.com
 @param  uid mark for a oauthed user, can get from the oauth delegate method or getUid method
 @param  error nil if successfully finished, else error occured
 
 @return a NSDictionary object, nil when error occured
 */
+ (NSDictionary *) getFriendsList:(UMShareToType)userPlatform andAppkey:(NSString *)appkey andUid:(NSString *)uid error:(NSError *)error;

/** 
 
 This method return access token for the uid for the selected platform, Return a NSDictionary object, autorelease
 
 @param  userPlatform platform releated to the uid
 
 @return return access token for the current user, return nil if the has not oauthed for the userPlatform
 */
+ (NSDictionary *) getAccessToken:(UMShareToType)userPlatform;

@end

#pragma mark -
#pragma mark - Protocol definition
/*_______________________________________________________________________________________________________________*/

/** @name UMSNSOauthDelegate */

/**
 
 this protocol provide interface for the oauth progress for the sns platform when oauth successfully finished 
 or failed for some error
 
 */

@protocol UMSNSOauthDelegate <NSObject> 

@optional

/**
 
 This method called when oauth progress finished successfully
 
 @param uid uid for the oauthed account
 @param accessToken access token for the oauthed account
 @param platfrom platform for the oauth, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 */

- (void)oauthDidFinish:(NSString *)uid andAccessToken:(NSDictionary *)accessToken andPlatformType:(UMShareToType)platfrom;

/** 
 
 This method called when oauth progress failed
 
 @param error error that cause the oauth progress failed
 @param platfrom platform for the oauth, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 */

- (void)oauthDidFailWithError:(NSError *)error andPlatformType:(UMShareToType)platfrom;

@end

/*_______________________________________________________________________________________________________________*/

/** @name UMSNSDataSendDelegate */

/** 
 
 this protocol provide interface the data send progress for the sns platform when data send finished successfully 
 or failed for some reason;
 protocol also provide interface for set the default private message content
 
 */

@protocol UMSNSDataSendDelegate <NSObject> 

@optional

/** 
 
 This method called when data send finished successfully or failed for some reason
 
 @param viewController controller of the data send view
 @param returnStatus data send return result
 @param platfrom platform for the data send to, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 */

- (void)dataSendDidFinish:(UIViewController *)viewController andReturnStatus:(UMReturnStatusType)returnStatus andPlatformType:(UMShareToType)platfrom;

/** 
 
 This method called when data send failed for error occured
 
 @param error error that cause data send failed
 @param platfrom platform for the data send to, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 */

- (void)dataSendFailWithError:(NSError *)error andPlatformType:(UMShareToType)platfrom;


/** 
 
 This method return the default private message content
 
 @param  platfrom platform for the private message send to, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @result default private message content  
 
 */

- (NSString *)invitationContent:(UMShareToType)platfrom;

@end

