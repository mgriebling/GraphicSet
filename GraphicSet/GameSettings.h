//
//  GameSettings.h
//  Matchismo
//
//  Created by Mike Griebling on 11.2.2013.
//  Copyright (c) 2013 Michael Griebling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSettings : NSObject

typedef enum {BACKDROP_GRAY, BACKDROP_LAVENDER, BACKDROP_AQUAMARINE} BackDrops;

@property (nonatomic) BackDrops backDrop;

//+ (NSArray *)getSettings;

@end
