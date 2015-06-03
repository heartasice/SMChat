//
//  SMChatViewController.m
//  SMChat
//
//  Created by Eric Che on 6/3/15.
//  Copyright (c) 2015 Eric Che. All rights reserved.
//

#import "SMChatViewController.h"
#import "DBManager.h"
#import "JSQMessage.h"
@interface SMChatViewController ()

@end

@implementation SMChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chatMessages=(NSMutableArray<JSQMessageData>*)[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadData{
    
    NSArray *arr= [DBManager getChatMessageByCurrentUserId:@"eric@114.215.145.244" setToUserId:@"simon@114.215.145.244" setPageIndex:@1 setPageSize:@20];
    if (arr&&arr.count>0) {
        for (SMChatMessageModel *chatMessageModel in arr) {
            JSQMessage *message=[[JSQMessage alloc]initWithSenderId:chatMessageModel.fromUserId senderDisplayName:chatMessageModel.fromUserId date:chatMessageModel.timestamp text:chatMessageModel.messageBody];
            [_chatMessages addObject:message];
        }
    }
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _chatMessages.count;
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
