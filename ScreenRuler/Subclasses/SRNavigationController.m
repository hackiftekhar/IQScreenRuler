//
//  SRNavigationController.m
//  ScreenRuler
//
//  Created by Iftekhar on 02/11/17.
//  Copyright © 2017 InfoEnum Software Systems. All rights reserved.
//

#import "SRNavigationController.h"

@interface SRNavigationController ()

@end

@implementation SRNavigationController

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak typeof(self) weakSelf = self;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            BOOL hidden = (size.width > size.height);
            [weakSelf setNavigationBarHidden:hidden animated:YES];
            [weakSelf setToolbarHidden:hidden animated:YES];
        }

    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

@end
