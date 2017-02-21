//
//  DataManager.h
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/21/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "cl_mdc.h"


@interface DataManager : NSObject
{
    sqlite3 *db;
}

- (id)initWithDBPath:(NSString*)dbPath;
- (void)saveParametersToDB:(Plane)p ColorScheme:(ColorScheme)cs iterLimit:(int)iterLimit;
- (NSMutableArray*)fetchAllPoints;

@end
