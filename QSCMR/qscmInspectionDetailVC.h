//
//  qscmInspectionDetailVC.h
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ccUtilities/CCExtras.h"
#import <CoreData/CoreData.h>

@interface qscmInspectionDetailVC : UIViewController <UITextViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate , UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *inspectionAreaField;
@property (weak, nonatomic) IBOutlet UILabel *inspectionDateAndTimeField;
@property (strong,nonatomic) UIManagedDocument *document;
@property (strong,nonatomic) NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *inspectionTrackingNumber;
@end
