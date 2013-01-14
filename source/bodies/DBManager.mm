//
//  DBManager.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-09-10.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

+ (UIManagedDocument* ) database {
    static UIManagedDocument* db = nil;
    
    if (!db) {
        NSURL *url = [[[[NSFileManager defaultManager]
                        URLsForDirectory:NSDocumentDirectory
                        inDomains:NSUserDomainMask]
                       lastObject]
                      URLByAppendingPathComponent:@"Frames"];
        
        db = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    return db;
}

@end
