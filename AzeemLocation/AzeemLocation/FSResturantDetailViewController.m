//
//  FSResturantDetailViewController.m
//  AzeemLocation
//
//  Created by Datainvent Systems on 24/10/2015.
//  Copyright © 2015 Datainvent Systems. All rights reserved.
//

#import "FSResturantDetailViewController.h"

@interface FSResturantDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *resPhone;
@property (weak, nonatomic) IBOutlet UILabel *resTwitter;
@property (weak, nonatomic) IBOutlet UILabel *resReservations;

@end

@implementation FSResturantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _restaurantInfo.name;
    _name.text = [NSString stringWithFormat:@"Name : %@",_restaurantInfo.name];
    _resPhone.text = [NSString stringWithFormat:@"Contact : %@",_restaurantInfo.phone];
    _resTwitter.text = [NSString stringWithFormat:@"Twitter : %@",_restaurantInfo.twitter];
    _resReservations.text = _restaurantInfo.reservationurl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
