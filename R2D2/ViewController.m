//
//  ViewController.m
//  R2D2
//
//  Created by daniel martinez gonzalez on 22/12/17.
//  Copyright © 2017 com.seat. All rights reserved.
//

#import "ViewController.h"
#import <RobotKit/RobotKit.h>



@interface ViewController ()
    @property (strong, atomic) RKConvenienceRobot* robot;
    @property (nonatomic) BOOL ledOn;
    @property (nonatomic) NSTimer *check;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RKRobotDiscoveryAgent sharedAgent] addNotificationObserver:self selector:@selector(handleRobotStateChangeNotification:)];
}

- (void)viewDidAppear:(BOOL)animated{

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)checkDiscovery:(NSTimer*)theTimer{
    if([[RKRobotDiscoveryAgent sharedAgent] isDiscovering]){
        NSLog(@"\n    Discovering...");
    }
}



- (void)handleRobotStateChangeNotification:(RKRobotChangedStateNotification*)n {
    switch(n.type) {
        case RKRobotConnecting:
            [self handleConnecting];
            break;
        case RKRobotOnline: {
            // Do not allow the robot to connect if the application is not running
            RKConvenienceRobot *convenience = [RKConvenienceRobot convenienceWithRobot:n.robot];
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                [convenience disconnect];
                return;
            }
            self.robot = convenience;
            [self handleConnected];
            break;
        }
        case RKRobotDisconnected:
            [self handleDisconnected];
            self.robot = nil;
            [RKRobotDiscoveryAgent startDiscovery];
            break;
        default:
            break;
    }
}



- (void) handleConnecting{
    NSLog(@"%@ Connecting....", _robot.robot.name);
    
}
    
- (void)handleConnected {
    NSLog(@"Connected: -> %@" , _robot.robot.name);
    [self toggleLED];
    
}
    
- (void)handleDisconnected {
    NSLog(@"Disconnected");
}

- (IBAction)ConnectPressed:(id)sender {
    if ([RKRobotDiscoveryAgent startDiscovery]){
        NSLog(@"\n    Discovering Robots....");
        
        self.check = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(checkDiscovery:)
                                                    userInfo:nil
                                                     repeats:YES];
        
    }else{
        NSLog(@"\n    Error Discovering !!");
    }
}


- (IBAction)DisconnectPressed:(id)sender {
    
    [self.check invalidate];
    NSLog(@"Disconnecting...");
    
    if (_robot) {
        NSLog(@"Disconnecting... -2-");
        [_robot sleep];
    }
}

- (void)toggleLED {
    if(!_robot || ![_robot isConnected]) return;
        
    if (_ledOn) {
        [_robot setLEDWithRed:0 green:0 blue:0];
    }
    else {
        [_robot setLEDWithRed:0 green:0 blue:1];
    }
    _ledOn = !_ledOn;
    [self performSelector:@selector(toggleLED) withObject:nil afterDelay:0.5];
}

@end
