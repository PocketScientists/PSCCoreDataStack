//
//  PSCLogging.h
//  PSCCoreDataStack
//
//  Created by Matthias Tretter on 05.04.13.
//  Copyright (c) 2013 PocketScience. All rights reserved.
//


#ifdef PSC_COREDATA_LOGGING
    #define PSCCDLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
    #define PSCCDLog(...) ((void)0)
#endif
