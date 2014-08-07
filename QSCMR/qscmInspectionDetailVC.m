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
#import "Inspection.h"
#import "InspectionDetail.h"

#define CATEGORY_FIELD 0
#define COMPLIANCE_HIGH_LEVEL_STATE 1
#define COMPLIANCE_NONCOMPLIANCE_STATE 2
#define TRID_NUMBER 3
#define PREVIOUS_OBSERVATIONS 4
#define CURRENT_OBSERVATIONS 5
#define NOTAPPLICABLE 99

@interface qscmInspectionDetailVC ()
@property (weak, nonatomic) IBOutlet UIToolbar *detailToolbar;
@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,strong) NSMutableArray *categoriesArray;
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

- (NSMutableDictionary *)loadCellDataForInspection:(NSString *)inspection Category:(NSString *)category
{
    NSMutableDictionary *insDict=[[NSMutableDictionary alloc] init];

    if(![inspection isEqualToString:@""]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspection" inManagedObjectContext:self.context];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"ddMMMyyyy HH:mm:ss z Z"];
        NSDate *date = [dateFormat dateFromString:self.inspectionDateAndTimeField.text];

    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area=%@ and hasDetails.forCategories.categoryName=%@ inspectionDate=%@", inspection, category,date];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(hasDetails,$d,SUBQUERY($d.isForCategory,$c,$c.categoryName=%@).@count>0).@count>0 and area=%@ and inspectionDate=%@",category,inspection,date];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        //NSSortDescriptor *sortDescriptor = nil;
        [fetchRequest setSortDescriptors:nil];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
        if ((fetchedObjects == nil) || (fetchedObjects.count==0)) {
            CCLog(@"Unable to fetch inspection data");
        } else {
            [insDict setObject:[fetchedObjects[0] valueForKey:@"area"] forKey:@"area"];
            [insDict setObject:[fetchedObjects[0] valueForKeyPath:@"hasDetails.previousObservations"] forKey:@"previousObservations"];
            [insDict setObject:[fetchedObjects[0] valueForKeyPath:@"hasDetails.currentObservations"] forKey:@"currentObservations"];
        }
    }
    return insDict;
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
    NSMutableDictionary *cellDict=[self loadCellDataForInspection:self.inspectionAreaField.text Category:[self.categoriesArray objectAtIndex:indexPath.row] ];
    
    qscmInspectionDetailCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"inspectionCell" forIndexPath:indexPath];
    cell.categoryLabel.text=[self.categoriesArray objectAtIndex:indexPath.row];
    cell.previousObservationTextBox.text=[cellDict valueForKey:@"previousObservations"];
    cell.currentObservationsTextBox.text=[cellDict valueForKey:@"currentObservations"];
    if(cell.segmentControlHighLevelState.selectedSegmentIndex==3) {
        cell.segmentControlNonCompliance.enabled=YES;
    } else {
        cell.segmentControlNonCompliance.enabled=NO;
    }

    cell.layer.borderWidth=1;
    
    return cell;

}

//#define CATEGORY_FIELD 0
//#define COMPLIANCEHIGHLEVELSTATE 1
//#define COMPLIANCENONCOMPLIANCESTATE 2
//#define TRIDNUMBER 3
//#define PREVIOUSOBSERVATIONS 4
//#define CURRENTOBSERVATIONS 5
//#define NOTAPPLICABLE 99


- (IBAction)saveDetailCell:(UIButton *)sender {
    //Save detail collection cell to database
    NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] init];
    for(UIView *sv in sender.superview.subviews) {
        CCLog(@"sv.tag=%d",sv.tag);
        switch(sv.tag) {
            case CATEGORY_FIELD: {
                [saveDict setValue:((UILabel *)sv).text forKey:@"CATEGORY_FIELD"];
                break;
            }
            case COMPLIANCE_HIGH_LEVEL_STATE :{
                [saveDict setValue:[((UISegmentedControl *)sv) titleForSegmentAtIndex:((UISegmentedControl *) sv).selectedSegmentIndex] forKey:@"COMPLIANCE_HIGH_LEVEL_STATE"];
                break;
            }
            case COMPLIANCE_NONCOMPLIANCE_STATE: {
                [saveDict setValue:[((UISegmentedControl *)sv) titleForSegmentAtIndex:((UISegmentedControl *) sv).selectedSegmentIndex] forKey:@"COMPLIANCE_NONCOMPLIANCE_STATE"];
                break;
            }
            case TRID_NUMBER :{
                [saveDict setValue:((UITextField *)sv).text forKey:@"TRID_NUMBER"];
                break;
            }
            case PREVIOUS_OBSERVATIONS :{
                [saveDict setValue:((UITextView *)sv).text forKey:@"PREVIOUS_OBSERVATIONS"];
                break;
            }
            case CURRENT_OBSERVATIONS :{
                [saveDict setValue:((UITextView *)sv).text forKey:@"CURRENT_OBSERVATIONS"];
                break;
            }
            case NOTAPPLICABLE : {
                CCLog(@"Skip subview");
                break;
            }
            default: {
                CCLog(@"unknown tag type %@",sv);
            }
        }
    }
    if([[saveDict valueForKey:@"COMPLIANCE_HIGH_LEVEL_STATE"] isEqualToString:@"Non-Compliant"]) {
        [saveDict setValue:[saveDict valueForKey:@"COMPLIANCE_NONCOMPLIANCE_STATE"] forKey:@"COMPLIANCE_STATE"];
    } else {
        [saveDict setValue:[saveDict valueForKey:@"COMPLIANCE_HIGH_LEVEL_STATE"] forKey:@"COMPLIANCE_STATE"];
    }
    
    [saveDict setValue:self.inspectionTrackingNumber.text forKey:@"TRACKING_NUMBER"];
    [saveDict setValue:self.inspectionAreaField.text forKey:@"INSPECTION_AREA"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"ddMMMyyyy HH:mm:ss z Z"];
    NSDate *date = [dateFormat dateFromString:self.inspectionDateAndTimeField.text];
    [saveDict setValue:date forKey:@"INSPECTION_DATE"];
    
    CCLog(@"saveDict=%@",saveDict);
    [self saveInspectionDetail:saveDict toContext:self.context];
}

- (void)saveInspectionDetail:(NSMutableDictionary*) dict toContext:(NSManagedObjectContext *) context
{
    InspectionDetail *inspD;
    inspD=[NSEntityDescription insertNewObjectForEntityForName:@"InspectionDetail" inManagedObjectContext:context];
    inspD.previousObservations= [dict valueForKey:@"PREVIOUS_OBSERVATIONS"];
    inspD.currentObservations=[dict valueForKey:@"CURRENT_OBSERVATIONS"];
    inspD.complianceState=[dict valueForKey:@"COMPLIANCE_STATE"];

    NSFetchRequest *fr=[[NSFetchRequest alloc] initWithEntityName:@"Categories"];
    fr.predicate=[NSPredicate predicateWithFormat:@"categoryName=%@",[dict valueForKey:@"CATEGORY_FIELD"]];
    fr.sortDescriptors=nil;
    NSArray *rs=[context executeFetchRequest:fr error:nil];
    
    if((rs==nil) || (rs.count==0)) {
        CCLog(@"Could not find category %@",[dict valueForKey:@"CATEGORY_FIELD"]);
    } else {
        inspD.isForCategory=[rs firstObject];
    }
    fr=nil;
    rs=nil;
    
    fr=[[NSFetchRequest alloc] initWithEntityName:@"Inspection"];
    fr.predicate=[NSPredicate predicateWithFormat:@"trackingNumber=%@",[dict valueForKey:@"TRACKING_NUMBER" ]];
    fr.sortDescriptors=nil;
    rs=[context executeFetchRequest:fr error:nil];
    
    if((rs==nil) || (rs.count==0)) {
        CCLog(@"Could not find inspection %@",[dict valueForKey:@"TRACKING_NUMBER"]);
    } else {
        CCLog(@"Found rs.firstObject=%@",rs.firstObject);
        inspD.forInspection=[rs firstObject];
    }
   
    
    
    if(![self.context save:nil])
        CCLog(@"Error saving inspection");

}

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
    [self.collectionView reloadData];
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
    [self.collectionView reloadData];
}

-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem=nil;
    [self.collectionView reloadData];
}
- (IBAction)segmentIsSelected:(UISegmentedControl *)sender {
}


@end
