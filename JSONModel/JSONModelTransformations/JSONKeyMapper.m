//
//  JSONKeyMapper.m
//
//  @version 0.8.2
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import "JSONKeyMapper.h"

@implementation JSONKeyMapper
{
    NSMutableDictionary* _toModelMap;
    NSMutableDictionary* _toJSONMap;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        //initialization
        _toModelMap = [NSMutableDictionary dictionaryWithCapacity:10];
        _toJSONMap  = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

-(instancetype)initWithJSONToModelBlock:(JSONModelKeyMapBlock)toModel
                       modelToJSONBlock:(JSONModelKeyMapBlock)toJSON
{
    self = [self init];
    
    if (self) {
        //the json to model convertion block
        _JSONToModelKeyBlock = ^NSString*(NSString* keyName) {

            //try to return cached transformed key
            if (_toModelMap[keyName]) return _toModelMap[keyName];
            
            //try to convert the key, and store in the cache
            NSString* result = toModel(keyName);
            _toModelMap[keyName] = result;
            return result;
        };
        
        _modelToJSONKeyBlock = ^NSString*(NSString* keyName) {
            
            //try to return cached transformed key
            if (_toJSONMap[keyName]) return _toJSONMap[keyName];
            
            //try to convert the key, and store in the cache
            NSString* result = toJSON(keyName);
            _toJSONMap[keyName] = result;
            return result;
            
        };
        
    }
    
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary*)map
{
    self = [super init];
    if (self) {
        //initialize

        _toModelMap = [NSMutableDictionary dictionaryWithDictionary:map];
        _toJSONMap  = [NSMutableDictionary dictionaryWithCapacity: map.count];
        
        for (NSString* key in map) {
            _toJSONMap[ map[key] ] = key;
        }
        
        _JSONToModelKeyBlock = ^NSString*(NSString* keyName) {
            NSString* result = _toModelMap[keyName];
            return result?result:keyName;
        };
        
        _modelToJSONKeyBlock = ^NSString*(NSString* keyName) {
            NSString* result = _toJSONMap[keyName];
            return result?result:keyName;
        };
        
    }
    
    return self;
}

+(instancetype)mapperFromUnderscoreCaseToCamelCase
{
    JSONModelKeyMapBlock toModel = ^ NSString* (NSString* keyName) {

        //bail early if no transformation required
        if ([keyName rangeOfString:@"_"].location==NSNotFound) return keyName;

        //derive camel case out of underscore case
        NSString* camelCase = [keyName capitalizedString];
        camelCase = [camelCase stringByReplacingOccurrencesOfString:@"_" withString:@""];
        camelCase = [camelCase stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[camelCase substringToIndex:1] lowercaseString] ];
        
        return camelCase;
    };

    JSONModelKeyMapBlock toJSON = ^ NSString* (NSString* keyName) {
        
        NSMutableString* result = [NSMutableString stringWithString:keyName];
        NSRange upperCharRange = [result rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];

        while ( upperCharRange.location!=NSNotFound) {

            NSString* lowerChar = [[result substringWithRange:upperCharRange] lowercaseString];
            [result replaceCharactersInRange:upperCharRange
                                  withString:[NSString stringWithFormat:@"_%@", lowerChar]];
            upperCharRange = [result rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
        }
        
        return result;
    };

    return [[self alloc] initWithJSONToModelBlock:toModel
                                 modelToJSONBlock:toJSON];
    
}

@end
