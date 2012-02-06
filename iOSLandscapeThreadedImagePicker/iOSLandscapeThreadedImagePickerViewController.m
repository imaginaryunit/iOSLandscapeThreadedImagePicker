//
//  iOSLandscapeImagePickerViewController.m
//  iOSLandscapeImagePicker
//
//  Created by Jim Huang on 2/5/12.
//  Copyright (c) 2012 Napkkin Inc. All rights reserved.
//

#import "iOSLandscapeThreadedImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation iOSLandscapeThreadedImagePickerViewController

@synthesize scrollview;
@synthesize clickedasset;
@synthesize buttons;
@synthesize assets;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [self setScrollview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidAppear:(BOOL)animated
{
    
    NSLog(@"View did appear");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIAlertView *mAlert = [[UIAlertView alloc] initWithTitle:@"Loaded" message:@"Loaded" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [mAlert show];
    
    
    self.navigationItem.prompt = @"Choose a picture";    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    
    scrollview.delegate = self;
    oldblock = 0;
    [self.navigationController setNavigationBarHidden:NO];
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) 
    { 
        if(result != NULL) 
        { 
            [assets addObject:result]; 
        } 
    };
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) 
    {
        if(group != nil)
        {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            
        }
        [self showAssets:0];
    };
    
    //Fetch photo assets from group album
    assets = [[NSMutableArray alloc] init];
    ALAssetsLibrary *library = [self defaultAssetsLibrary];
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:assetGroupEnumerator 
                         failureBlock: ^(NSError *error) { NSLog(@"Failure");}];
}

- (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library; 
}

//Show images in blocks of 24
-(void)showAssets:(int)start{
    
    if([assets count]>start+24){        
        for(int i=start;i<=start+24;i=i+6){        
            [self performSelectorOnMainThread:@selector(showAssetsBlock:)  withObject:[NSNumber numberWithInt:i]   waitUntilDone:NO];        
        }    
    }else{
        for(int i=start;i<start+[assets count];i=i+6){        
            [self performSelectorOnMainThread:@selector(showAssetsBlock:)  withObject:[NSNumber numberWithInt:i]   waitUntilDone:NO];        
        }                    
    }
    scrollview.contentSize = CGSizeMake(480,(([assets count]/4)+1)*300);    
}


-(void)showAssetsBlock:(NSNumber *)ix{
    
    NSRange range = NSMakeRange([ix intValue],6);
    for (int i = range.location; i<MIN(range.location + range.length, [assets count]); i++) 
    {
        UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [imgBtn setFrame:CGRectMake((i%6*80)+2,(i/6*80)+2,75,75)];
        imgBtn.tag=i;
        ALAsset *asset=[assets objectAtIndex:i];
        [imgBtn addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
        [imgBtn setImage:[UIImage imageWithCGImage:[asset thumbnail]] forState:UIControlStateNormal];
        [scrollview addSubview:imgBtn];
        
    }
    
}

//Clear blocks of images outside of current view
-(void)removeAssetsBlockBefore:(int) i{
    for (UIButton *btn in [scrollview subviews]) 
    {
        if(btn.tag<i)
            [btn removeFromSuperview];
    }    
}
-(void)removeAssetsBlockAfter:(int) i{
    for (UIButton *btn in [scrollview subviews]) 
    {
        if(btn.tag>i)
            [btn removeFromSuperview];
    }    
}


-(IBAction)imageClicked:(id)sender{
    
    UIButton *clickedbutton = (UIButton*)sender;        
    int i = clickedbutton.tag;
    
    NSString *msg = [NSString stringWithFormat:@"Clicked on image: %d",i];
    UIAlertView *mAlert = [[UIAlertView alloc] initWithTitle:@"Image selected!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [mAlert show];
    
    
}

//Handle scrolling of view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    block = ((int) scrollView.contentOffset.y)/300;    
    if(block!=oldblock)
    {
        if([[scrollview subviews] count]>2048)
        {
            [self removeAssetsBlockBefore:MAX(0,block*24-1024)];
            [self removeAssetsBlockAfter:MIN([assets count]-7,block*24+1024)];        
        }        
        
        [self showAssets:block*24];
        
        oldblock = block;
    }    
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    //Each block of images contains 24 images and has height 300    
    block = ((int) targetContentOffset->y)/300;    
    if(block!=oldblock)
    {        
        [self showAssets:block*24];
        oldblock = block;
    }    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    //Each block of images contains 24 images and has height 300
    block = ((int) scrollView.contentOffset.y)/300;    
    if(block!=oldblock)
    {
        [self showAssets:block*24];
        oldblock = block;
    }        
}

@end
