//
//  ViewController.m
//  读取本地联系人
//
//  Created by Alen on 2016/12/16.
//  Copyright © 2016年 JingKeCompany. All rights reserved.
//

#import "ViewController.h"
#import "AddressBookManger.h"

@interface ViewController ()
{
    UITableView *_contactTableView;
    NSMutableArray *data;
}
@property (nonatomic,strong)NSMutableArray *dataSource;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)getLocatContact:(id)sender {
    AddressBookManger *manger = [AddressBookManger shareManger];
    [manger currentReadVC:self readAdressBookResult:^(NSString *name, NSString *phone) {
        self.nameTextField.text = name;
        self.phoneTextField.text = phone;
    }];
}



@end
