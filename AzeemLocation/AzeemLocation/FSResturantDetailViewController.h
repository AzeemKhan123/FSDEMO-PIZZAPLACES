//
//  FSResturantDetailViewController.h
//  AzeemLocation
//
//  Created by Datainvent Systems on 24/10/2015.
//  Copyright © 2015 Datainvent Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FourSquareKit/FourSquareKit.h>
#import "PizzaPlace.h"
@interface FSResturantDetailViewController : UIViewController
@property(nonatomic,strong)PizzaPlace *restaurantInfo;
@end
