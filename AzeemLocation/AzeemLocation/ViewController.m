//
//  ViewController.m
//  AzeemLocation
//
//  Created by Datainvent Systems on 24/10/2015.
//  Copyright © 2015 Datainvent Systems. All rights reserved.
//

#import "ViewController.h"
#import <FourSquareKit/FourSquareKit.h>
#import "FSResturantCell.h"
#import "FSResturantDetailViewController.h"
#import "AppDelegate.h"
#import "PizzaPlace.h"
@interface ViewController ()
@property(nonatomic,strong)UXRFourSquareNetworkingEngine * fourSquareEngine;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSArray * pizzaPlaces;
@property(nonatomic,strong)CLLocationManager *locationManager;;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Pizza Places";
    _pizzaPlaces = nil;
    _fourSquareEngine = [UXRFourSquareNetworkingEngine sharedInstance];
    // Do any additional setup after loading the view, typically from a nib.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [_locationManager requestAlwaysAuthorization];
    }
    [_activityIndicator startAnimating];
    [_locationManager startUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDataSaved:)
                                                 name:@"DataSaved"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:self];
}
#pragma mark - Notification Delegate
- (void) receiveDataSaved:(NSNotification *) notification
{
    NSManagedObjectContext * managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PizzaPlace" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    self.pizzaPlaces = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [self.tableView reloadData];
}


#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"Location Fetched");
    [self fetchNearbyPizzaLocation:[locations lastObject]];
}

#pragma mark - FourSquare Fetch Functions
-(void)fetchNearbyPizzaLocation:(CLLocation *)newLocation{
    // Get Nearby pizza restaurants.
    NSString *query = @"pizza";
    [self.fourSquareEngine exploreRestaurantsNearLatLong:newLocation.coordinate withQuery:query withCompletionBlock:^(NSArray *restaurants) {
        if([restaurants count]>=5){
            //Stop location Update
            [_locationManager stopUpdatingLocation];
            //Sorting Resturants then Storing in Array
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            self.pizzaPlaces = [restaurants sortedArrayUsingDescriptors:sortDescriptors];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSManagedObjectContext * managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
                for(UXRFourSquareRestaurantModel *restaurantInfo in self.pizzaPlaces){
                    //Check If Data Already Exisits
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PizzaPlace" inManagedObjectContext:managedObjectContext];
                    [fetchRequest setEntity:entity];
                    
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", restaurantInfo.name]];
                    
                    NSError *error;
                    NSArray * result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    if([result count] == 0){//Insert if Name not already present
                        PizzaPlace * pizzaResturant = [NSEntityDescription
                                                       insertNewObjectForEntityForName:@"PizzaPlace" inManagedObjectContext:managedObjectContext];
                        pizzaResturant.name = restaurantInfo.name;
                        pizzaResturant.phone = restaurantInfo.contact.phone?restaurantInfo.contact.phone:@"";
                        pizzaResturant.twitter = restaurantInfo.contact.twitter?restaurantInfo.contact.twitter:@"";
                        pizzaResturant.reservationurl = [restaurantInfo.reservations.url absoluteString]?[restaurantInfo.reservations.url absoluteString]:@"";
                        NSError *error;
                        if (![managedObjectContext save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:self];
                [_activityIndicator stopAnimating];
            });
        }
    } failureBlock:^(NSError *error) {
        //Error
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.pizzaPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ResturantCell";
    
    // Set up the cell.
    FSResturantCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        [_tableView registerNib:[UINib nibWithNibName:@"FSResturantCell" bundle:nil] forCellReuseIdentifier:@"ResturantCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    cell.tag = indexPath.row;
    PizzaPlace *restaurantInfo = [self.pizzaPlaces objectAtIndex:indexPath.row];
    cell.resturantName.text   = restaurantInfo.name;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ShowResturant" sender:indexPath];
}


 #pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Make sure your segue name in storyboard is the same as this line
     if ([[segue identifier] isEqualToString:@"ShowResturant"])
     {
         NSIndexPath *indexPath = (NSIndexPath *)sender;
         
         // Get reference to the destination view controller
         FSResturantDetailViewController *vc = [segue destinationViewController];
         vc.restaurantInfo = [self.pizzaPlaces objectAtIndexedSubscript:indexPath.row];
         
     }
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
