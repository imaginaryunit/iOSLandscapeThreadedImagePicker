//
//  iOSLandscapeImagePickerViewController.h
//  iOSLandscapeImagePicker
//
//  Created by Jim Huang on 2/5/12.
//  Copyright (c) 2012 Napkkin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface iOSLandscapeThreadedImagePickerViewController : UIViewController<UIScrollViewDelegate>
{
    
    NSMutableArray *assets;
    NSMutableArray *buttons;
    ALAsset *clickedasset;
    int block, oldblock, bigblock, oldbigblock;
    float y;
}
@property (weak, atomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) ALAsset *clickedasset;
@property (strong, atomic) NSMutableArray *assets;
@property (strong, atomic) NSMutableArray *buttons;

-(void)showAssets:(int)start;
-(IBAction)imageClicked:(id)sender;
-(void)showAssetsBlock:(NSNumber *)ix;
-(void)removeAssetsBlockBefore:(int)i;
-(void)removeAssetsBlockAfter:(int)i;
-(ALAssetsLibrary *)defaultAssetsLibrary;

@end
