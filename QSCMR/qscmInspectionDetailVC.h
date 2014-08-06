//
//  qscmInspectionDetailVC.h
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ccUtilities/CCExtras.h"

@interface qscmInspectionDetailVC : UIViewController <UITextViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *inspectionAreaField;
@property (weak, nonatomic) IBOutlet UILabel *inspectionDateAndTimeField;


@end
