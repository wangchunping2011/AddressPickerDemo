//
//  ViewController.m
//  AddressPickerDemo
//
//  Created by nhope on 2017/8/2.
//
//

#import "ViewController.h"
#import "XPAddressPicker.h"

@interface ViewController ()<XPAddressPickerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonAction:(UIButton *)sender {
    XPAddressPicker *picker = [[XPAddressPicker alloc] init];
    picker.delegate = self;
    // 设置默认地址
//    [picker setSelectionAddressForId:@"450881"];
    [picker show];
}

- (void)addressPicker:(XPAddressPicker *)picker didFinishPickingAddress:(NSDictionary<NSString *,NSDictionary *> *)info {
    NSDictionary *province = info[XPAddressPickerProvinceKey];
    NSDictionary *city = info[XPAddressPickerCityKey];
    NSDictionary *county = info[XPAddressPickerCountyKey];
    
    NSString *provinceName = province[XPAddressPickerNameKey];
    NSString *cityName = city[XPAddressPickerNameKey];
    
    NSString *ID = city[XPAddressPickerIdKey];
    NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"%@ %@", provinceName, cityName];
    if (nil != county) {
        NSString *countyName = county[XPAddressPickerNameKey];
        ID = county[XPAddressPickerIdKey];
        [string appendFormat:@" %@", countyName];
    }
    [string appendFormat:@" id:%@", ID];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您选择的地址是:" message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
