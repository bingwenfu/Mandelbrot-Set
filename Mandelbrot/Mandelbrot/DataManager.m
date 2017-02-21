//
//  DataManager.m
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/21/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#import "DataManager.h"
#import "MandelbrotParameters.h"

@implementation DataManager

- (id)initWithDBPath:(NSString*)dbPath
{
    self = [super init];
    if (self) {
        if (sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK) {
            NSLog(@"DataManager can't open database at path: %@", dbPath);
        }
    }
    [self createTable];
    return self;
}

- (void)createTable
{
    char *cmd =
    "CREATE TABLE Parameters (              "
    "   x1 real, y1 real, x2 real, y2 real, " // Plane
    "   c1r real, c1g real, c1b real,       " // Color1
    "   c2r real, c2g real, c2b real,       " // Color2
    "   c3r real, c3g real, c3b real,       " // Color3
    "   c4r real, c4g real, c4b real,       " // Color4
    "   cl1 real, cl2 real, a real,         " // ColorLines
    "   iterLimit integer,                  " // iterLimit
    "   ID integer, PRIMARY KEY(ID)         "
    ")                                      ";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, cmd, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    } else {
        NSLog(@"DataManager failed to create table for database: %s", sqlite3_errmsg(db));
    }
}

- (void)saveParametersToDB:(Plane)p ColorScheme:(ColorScheme)cs iterLimit:(int)iterLimit
{
    NSString *cmd = [[NSString alloc] initWithFormat:@"INSERT INTO Parameters (x1, y1, x2, y2, c1r, c1g, c1b, c2r, c2g, c2b, c3r, c3g, c3b, c4r, c4g, c4b, cl1, cl2, a, iterLimit) VALUES(\"%.20f\",\"%.20f\",\"%.20f\",\"%.20f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\",\"%f\", \"%d\")", p.x1, p.y1, p.x2, p.y2, cs.color1.r, cs.color1.g, cs.color1.b, cs.color2.r, cs.color2.g, cs.color2.b, cs.color3.r, cs.color3.g, cs.color3.b, cs.color4.r, cs.color4.g, cs.color4.b, cs.colorLine1, cs.colorLine2, cs.a, iterLimit];
    
    NSLog(@"%@", cmd);
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [cmd UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    } else {
        NSLog(@"%s", __FUNCTION__);
        NSLog(@"DataManager failed to insert parameters: %s", sqlite3_errmsg(db));
    }
}

- (NSMutableArray*)fetchAllPoints
{
    char *cmd = "SELECT * FROM Parameters";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, cmd, -1, &statement, NULL) == SQLITE_OK) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [result addObject:[self mandelbrotParametersFromStatement:statement]];
        }
        sqlite3_finalize(statement);
        return result;
    } else {
        NSLog(@"%s", __FUNCTION__);
        NSLog(@"DataManager failed to Fetch parameters: %s", sqlite3_errmsg(db));
        return nil;
    }
}

- (MandelbrotParameters*)mandelbrotParametersFromStatement:(sqlite3_stmt*)statement
{
    MandelbrotParameters *pa = [[MandelbrotParameters alloc] init];
    Plane p = pa.plane;
    ColorScheme cs = pa.colorScheme;
    p.x1 = sqlite3_column_double(statement, 0);
    p.y1 = sqlite3_column_double(statement, 1);
    p.x2 = sqlite3_column_double(statement, 2);
    p.y2 = sqlite3_column_double(statement, 3);
    cs.color1.r = sqlite3_column_double(statement, 4);
    cs.color1.g = sqlite3_column_double(statement, 5);
    cs.color1.b = sqlite3_column_double(statement, 6);
    cs.color2.r = sqlite3_column_double(statement, 7);
    cs.color2.g = sqlite3_column_double(statement, 8);
    cs.color2.b = sqlite3_column_double(statement, 9);
    cs.color3.r = sqlite3_column_double(statement, 10);
    cs.color3.g = sqlite3_column_double(statement, 11);
    cs.color3.b = sqlite3_column_double(statement, 12);
    cs.color4.r = sqlite3_column_double(statement, 13);
    cs.color4.g = sqlite3_column_double(statement, 14);
    cs.color4.b = sqlite3_column_double(statement, 15);
    cs.colorLine1 = sqlite3_column_double(statement, 16);
    cs.colorLine2 = sqlite3_column_double(statement, 17);
    cs.a = sqlite3_column_double(statement, 18);
    pa.iterLimit = sqlite3_column_int(statement, 19);
    pa.ID = sqlite3_column_int(statement, 20);
    pa.plane = p;
    pa.colorScheme = cs;
    return pa;
}

@end
