//
//  CPPCounter.cpp
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#include "CPPCounter.h"

CPPCounter::CPPCounter(int startCount): _count(startCount) {}

int CPPCounter::incrementCount() {
    _count++;
    return _count;
}

int CPPCounter::decrementCount() {
    _count--;
    return _count;
}

void CPPCounter::setCount(int count) {
    _count = count;
}

int CPPCounter::getCount() {
    return _count;
}