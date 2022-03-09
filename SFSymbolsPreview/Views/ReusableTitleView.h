//
//  ReusableTitleView.h
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReusableTitleView : UICollectionReusableView

@property (nonatomic, strong) NSString *title;

@end

@interface ReusableSegmentedControlView : UICollectionReusableView

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

NS_ASSUME_NONNULL_END
