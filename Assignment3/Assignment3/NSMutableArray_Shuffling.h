//
//  NSMutableArray_Shuffling.h
//  Assignment3
//
//  Created by Dan Russell on 2015-03-18.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef Assignment3_NSMutableArray_Shuffling_h
#define Assignment3_NSMutableArray_Shuffling_h

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#include <Cocoa/Cocoa.h>
#endif

// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end
#endif
