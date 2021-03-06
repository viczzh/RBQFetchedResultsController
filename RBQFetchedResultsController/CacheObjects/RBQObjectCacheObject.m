//
//  RBQObjectCacheObject.m
//  RBQFetchedResultsControllerExample
//
//  Created by Adam Fish on 1/6/15.
//  Copyright (c) 2015 Roobiq. All rights reserved.
//

#import "RBQObjectCacheObject.h"
#import "RLMObject+Utilities.h"

@implementation RBQObjectCacheObject

#pragma mark - Public Class

+ (instancetype)createCacheObjectWithObject:(RLMObject *)object
                        sectionKeyPathValue:(NSString *)sectionValue
{
    RBQObjectCacheObject *cacheObject = [[RBQObjectCacheObject alloc] init];
    cacheObject.primaryKeyType = object.objectSchema.primaryKeyProperty.type;
    cacheObject.sectionKeyPathValue = sectionValue;
    cacheObject.className = [RLMObject classNameForObject:object];
    
    id primaryKeyValue = [RLMObject primaryKeyValueForObject:object];
    
    if (cacheObject.primaryKeyType == RLMPropertyTypeString) {
        cacheObject.primaryKeyStringValue = (NSString *)primaryKeyValue;
    }
    else if (cacheObject.primaryKeyType == RLMPropertyTypeInt) {
        cacheObject.primaryKeyStringValue = ((NSNumber *)primaryKeyValue).stringValue;
    }
    else {
        @throw([self unsupportedPrimaryKeyTypeException]);
    }
    
    return cacheObject;
}

+ (instancetype)createCacheObjectWithSafeObject:(RBQSafeRealmObject *)safeObject
                            sectionKeyPathValue:(NSString *)sectionValue
{
    RBQObjectCacheObject *cacheObject = [[RBQObjectCacheObject alloc] init];
    cacheObject.primaryKeyType = safeObject.primaryKeyType;
    cacheObject.sectionKeyPathValue = sectionValue;
    cacheObject.className = safeObject.className;
    
    if (cacheObject.primaryKeyType == RLMPropertyTypeString) {
        cacheObject.primaryKeyStringValue = (NSString *)safeObject.primaryKeyValue;
    }
    else if (cacheObject.primaryKeyType == RLMPropertyTypeInt) {
        cacheObject.primaryKeyStringValue = ((NSNumber *)safeObject.primaryKeyValue).stringValue;
    }
    else {
        @throw([self unsupportedPrimaryKeyTypeException]);
    }
    
    return cacheObject;
}

+ (instancetype)cacheObjectInRealm:(RLMRealm *)realm
                         forObject:(RLMObject *)object
{
    if (object) {
        id primaryKeyValue = [RLMObject primaryKeyValueForObject:object];
        RLMPropertyType primaryKeyType = object.objectSchema.primaryKeyProperty.type;
        
        if (primaryKeyType == RLMPropertyTypeString) {
            
            return [RBQObjectCacheObject objectInRealm:realm
                                         forPrimaryKey:primaryKeyValue];
        }
        else if (primaryKeyType == RLMPropertyTypeInt) {
            NSString *primaryKeyStringValue = ((NSNumber *)primaryKeyValue).stringValue;
            
            return [RBQObjectCacheObject objectInRealm:realm
                                         forPrimaryKey:primaryKeyStringValue];
        }
        else {
            @throw([self unsupportedPrimaryKeyTypeException]);
        }
    }
    
    return nil;
}

+ (RLMObject *)objectInRealm:(RLMRealm *)realm
              forCacheObject:(RBQObjectCacheObject *)cacheObject
{
    Class realClass = NSClassFromString(cacheObject.className);
    if (cacheObject.primaryKeyType == RLMPropertyTypeString) {
        
        return [realClass objectInRealm:realm forPrimaryKey:cacheObject.primaryKeyStringValue];
    }
    else if (cacheObject.primaryKeyType == RLMPropertyTypeInt) {
        NSNumber *numberFromString = @(cacheObject.primaryKeyStringValue.integerValue);
        
        return [realClass objectInRealm:realm forPrimaryKey:numberFromString];
    }
    else {
        @throw ([self unsupportedPrimaryKeyTypeException]);
    }
}

#pragma mark - RLMObject Class

+ (NSString *)primaryKey
{
    return @"primaryKeyStringValue";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"className": @"",
             @"primaryKeyStringValue" : @"",
             @"primaryKeyType" : @(NSIntegerMin),
             @"sectionKeyPathValue" : @""
             };
}

#pragma mark - Equality

- (BOOL)isEqualToObject:(RBQObjectCacheObject *)object
{
    if (self.primaryKeyType == RLMPropertyTypeString &&
        object.primaryKeyType == RLMPropertyTypeString) {
        
        return [self.primaryKeyStringValue isEqualToString:object.primaryKeyStringValue];
    }
    else if (self.primaryKeyType == RLMPropertyTypeInt &&
             object.primaryKeyType == RLMPropertyTypeInt) {
        
        return self.primaryKeyStringValue.integerValue == object.primaryKeyStringValue.integerValue;
    }
    else {
        return [super isEqual:object];
    }
}

- (BOOL)isEqual:(id)object
{
    NSString *className = NSStringFromClass(self.class);
    
    if ([className hasPrefix:@"RLMStandalone_"]) {
        return [self isEqualToObject:object];
    }
    else {
        return [super isEqual:object];
    }
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    RBQObjectCacheObject *objectCache = [[RBQObjectCacheObject allocWithZone:zone] init];
    objectCache.className = _className;
    objectCache.primaryKeyStringValue = _primaryKeyStringValue;
    objectCache.primaryKeyType = _primaryKeyType;
    objectCache.sectionKeyPathValue = _sectionKeyPathValue;
    objectCache.section = _section;
    
    return objectCache;
}

#pragma mark - Helper exception

+ (NSException *)unsupportedPrimaryKeyTypeException
{
    return [NSException exceptionWithName:@"Unsupported primary key type"
                                   reason:@"RBQFetchedResultsController only supports NSString or int/NSInteger primary keys"
                                 userInfo:nil];
}

@end
