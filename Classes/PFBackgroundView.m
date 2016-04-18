//
// Created by Anton Zlotnikov on 18.04.16.
// Copyright (c) 2016 Cee. All rights reserved.
//

#import "PFBackgroundView.h"


@implementation PFBackgroundView {

}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView * view in [self subviews]) {
        if (view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

@end