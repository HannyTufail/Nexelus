//
//  TLDatabaseHandler.h
//  TimeLineApp
//
//  Created by Mac on 12/26/14.
//  Copyright (c) 2014 Hanny Tufail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface TLDatabaseHandler : NSObject
{
    sqlite3 * _database;
}

+(TLDatabaseHandler *) database;

-(NSArray *) pldTransactionInfos;
@end
