//
//  XPAddressPicker.h
//  AddressPicker
//
//  Created by nhope on 2017/7/27.
//

#import <UIKit/UIKit.h>

@class XPAddressPicker;

@protocol XPAddressPickerDelegate <NSObject, UIImagePickerControllerDelegate>

@optional
/// 完成按钮点击事件回调
- (void)addressPicker:(XPAddressPicker *)picker didFinishPickingAddress:(NSDictionary<NSString*, NSDictionary*> *)info;
/// 取消按钮点击事件回调
- (void)addressPickerDidCancel:(XPAddressPicker *)picker;

@end


@interface XPAddressPicker : UIView

@property (nonatomic, weak) id<XPAddressPickerDelegate> delegate;

/**
 显示Picker
 */
- (void)show;

/**
 设置默认选中地址

 @param addressId 选中的地址id
 */
- (void)setSelectionAddressForId:(NSString *)addressId;

@end


/// 从字典中获取省份信息的key
UIKIT_EXTERN NSString * const XPAddressPickerProvinceKey;
/// 从字典中获取城市信息的key
UIKIT_EXTERN NSString * const XPAddressPickerCityKey;
/// 从字典中获取市区信息的key
UIKIT_EXTERN NSString * const XPAddressPickerCountyKey;
/// id key
UIKIT_EXTERN NSString * const XPAddressPickerIdKey;
/// 名称key
UIKIT_EXTERN NSString * const XPAddressPickerNameKey;
