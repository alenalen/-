//
//  AddressBookManger.h
//  读取本地联系人
//
//  Created by Alen on 2016/12/16.
//  Copyright © 2016年 JingKeCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

typedef void(^AddressBookBlock)(BOOL canRead, ABAuthorizationStatus authorStatus);
typedef void(^ReadAddressBookResultBlock)(NSString *name,NSString *phone);

@interface AddressBookManger : NSObject

@property (nonatomic, assign) ABAddressBookRef addressBook;

+ (instancetype)shareManger;

- (void)currentReadVC:(id)vc readAdressBookResult:(ReadAddressBookResultBlock)readAddressBookResultBlock;

@end
