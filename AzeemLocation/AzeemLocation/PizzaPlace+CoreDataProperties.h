//
//  PizzaPlace+CoreDataProperties.h
//  AzeemLocation
//
//  Created by Datainvent Systems on 24/10/2015.
//  Copyright © 2015 Datainvent Systems. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PizzaPlace.h"

NS_ASSUME_NONNULL_BEGIN

@interface PizzaPlace (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSString *reservationurl;
@property (nullable, nonatomic, retain) NSString *twitter;

@end

NS_ASSUME_NONNULL_END
