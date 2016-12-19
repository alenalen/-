//
//  AddressBookManger.m
//  读取本地联系人
//
//  Created by Alen on 2016/12/16.
//  Copyright © 2016年 JingKeCompany. All rights reserved.
//

#import "AddressBookManger.h"


@interface AddressBookManger ()<ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic,weak)ReadAddressBookResultBlock readResultBlock;
//设置传值
- (void)canReadAddressBookWithBlock:(AddressBookBlock)block;

@end

@implementation AddressBookManger

+ (instancetype)shareManger{
    static AddressBookManger *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manger) {
            manger = [[AddressBookManger alloc]init];
        }
    });
    return manger;
}

- (id)init{
    self = [super init];
    if (self) {
        _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    return self;
}



#pragma mark - Method
//获取读取权限
- (void)canReadAddressBookWithBlock:(AddressBookBlock)block{
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    if (authStatus == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    //拒绝访问
                    block(NO,kABAuthorizationStatusDenied);
                }else{
                    block(YES,0);
                }
            });
        });
    }else if (authStatus == kABAuthorizationStatusAuthorized){
        block(YES,0);
    }else{
        block(NO,authStatus);
    }
}


- (void)currentReadVC:(id)vc readAdressBookResult:(ReadAddressBookResultBlock)readAddressBookResultBlock{

    _readResultBlock = readAddressBookResultBlock;
    
    [self canReadAddressBookWithBlock:^(BOOL canRead, ABAuthorizationStatus authorStatus) {
        if (canRead) {
            // 1.创建选择联系人的控制器
            ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
            // 2.设置代理
            ppnc.peoplePickerDelegate = self;
            if([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0){ // iOS系统版本 >= 8.0
                ppnc.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
            }
            // 3.弹出控制器
            [vc presentViewController:ppnc animated:YES completion:nil];
        }
    }];
}

//去设置页面
- (void)gotoSetting:(UIViewController *)vc{
    NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
    NSString *message = [NSString stringWithFormat:@"请在%@的\"设置-隐私-通讯录\"选项中，\r允许%@访问你的通讯录。",[UIDevice currentDevice].model,appName];
    
    UIAlertController *alertVC = [[UIAlertController alloc]init];
    [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancleAction];
    [alertVC addAction:sureAction];
}


//获得选中person的信息
- (void)displayPerson:(ABRecordRef)person
{
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *middleName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSMutableString *nameStr = [NSMutableString string];
    if (lastname!=nil) {
        [nameStr appendString:lastname];
    }
    if (middleName!=nil) {
        [nameStr appendString:middleName];
    }
    if (firstName!=nil) {
        [nameStr appendString:firstName];
    }
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"[None]";
    }
    
    //可以把-、+86、空格这些过滤掉
    NSString *phoneStr = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    _readResultBlock(nameStr,phoneStr);
}


#pragma mark - <ABPeoplePickerNavigationControllerDelegate>

// 当用户选中某一个联系人的某一个属性时会执行该方法,并且选中属性后会退出控制器
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self displayPerson:person];
    [peoplePicker dismissViewControllerAnimated:YES completion:^{}];
}


- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.displayedPerson = person;
    [peoplePicker pushViewController:personViewController animated:YES];
}


//这个方法在用户取消选择时调用
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:^{}];
}

@end
