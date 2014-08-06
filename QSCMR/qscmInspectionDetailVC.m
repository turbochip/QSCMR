//
//  qscmInspectionDetailVC.m
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "qscmInspectionDetailVC.h"
#import "qscmInspectionDetailCollectionCell.h"
#import "Categories.h"

@interface qscmInspectionDetailVC ()
@property (weak, nonatomic) IBOutlet UIToolbar *detailToolbar;
@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,strong) NSMutableArray *categoriesArray;
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

- (void) awakeFromNib
{
    self.splitViewController.delegate=self;

}

-(NSManagedObjectContext *) context
{
    if(!_context) _context=self.document.managedObjectContext;
    return _context;
}

-(UIManagedDocument *) document
{
    if(!_document) _document=openDatabase(@"qscmr");
    return _document;
}

-(NSMutableArray *) categoriesArray
{
    if(!_categoriesArray) _categoriesArray=[[NSMutableArray alloc] init];
    return _categoriesArray;
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
    self.context=self.document.managedObjectContext;
}

-(void) viewDidAppear:(BOOL)animated
{
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] initWithEntityName:@"Categories"];
    NSSortDescriptor *seqSort=[[NSSortDescriptor alloc] initWithKey:@"displaySequence" ascending:YES];
    fetchRequest.sortDescriptors=@[seqSort];
    fetchRequest.predicate=Nil;
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if ((fetchedObjects == nil)||(fetchedObjects.count==0)) {
        if(fetchedObjects.count==0){
            CCLog(@"zero category records found");
            NSArray *catArray=@[@{@"category":@"Training",@"displaySequence":@0},
                                @{@"category":@"Process/Procedure/PackagingRecord/Test Standard Detail",@"displaySequence":@1},
                                @{@"category":@"Compliance to Procedure/Standard/Packaging Record",@"displaySequence":@2},
                                @{@"category":@"Good DocumentationPractices",@"displaySequence":@3},
                                @{@"category":@"Gowning/Hygiene",@"displaySequence":@4},
                                @{@"category":@"Facilities/Maintenance",@"displaySequence":@5},
                                @{@"category":@"General Housekeeping",@"displaySequence":@6},
                                @{@"category":@"Validation/Qualification",@"displaySequence":@7},
                                @{@"category":@"Calibration",@"displaySequence":@8},
                                @{@"category":@"Laboratory Controls/Sample Control",@"displaySequence":@9},
                                @{@"category":@"Investigations",@"displaySequence":@10},
                                @{@"category":@"Change Control",@"displaySequence":@11},
                                @{@"category":@"Material Handling",@"displaySequence":@12},
                                @{@"category":@"Safety",@"displaySequence":@13}];
            
            for(NSDictionary *catDict in catArray) {
                Categories *cat =[NSEntityDescription insertNewObjectForEntityForName:@"Categories" inManagedObjectContext:self.context];
                cat.categoryName=[catDict objectForKey:@"category"];
                cat.displaySequence=[catDict objectForKey:@"displaySequence"];
            }
            [self.context save:nil];
           
        } else {
            CCLog(@"Error fetching objects");
        }
    } else {
        for(Categories *cat in fetchedObjects) {
            [self.categoriesArray addObject:cat.categoryName];
        }
    }
    
    [self.collectionView reloadData];
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
    return self.categoriesArray.count;
}

-( qscmInspectionDetailCollectionCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellData = [self.data objectAtIndex:indexPath.row];
    
    qscmInspectionDetailCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"inspectionCell" forIndexPath:indexPath];
    cell.categoryLabel.text=[self.categoriesArray objectAtIndex:indexPath.row];
    cell.previousObservationTextBox.text=cellData;
    cell.currentObservationsTextBox.text=[NSString stringWithFormat:@"currnet observations %@",cellData ];
    if(cell.segmentControlHighLevelState.selectedSegmentIndex==3) {
        cell.segmentControlNonCompliance.enabled=YES;
    } else {
        cell.segmentControlNonCompliance.enabled=NO;
    }

    cell.layer.borderWidth=1;
    
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

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

-(void) splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    if(aViewController.title)
        barButtonItem.title=aViewController.title;
    else
        barButtonItem.title=@"Show Menu";
    
    [barButtonItem setWidth:40.0];
    CCLog(@"barbuttonItem=%f",barButtonItem.width);
    
    CCLog(@"toolbarItems=%@",self.navigationItem.leftBarButtonItem);
//    [self.toolbarItems.firstObject addObject: barButtonItem];
    
    self.navigationItem.leftBarButtonItem=barButtonItem;
}

-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem=nil;
}
- (IBAction)segmentIsSelected:(UISegmentedControl *)sender {
}


@end
