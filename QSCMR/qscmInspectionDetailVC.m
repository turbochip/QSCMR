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

//collection cell fields and their tag
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

#pragma mark Getters
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

#pragma mark Screen Control
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
    //we are the delegate to handle the split view controller.
    self.splitViewController.delegate=self;
}

#define BORDER_WIDTH 1
#define CORNER_RADIUS 6

- (void)viewDidLoad
{
    [super viewDidLoad];
    // All of these are labels to enforce them as readonly
    self.inspectionAreaField.layer.borderWidth=BORDER_WIDTH;
    self.inspectionAreaField.layer.cornerRadius=CORNER_RADIUS;
    self.inspectionDateAndTimeField.layer.borderWidth=BORDER_WIDTH;
    self.inspectionDateAndTimeField.layer.cornerRadius=CORNER_RADIUS;
    self.inspectionTrackingNumber.layer.borderWidth=BORDER_WIDTH;
    self.inspectionTrackingNumber.layer.cornerRadius=CORNER_RADIUS;
    
    self.context=self.document.managedObjectContext;
    
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
}

-(void) viewDidAppear:(BOOL)animated
{
    // Load the categories into an array
    NSMutableArray *fetchedObjects=[[NSMutableArray alloc] init];
    fetchedObjects=[[self loadCategoriesInToArrayFromContext: self.context] mutableCopy];
    if ((fetchedObjects == nil)||(fetchedObjects.count==0)) {
        if(fetchedObjects.count==0){  // No records found in database so initialize the database.
            CCLog(@"zero category records found initialize database");
            fetchedObjects=[[self initializeCategoriesEntityInContext:self.context] mutableCopy];
        } else {
            CCLog(@"Error fetching objects");
        }
    }
    
    for(Categories *cat in fetchedObjects) {
        [self.categoriesArray addObject:cat.categoryName];
    }
    //reload the collection view with the categories filled in.
    [self.collectionView reloadData];
}


#pragma mark Collection Control
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categoriesArray.count;
}

// qscmInspectionDetailCollectionCell  is the class that controls the prototype cells in the collection
-( qscmInspectionDetailCollectionCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *cellDict=[self loadCellDataForInspection:self.inspectionAreaField.text Category:[self.categoriesArray objectAtIndex:indexPath.row] ];
    
    qscmInspectionDetailCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"inspectionCell" forIndexPath:indexPath];
    cell.categoryLabel.text=@"";
    cell.categoryLabel.text=[self.categoriesArray objectAtIndex:indexPath.row];
    cell.previousObservationTextBox.text=@"";
    cell.previousObservationTextBox.text=[cellDict valueForKey:@"previousObservations"];
    cell.currentObservationsTextBox.text=@"";
    cell.currentObservationsTextBox.text=[cellDict valueForKey:@"currentObservations"];
    CCLog(@"highlevelstate=%d",[[cellDict valueForKey:@"complianceHighLevelState"] integerValue]);
    [cell.segmentControlHighLevelState setSelectedSegmentIndex:[[cellDict valueForKey:@"complianceHighLevelState"] integerValue]];
    [cell.segmentControlNonCompliance setSelectedSegmentIndex:[[cellDict valueForKey:@"complianceNonComplianceState"] integerValue]];
    if(cell.segmentControlHighLevelState.selectedSegmentIndex==2) {
        cell.segmentControlNonCompliance.enabled=YES;
        if(cell.segmentControlNonCompliance.selectedSegmentIndex==2) {
            cell.tridNumberTextField.text=@"";
            cell.tridNumberTextField.text=[cellDict valueForKey:@"tridNO"];
        }
    } else {
        [cell.segmentControlNonCompliance setSelectedSegmentIndex:UISegmentedControlNoSegment];
        cell.tridNumberTextField.text=@"";
        cell.segmentControlNonCompliance.enabled=NO;
    }

    cell.layer.borderWidth=1;
    
    return cell;

}

//save the information for the detail cell you are in.
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
    // The compliance information is in two controls on the screen, but we only want to store the
    // resulting state in the database so based on the two controls, set the actual state.
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

#pragma mark Split View Controller methods

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

#pragma mark SQL Calls

- (NSArray *) loadCategoriesInToArrayFromContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] initWithEntityName:@"Categories"];
    NSSortDescriptor *seqSort=[[NSSortDescriptor alloc] initWithKey:@"displaySequence" ascending:YES];
    fetchRequest.sortDescriptors=@[seqSort];
    fetchRequest.predicate=Nil;  //Get them all
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if(fetchedObjects==nil) CCLog(@"Error fetching Categories - %@",error);
    return fetchedObjects;
}

- (NSArray *) initializeCategoriesEntityInContext:(NSManagedObjectContext *)context
{
    // Build an array of dictionaries.  Each dictionary has the category name and the display sequence.
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
    
    // load everything into the entity
    for(NSDictionary *catDict in catArray) {
        // for each dictionary in the array we just built, add an object to the categories entity
        Categories *cat =[NSEntityDescription insertNewObjectForEntityForName:@"Categories" inManagedObjectContext:context];
        cat.categoryName=[catDict objectForKey:@"category"];
        cat.displaySequence=[catDict objectForKey:@"displaySequence"];
    }
    // commit the inserts
    [self.context save:nil];
    
    // now that we have initialized the entity populated, load them into the array using the same code as earlier.
    NSArray *fetchedObjects=[self loadCategoriesInToArrayFromContext:context];
    return fetchedObjects;
}

- (NSArray *)fetchInspection:(NSString *)inspection DataForCategory:(NSString *)category FromContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Categories" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    //    NSString *pred=[NSString stringWithFormat:@"SUBQUERY(hasDetails,$d,SUBQUERY($d.isForCategory,$c,$c.categoryName='%@').@count>0).@count>0 and trackingNumber='%@'",category,self.inspectionTrackingNumber.text];
    NSString *pred=[NSString stringWithFormat:@"SUBQUERY(hasInspections,$d,SUBQUERY($d.forInspection,$i,$i.trackingNumber='%@').@count>0).@count>0 and categoryName='%@'",self.inspectionTrackingNumber.text,category];
    CCLog(@"pred=%@",pred);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pred];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:nil];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if ((fetchedObjects == nil) || (fetchedObjects.count==0)) {
        CCLog(@"Unable to fetch inspection data");
    } else {
        CCLog(@"fetchedObjects complianceState=%@",[fetchedObjects[0] valueForKeyPath:@"hasInspections.complianceState"]);
    }
    return fetchedObjects;
}

// pull up all the data for the inspection we have chosen.
- (NSMutableDictionary *)loadCellDataForInspection:(NSString *)inspection Category:(NSString *)category
{
    NSMutableDictionary *insDict=[[NSMutableDictionary alloc] init];
    
    // don't do this if we haven't selected an inspection yet.
    if(![inspection isEqualToString:@""]) {
        NSArray *fetchedObjects=[self fetchInspection:inspection DataForCategory:category FromContext:self.context];
        if ((fetchedObjects == nil) || (fetchedObjects.count==0)) {
            CCLog(@"Unable to fetch inspection data");
        } else {
            [insDict setObject:[[fetchedObjects[0] valueForKeyPath:@"hasInspections.forInspection.area"] anyObject] forKey:@"area"];
            [insDict setObject:[[fetchedObjects[0] valueForKeyPath:@"hasInspections.forInspection.trackingNumber"] anyObject] forKey:@"trackingNumber"];
            [insDict setObject:[[fetchedObjects[0] valueForKeyPath:@"hasInspections.forInspection.inspectionDate"] anyObject] forKey:@"inspectionDate"];
            [insDict setObject:[[fetchedObjects[0] valueForKeyPath:@"hasInspections.previousObservations"] anyObject  ]forKey:@"previousObservations"];
            [insDict setObject:[[fetchedObjects[0] valueForKeyPath:@"hasInspections.currentObservations"] anyObject  ]forKey:@"currentObservations"];
            [insDict setObject:[[fetchedObjects[0] valueForKeyPath:@"hasInspections.tridNO"] anyObject] forKey:@"tridNO"];
            [insDict setObject:[[fetchedObjects[0] valueForKeyPath:@"hasInspections.forCategory.categoryName"] anyObject] forKey:@"categoryName"];
            //compliance state is the result of looking at the two segment controls.  It represents the combined state
            [insDict setObject:[[fetchedObjects[0] valueForKeyPath:@"hasInspections.complianceState"] anyObject] forKey:@"complianceState"];
            //in here we need to have both states so we can set the segment controls so we need to break them appart.
            CCLog(@"compstate=%@",[insDict valueForKey:@"complianceState"]);
            NSString *compState=[insDict valueForKey:@"complianceState"];
            if([compState isEqualToString:@"N/A"]) {
                CCLog(@"N/A");
                [insDict setObject:@1 forKey:@"complianceHighLevelState"];
            } else {
                if([compState isEqualToString:@"Complies"]) {
                    CCLog(@"complies");
                    [insDict setObject:@0 forKey:@"complianceHighLevelState"];
                } else {
                    //Everything else should be non-compliant at the high level so set hight level and start checking details
                    [insDict setObject:@2 forKey:@"complianceHighLevelState"];
                    if([compState isEqualToString:@"Non-Compliant"]) {
                        CCLog(@"Non-Compliant");
                        // We should never get here because instead of a state of Non-Compliant, we would have
                        // stored the non-compliant state.
                    } else {
                        if([compState isEqualToString:@"Minor"]) {
                            CCLog(@"Minor");
                            [insDict setObject:@0 forKey:@"complianceNonComplianceState"];
                        } else {
                            if([compState isEqualToString:@"Major"]) {
                                CCLog(@"Major");
                                [insDict setObject:@1 forKey:@"complianceNonComplanceState"];
                            } else {
                                if([compState isEqualToString:@"Critical"]) {
                                    CCLog(@"Critical");
                                    [insDict setObject:@2 forKey:@"complianceNonComplianceState"];
                                } else {
                                    CCLog(@"unknown");
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return insDict;
}

- (void)saveInspectionDetail:(NSMutableDictionary*) dict toContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *fr;
    InspectionDetail *inspD;
    CCLog(@"tracking Number=%@",[dict valueForKey:@"TRACKING_NUMBER"]);
    CCLog(@"CATEGORY_FIELD=%@",[dict valueForKey:@"CATEGORY_FIELD"]);
//    fr=[[NSFetchRequest alloc] initWithEntityName:@"InspectionDetail"];
//    fr.predicate=[NSPredicate predicateWithFormat:@"forInspection.trackingNumber=%@ and isForCategory=%@",  [dict valueForKey:@"TRACKING_NUMBER" ], [dict valueForKey:@"CATEGORY_FIELD"]];
    fr=[[NSFetchRequest alloc] initWithEntityName:@"Categories"];
    fr.predicate=[NSPredicate predicateWithFormat:@"SUBQUERY(hasInspections, $i, SUBQUERY($i.forInspection,$d,$d.trackingNumber=%@).@count>0).@count>0 and categoryName=%@",[dict valueForKey:@"TRACKING_NUMBER"],[dict valueForKey:@"CATEGORY_FIELD"]];
    fr.sortDescriptors=nil;
    NSArray *rs=[context executeFetchRequest:fr error:nil];
    if(rs==nil) {
        CCLog(@"Error unable to execute fetch for matching records");
    } else {
        if(rs.count==0) {
            CCLog(@"No Rows Found add new record");
            inspD=[NSEntityDescription insertNewObjectForEntityForName:@"InspectionDetail" inManagedObjectContext:context];
            inspD.previousObservations= [dict valueForKey:@"PREVIOUS_OBSERVATIONS"];
            inspD.currentObservations=[dict valueForKey:@"CURRENT_OBSERVATIONS"];
            inspD.complianceState=[dict valueForKey:@"COMPLIANCE_STATE"];
            inspD.isForCategory=[[self getCategoryRecordForCategory:[dict valueForKey:@"CATEGORY_FIELD"] inContext:context] firstObject];
            inspD.forInspection=[[self getInspectionRecordForTrackingNumber:[dict valueForKey:@"TRACKING_NUMBER"] inContext:context] firstObject];
        } else {  // we already have records so update it
            CCLog(@"Row already exists update it");
            NSFetchRequest *fr1=[[NSFetchRequest alloc] initWithEntityName:@"InspectionDetail"];
            fr1.predicate=[NSPredicate predicateWithFormat:@"forInspection.trackingNumber=%@ and isForCategory.categoryName=%@",[dict valueForKey:@"TRACKING_NUMBER"], [dict valueForKey:@"CATEGORY_FIELD"]];
            fr1.sortDescriptors=nil;
            NSArray *rs1=[context executeFetchRequest:fr1 error:nil];
            if(rs1==nil) {
                CCLog(@"Error opening InspectionDetail for TrackingNo:%@",[dict valueForKey:@"TRACKING_NUMBER"]);
            } else {
                if(rs1.count==1) {
                    inspD=[rs1 firstObject];
                    CCLog(@"inspD=%@",inspD);
                    inspD.previousObservations= [dict valueForKey:@"PREVIOUS_OBSERVATIONS"];
                    inspD.currentObservations=[dict valueForKey:@"CURRENT_OBSERVATIONS"];
                    inspD.complianceState=[dict valueForKey:@"COMPLIANCE_STATE"];
                } else {
                    CCLog(@"Somehow we have more than one record for %@:%@",[dict valueForKey:@"TRACKING_NUMBER"],[dict valueForKey:@"CATEGORY_FIELD"]);
                }
            }
        }
    }
    
    if(![self.context save:nil])
        CCLog(@"Error saving inspection");
    
}

-(InspectionDetail *) getInspectionDetailForInspectionTrackingNumber:(NSString *) trkNum andCategory:(NSString *)category onContext:(NSManagedObjectContext*) context
{
//    fr=[[NSFetchRequest alloc] initWithEntityName:@"InspectionDetail"];
//    fr.predicate=[NSPredicate predicateWithFormat:@"forInspection.trackingNumber=%@ and isForCategory=%@",  [dict valueForKey:@"TRACKING_NUMBER" ], [dict valueForKey:@"CATEGORY_FIELD"]];
    return nil;
}

- (NSArray *)getCategoryRecordForCategory:(NSString *)category inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fr=[[NSFetchRequest alloc] initWithEntityName:@"Categories"];
    fr.predicate=[NSPredicate predicateWithFormat:@"categoryName=%@",category];
    fr.sortDescriptors=nil;
    NSArray *rs=[context executeFetchRequest:fr error:nil];
    
    if((rs==nil) || (rs.count==0)) {
        CCLog(@"Could not find category %@",category);
    }
    return rs;
}

-(NSArray *)getInspectionRecordForTrackingNumber:(NSString *)trackingNumber inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fr=[[NSFetchRequest alloc] initWithEntityName:@"Inspection"];
    fr.predicate=[NSPredicate predicateWithFormat:@"trackingNumber=%@",trackingNumber];
    fr.sortDescriptors=nil;
    NSArray *rs=[context executeFetchRequest:fr error:nil];

    if((rs==nil) || (rs.count==0)) {
        CCLog(@"Could not find inspection %@",trackingNumber);
    }
    return rs;
}

@end
