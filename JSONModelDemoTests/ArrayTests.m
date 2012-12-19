//
//  ArrayTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "ArrayTests.h"
#import "JSONModelLib.h"
#import "ReposModel.h"

@implementation ArrayTests
{
    ReposModel* repos;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"github-iphone.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    repos = [[ReposModel alloc] initWithString: jsonContents error:&err];
    NSAssert(!err, [err localizedDescription]);
    
    NSAssert(repos, @"Could not load the test data file.");

}

-(void)testLoading
{
    NSLog(@"%@", repos.repositories[0]);
    NSAssert([repos.repositories isMemberOfClass:[JSONModelArray class]], @".properties is not a JSONModelArray");

}

@end