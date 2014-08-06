//
//  qscmAreaPVC.h
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ccUtilities/CCExtras.h"

@protocol areaPopupDelegate
-(void) popupViewControllerDismissed:(NSMutableDictionary *)dict sender:(id) sender;
@end

@interface qscmAreaPVC : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    id<areaPopupDelegate> delegate;
}
//@property (nonatomic,strong) id myDelegate;
@property (nonatomic, assign) id<areaPopupDelegate> areaPopupDelegate;
@property (nonatomic,strong) NSMutableDictionary *transferDictionary;

@end
