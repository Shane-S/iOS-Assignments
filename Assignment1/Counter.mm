//
//  Counter.m
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "Counter.h"
#import "CPPCounter.h"

struct CPPCounterImpl {
public:
    CPPCounter *cppCounter;
    CPPCounterImpl(): cppCounter(new CPPCounter(0)){}
    ~CPPCounterImpl() {delete cppCounter; cppCounter = NULL;}
};

@interface Counter()
{
    int objCCount;
}
@end

@implementation Counter

-(instancetype)init {
    self = [super init];

    if(self) {
        cppCounterObj = new CPPCounterImpl;
        objCCount = 0;
        self.usingObjC = TRUE;
    }

    return self;
}

-(void)incrementCounter {
    if(_usingObjC) objCCount++;
    else cppCounterObj->cppCounter->incrementCount();
}

-(void)toggleCounter {
    _usingObjC = !_usingObjC;
}

-(int)getCounterValue {
    return _usingObjC ? objCCount : cppCounterObj->cppCounter->getCount();
}

@end
