//
//  XPAddressPicker.m
//  AddressPicker
//
//  Created by nhope on 2017/7/27.
//

#import "XPAddressPicker.h"

/// Picker视图的高度
#define kPickerHeight (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 389.0 : 249.0)


NSString * const XPAddressPickerProvinceKey     =   @"province";
NSString * const XPAddressPickerCityKey         =   @"city";
NSString * const XPAddressPickerCountyKey       =   @"county";
NSString * const XPAddressPickerIdKey           =   @"id";
NSString * const XPAddressPickerNameKey         =   @"name";


#pragma mark -
@interface XPAddressPicker ()<UIPickerViewDataSource, UIPickerViewDelegate>

/// 背景关闭按钮
@property (nonatomic, strong) UIButton *backgroundCloseButton;
/// 内容容器视图
@property (nonatomic, strong) UIView *containerView;
/// Picker视图
@property (nonatomic, strong) UIPickerView *pickerView;
/// 取消按钮
@property (nonatomic, strong) UIButton *cancelButton;
/// 完成按钮
@property (nonatomic, strong) UIButton *doneButton;
/// 容器视图底部布局
@property (nonatomic, strong) NSLayoutConstraint *containerBottomLayout;

/// 地址数据
@property (nonatomic, strong) NSArray<NSDictionary *> *addressMaps;
/// 当前选中的省份索引
@property (nonatomic, assign) NSUInteger provinceIndex;
/// 当前选中的城市索引
@property (nonatomic, assign) NSUInteger cityIndex;
/// 当前选中的市区索引
@property (nonatomic, assign) NSUInteger countyIndex;

@end

#pragma mark -
@implementation XPAddressPicker

/// 动画时间
static NSTimeInterval const kAnimationDuration  =   0.25;


#pragma mark Lifeycycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIUserInterfaceIdiom idiom = UI_USER_INTERFACE_IDIOM();
        if (idiom != UIUserInterfaceIdiomPad && idiom != UIUserInterfaceIdiomPhone) {
            NSAssert(NO, @"Only supports iPhone and iPad");
        }
        [self standardInitialization];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSAssert(NO, @"Does not support storyboard and xib.");
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark <UIPickerViewDataSource>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) { // 省份
        return self.addressMaps.count;
    } else if (component == 1) { // 城市
        NSDictionary *province = [self.addressMaps objectAtIndex:_provinceIndex];
        NSArray *cities = (NSArray *)[province objectForKey:XPAddressPickerCityKey];
        return cities.count;
    } else if (component == 2) { // 市区
        NSDictionary *province = [self.addressMaps objectAtIndex:_provinceIndex];
        NSArray *cities = (NSArray *)[province objectForKey:XPAddressPickerCityKey];
        if (cities.count) {
            NSDictionary *city = [cities objectAtIndex:_cityIndex];
            NSArray *counties = [city objectForKey:XPAddressPickerCountyKey];
            return counties.count;
        }
    }
    return 0;
}

#pragma mark <UIPickerViewDelegate>

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) { // 省份
        NSDictionary *province = [self.addressMaps objectAtIndex:row];
        return [province objectForKey:XPAddressPickerNameKey];
    } else if (component == 1) { // 城市
        NSDictionary *province = [self.addressMaps objectAtIndex:_provinceIndex];
        NSArray *cities = (NSArray *)[province objectForKey:XPAddressPickerCityKey];
        NSDictionary *city = [cities objectAtIndex:row];
        return [city objectForKey:XPAddressPickerNameKey];
    } else if (component == 2) { // 市区
        NSDictionary *province = [self.addressMaps objectAtIndex:_provinceIndex];
        NSArray *cities = (NSArray *)[province objectForKey:XPAddressPickerCityKey];
        if (cities.count) {
            NSDictionary *city = [cities objectAtIndex:_cityIndex];
            NSArray *counties = [city objectForKey:XPAddressPickerCountyKey];
            NSDictionary *county = [counties objectAtIndex:row];
            return [county objectForKey:XPAddressPickerNameKey];
        }
    }
    return @"";
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (nil == label) {
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor colorWithRed:117/255.0 green:119/255.0 blue:121/255.0 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.numberOfLines = 2;
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        _provinceIndex = row;
        _cityIndex = 0;
        _countyIndex = 0;
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [pickerView selectRow:0 inComponent:2 animated:NO];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
    } else if (component == 1) {
        _cityIndex = row;
        _countyIndex = 0;
        [pickerView selectRow:0 inComponent:2 animated:NO];
        [pickerView reloadComponent:2];
    } else if (component == 2) {
        _countyIndex = row;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35.0;
}

#pragma mark Actions

- (void)cancelButtonAction:(UIButton *)sender {
    [self hide];
    if ([self.delegate respondsToSelector:@selector(addressPickerDidCancel:)]) {
        [self.delegate addressPickerDidCancel:self];
    }
}

- (void)doneButtonAction:(UIButton *)sender {
    [self hide];
    if ([self.delegate respondsToSelector:@selector(addressPicker:didFinishPickingAddress:)]) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSDictionary *province = [self.addressMaps objectAtIndex:_provinceIndex];
        NSDictionary *city = [(NSArray *)province[XPAddressPickerCityKey] objectAtIndex:_cityIndex];
        NSArray *counties = (NSArray *)city[XPAddressPickerCountyKey];
        
        [result setObject:@{
                            XPAddressPickerIdKey: province[XPAddressPickerIdKey],
                            XPAddressPickerNameKey: province[XPAddressPickerNameKey]
                            }
                   forKey:XPAddressPickerProvinceKey];
        [result setObject:@{
                            XPAddressPickerIdKey: city[XPAddressPickerIdKey],
                            XPAddressPickerNameKey: city[XPAddressPickerNameKey]
                            }
                   forKey:XPAddressPickerCityKey];
        if (counties.count) {
            NSDictionary *county = [counties objectAtIndex:_countyIndex];
            [result setObject:@{
                                XPAddressPickerIdKey: county[XPAddressPickerIdKey],
                                XPAddressPickerNameKey: county[XPAddressPickerNameKey]
                                }
                       forKey:XPAddressPickerCountyKey];
        }
        [self.delegate addressPicker:self didFinishPickingAddress:result];
    }
}

#pragma mark Public

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(self)]];
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(self)]];
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.01 animations:^{
        // do nothing.
    } completion:^(BOOL finished) {
        self.containerBottomLayout.constant = 0.0;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self layoutIfNeeded];
        }];
    }];
}

- (void)hide {
    _containerBottomLayout.constant = kPickerHeight;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setSelectionAddressForId:(NSString *)addressId {
    if (nil == addressId || addressId.length == 0) {
        return;
    }
    NSArray<NSNumber *> *rows = nil;
    // 判断省份
    for (NSUInteger provinceIndex = 0; provinceIndex < self.addressMaps.count; provinceIndex++) {
        NSDictionary *province = self.addressMaps[provinceIndex];
        NSString *provinceId = province[XPAddressPickerIdKey];
        if (nil != provinceId && [provinceId isEqualToString:addressId]) {
            rows = @[@(provinceIndex)];
            break;
        }
        // 判断城市
        NSArray *cities = province[XPAddressPickerCityKey];
        for (NSUInteger cityIndex = 0; cityIndex < cities.count; cityIndex++) {
            NSDictionary *city = cities[cityIndex];
            NSString *cityId = city[XPAddressPickerIdKey];
            if (nil != cityId && [cityId isEqualToString:addressId]) {
                rows = @[@(provinceIndex), @(cityIndex)];
                goto finally;
            }
            // 判断市区
            NSArray *counties = city[XPAddressPickerCountyKey];
            for (NSUInteger countyIndex = 0; countyIndex < counties.count; countyIndex++) {
                NSDictionary *county = counties[countyIndex];
                NSString *countyId = county[XPAddressPickerIdKey];
                if (nil != countyId && [countyId isEqualToString:addressId]) {
                    rows = @[@(provinceIndex), @(cityIndex), @(countyIndex)];
                    goto finally;
                }
            }
        }
    }
    
    // UIPickerView跳转到对应的位置
    finally: {
        for (NSUInteger idx = 0; idx < rows.count; idx++) {
            NSInteger row = [rows[idx] integerValue];
            switch (idx) {
                case 0: _provinceIndex = row; break;
                case 1: _cityIndex = row; break;
                case 2: _countyIndex = row; break;
                default: break;
            }
            [_pickerView selectRow:row inComponent:idx animated:NO];
            if (idx+1 < 3) {
                [_pickerView reloadComponent:(idx+1)];
            }
        }
    }
}

#pragma mark Private

- (void)standardInitialization {
    self.backgroundColor = nil;
    [self addSubview:self.backgroundCloseButton];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.cancelButton];
    [self.containerView addSubview:self.doneButton];
    [self.containerView addSubview:self.pickerView];
    
    self.backgroundCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundCloseButton]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_backgroundCloseButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundCloseButton]|" options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(_backgroundCloseButton)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_containerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_containerView)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kPickerHeight]];
    _containerBottomLayout = [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kPickerHeight];
    [self addConstraint:_containerBottomLayout];
    
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cancelButton]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_cancelButton)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cancelButton(==30.0)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_cancelButton)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_doneButton]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_doneButton)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_doneButton(==30.0)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_doneButton)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pickerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_pickerView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cancelButton]-0-[_pickerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_cancelButton, _pickerView)]];
    [self.containerView addConstraints:constraints];
}

#pragma mark setter & getter

- (void)setFrame:(CGRect)frame {
    frame = [UIScreen mainScreen].bounds;
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    bounds = [UIScreen mainScreen].bounds;
    [super setBounds:bounds];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [super setBackgroundColor:backgroundColor];
}

- (UIButton *)backgroundCloseButton {
    if (nil == _backgroundCloseButton) {
        _backgroundCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundCloseButton.backgroundColor = [UIColor clearColor];
        [_backgroundCloseButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundCloseButton;
}

- (UIView *)containerView {
    if (nil == _containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

- (UIButton *)cancelButton {
    if (nil == _cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _cancelButton;
}

- (UIButton *)doneButton {
    if (nil == _doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _doneButton;
}

- (UIPickerView *)pickerView {
    if (nil == _pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1.0];
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        // 显示选中行的分割线(必须在设置dataSource/delegate后调用才有效果)
        [_pickerView selectRow:0 inComponent:0 animated:NO];
    }
    return _pickerView;
}

- (NSArray<NSDictionary *> *)addressMaps {
    if (nil == _addressMaps) {
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"Address.json" ofType:nil];
        NSData *data = [[NSData alloc] initWithContentsOfFile:filepath];
        _addressMaps = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
    return _addressMaps;
}

@end
