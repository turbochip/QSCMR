//
//  qscmInspectionDetailCollectionCell.h
//  QSCMR
//
//  Created by Chip Cox on 8/6/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface qscmInspectionDetailCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UITextView *previousObservationTextBox;
@property (weak, nonatomic) IBOutlet UITextView *currentObservationsTextBox;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControlHighLevelState;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControlNonCompliance;
@property (weak, nonatomic) IBOutlet UILabel *tridLabel;
@property (weak, nonatomic) IBOutlet UITextField *tridNumberTextField;


@end
