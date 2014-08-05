//
//  FRExtras.m
//  FlickrRegions
//
//  Created by Chip Cox on 7/14/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "CCExtras.h"
@interface CCExtras()
@end

@implementation CCExtras


+(UIActivityIndicatorView *) startSpinner:(UIActivityIndicatorView *)spinner
{
    if(!spinner) spinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.hidesWhenStopped=YES;
    spinner.color=[UIColor redColor];

    if(![spinner isAnimating]){
        if([NSThread isMainThread]) {
            [spinner startAnimating];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner startAnimating];
            });
        }
        CCLog(@"Starting Spinner ");
    }
    return spinner;
}

+(void) stopSpinner:(UIActivityIndicatorView *) spinner
{
    if([spinner isAnimating]){
        if([NSThread isMainThread]) {
            [spinner stopAnimating];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
            });
        }
        CCLog(@"Stopping Spinner");
    }
    spinner=nil;
}


void logIt(NSString *fmt, ...)
{
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    
    NSString *oldDateFormat = [[NSString alloc] init] ;
    oldDateFormat=[df dateFormat];
    [df setDateFormat:@"HH:mm:SS"];
    va_list argList;
    
    va_start(argList,fmt);
    NSLocale* currentLocale = [NSLocale currentLocale];

    [[NSDate date] descriptionWithLocale:currentLocale];
    NSString *dte=[NSString stringWithFormat:@"%@ - ",[df stringFromDate:[NSDate date]]];
    fmt=[dte stringByAppendingString:fmt];
    NSString *outstr=[[NSString alloc] initWithFormat:fmt arguments:argList];
    
    printf("%s\n",[outstr UTF8String]);
    va_end(argList);
    [df setDateFormat:oldDateFormat];
}

UIManagedDocument *openDB(NSString *databaseName)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url;
    NSURL *documentsDirectory =[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = databaseName;
    url = [documentsDirectory URLByAppendingPathComponent:documentName];
    
    // Setup my document here
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    // print out the url path just for fun.
    CCLog(@"url=%@ \n filePathURL=%@",[url path], [url pathComponents]);
    
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
    if(fileExists){
        // open file
        [document openWithCompletionHandler:^(BOOL success) {
            if(success) {
                CCLog(@"Database exists and was opened");
            }
        }];
    } else { // create file and open it at the same time.
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success)
                CCLog(@"New Database Opened");
            else
                CCLog(@"Couldn't create document %@",url);
        }];
    }
    return document;
}



@end


