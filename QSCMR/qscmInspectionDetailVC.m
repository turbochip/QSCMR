//
//  qscmInspectionDetailVC.m
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "qscmInspectionDetailVC.h"

@interface qscmInspectionDetailVC ()
@property (nonatomic,strong) NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation qscmInspectionDetailVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *) data
{
    if(!_data) _data=[[NSMutableArray alloc] init];
    return _data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CCLog(@"in view did load");
    self.inspectionAreaField.layer.borderWidth=1;
    self.inspectionAreaField.layer.cornerRadius=12;
    self.inspectionDateAndTimeField.layer.borderWidth=1;
    self.inspectionDateAndTimeField.layer.cornerRadius=12;
    for(int i=0;i<21;i++)
        self.data[i]=[@"abcdefghijklmnopqrstuvwxyz" substringFromIndex:i];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

-( UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier=@"";
    NSString *cellData = [self.data objectAtIndex:indexPath.row];
    
    switch (indexPath.row % 3) {
        case 0: {
            cellIdentifier=@"currentObservations";
            break;
        }
        case 1: {
            cellIdentifier=@"previousObservations";
        }
            
        default:
            break;
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UITextField *titleLabel = (UITextField *)[cell viewWithTag:0];
    
    [titleLabel.text stringByAppendingFormat:@"%@",cellData ];
    
    return cell;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"placeholder text here..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"placeholder text here...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
