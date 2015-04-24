//
//  notePadViewController.m
//  HomeWork Scribe
//
//  Created by Daniel Katz on 4/24/15.
//  Copyright (c) 2015 Stratton Apps. All rights reserved.
//

#import "notePadViewController.h"
#import "notesTableViewController.h"
#import "dataClass.h"
@interface notePadViewController ()

@end

@implementation notePadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataClass *obj = [dataClass getInstance];
    if (obj.note) {
        self.textField.text = obj.note;
        obj.note = nil;
    }
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(add)];
    flipButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = flipButton;
    
    // Do any additional setup after loading the view.
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%@",[alertView buttonTitleAtIndex:buttonIndex]);
    NSLog(@"%ld",(long)buttonIndex);
        NSMutableArray *savedValues = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@",[alertView buttonTitleAtIndex:buttonIndex]]]];
        NSString *saveString = self.textField.text;
        [savedValues addObject:saveString];
        [[NSUserDefaults standardUserDefaults]setObject:savedValues forKey:[NSString stringWithFormat:@"%@",[alertView buttonTitleAtIndex:buttonIndex]]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        notesTableViewController *purchaseContr = (notesTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"notes"];
        [self.navigationController pushViewController:purchaseContr animated:YES];
    
}
-(void)add{
    UIAlertView *chooseSubject = [[UIAlertView alloc]initWithTitle:@"Set Subject" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Math",@"Science",@"Social Studies",@"English",@"Language", nil];
    [chooseSubject show];
    
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