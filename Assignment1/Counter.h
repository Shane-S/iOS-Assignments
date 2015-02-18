//
//  Counter.h
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct CPPCounterImpl CPPCounterImpl;

@interface Counter : NSObject
{
    CPPCounterImpl *cppCounterObj;
}

@property (nonatomic) BOOL usingObjC;

/*!
 * @brief Increments the count of the currently active object.
 */
-(void)incrementCounter;

/*!
 * @brief Toggles the active object between the Objective C counter and the C++ counter.
 */
-(void)toggleCounter;

/*!
 * @brief Retrieves the counter value for the currently active object.
 * @return The counter value for the currently active object.
 */
-(int)getCounterValue;

@end
