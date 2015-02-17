//
//  CPPCounter.h
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-17.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#ifndef __Assignment1__CPPCounter__
#define __Assignment1__CPPCounter__

#include <stdio.h>

class CPPCounter {
public:
    /**
     * @brief Initiliases the counter object with the specified count to start.
     */
    CPPCounter(int startCount);
    
    /**
     * @brief Increments the counter by one.
     * @return The current count.
     */
    int incrementCount();
    
    /**
     * @brief Decrements the counter by one.
     * @return The current count.
     */
    int decrementCount();
    
    /**
     * @brief Sets the count to the specified value.
     * @param count The new value to which to set the count.
     */
    void setCount(int count);
    
    /**
     * @brief Gets the current count.
     * @return The current count.
     */
    int getCount();
    
private:
    int _count;
};


#endif /* defined(__Assignment1__CPPCounter__) */
