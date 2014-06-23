//
//  JBViewController.m
//  JBParallaxTable
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Javier Berlana @jberlana
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "ViewController.h"

#import "JBParallaxCell.h"
#import "SqliteSimple.h"
#import "UIImage+MostColor.h"

#import <QuartzCore/QuartzCore.h>

@interface ViewController () <UIScrollViewDelegate>
{
    //是否从scrollview 中转换成拖动
    BOOL isPaning;
    BOOL isLeftShow,isLeftDragging;
    BOOL isRightShow,isRightDragging;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showIntroWithCrossDissolve];

    _words = [[NSMutableDictionary alloc] init];

    SqliteSimple *db = [[SqliteSimple alloc] initWithWritablePath:@"english.sqlite"];
    if([db open]){

        NSString *sql = [NSString stringWithFormat:@"SELECT `WORD`, `BRIEF_TRANSLATION`, `KK_PHONET` FROM `WordData` WHERE 1 ORDER BY `WORD_NUMBER` ASC;"];
        if ([db selectq:sql]) {

            int count = -1;
            while ([db next]) {

                NSString *word = [db textByIndex:0];
                NSString *brief = [db textByIndex:1];
                NSString *kk = [db textByIndex:2];

                count++;

                NSArray *temp = [[NSArray alloc] initWithObjects:word, brief, kk, nil];
                [_words setObject:temp forKey:[NSString stringWithFormat:@"%d", count]];
            }
        }

        [db close];
    }
    
    
    
    // 載入本地端儲存的資訊
    //favoriteArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] mutableCopy];

    // layout switch
    // 載入本地端儲存的資訊
    isLayoutRight = [[NSUserDefaults standardUserDefaults] integerForKey:@"isLayoutRight"];
    NSLog(@"isLayoutRight(%d)", isLayoutRight);
    if(isLayoutRight == 1) {
        [self.layoutSwitch setOn:YES animated:NO];
    }
    
    // voice switch
    // 載入本地端儲存的資訊
    isVoiceFemale = [[NSUserDefaults standardUserDefaults] integerForKey:@"isVoiceFemale"];
    NSLog(@"isVoiceFemale(%d)", isVoiceFemale);
    if(isVoiceFemale == 1) {
        [self.voiceSwitch setOn:YES animated:NO];
    }
    
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.3; //seconds
    //lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]init];
    [pan addTarget:self action:@selector(handlePan:)];
    [self.view_content addGestureRecognizer:pan];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self scrollViewDidScroll:nil];
    
    // 載入本地端儲存的資訊
    NSInteger table_index = [[NSUserDefaults standardUserDefaults] integerForKey:@"table_index"] + 2;
    //NSLog(@"viewDidAppear ==> table_index(%d)", table_index);

    // 移動至最後觀看的 cell
    [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:table_index inSection:0]
                            atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    
    //isFavoriteStatus = [[NSUserDefaults standardUserDefaults] integerForKey:@"isFavoriteStatus"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    if(isFavoriteStatus == 1) {
        
        // 載入本地端儲存的資訊
        favoriteArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] mutableCopy];
        NSArray *keys = [favoriteArray allKeys];
        NSLog(@"keys count(%d)", [keys count]);
        return [keys count];
    }
    */
    
    return [[_words allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"parallaxCell";
    JBParallaxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    NSInteger row = [indexPath row] + 1;
    
    NSArray *temp;
    NSString *file_name;
    
    //if(isFavoriteStatus == 0) {
    
        temp = [_words objectForKey:[NSString stringWithFormat:@"%d", row]];
        file_name = [NSString stringWithFormat:@"%04.4d", indexPath.row % 396];
    /*
    } else {
        
        NSArray *keys = [favoriteArray allKeys];
        if(row >= [keys count]) {
            return cell;
        }
        
        NSString *aKey = [keys objectAtIndex:row];
        NSString *wordsKey = [favoriteArray objectForKey:aKey];
        temp = [_words objectForKey:wordsKey];
        
        file_name = [NSString stringWithFormat:@"%04.4d", [aKey intValue] % 396];
    }
    */
    
    
    NSString *word = [temp objectAtIndex:0];
    NSString *brief = [temp objectAtIndex:1];
    NSString *kk = [NSString stringWithFormat:@"[%@]", [temp objectAtIndex:2]];
    
 
    UIImage *img = [UIImage imageNamed:file_name];
    cell.parallaxImage.image = img;
  
    UIColor *fontColor = [UIColor whiteColor];
    
    
    cell.titleLabel.text = word;
    cell.titleLabel.textColor = fontColor;// [UIColor blackColor];
    [cell.titleLabel setFont:[UIFont systemFontOfSize:32]];
    
    cell.subtitleLabel.text = brief;
    cell.subtitleLabel.textColor = fontColor; //[UIColor blackColor];
    
    cell.kkLabel.text = kk;
    cell.kkLabel.textColor = fontColor;
    
    
    if(isLayoutRight == 1) {
    
        cell.titleLabel.textAlignment = NSTextAlignmentRight;
        cell.subtitleLabel.textAlignment = NSTextAlignmentRight;
        cell.kkLabel.textAlignment = NSTextAlignmentRight;
    } else {
        cell.titleLabel.textAlignment = NSTextAlignmentLeft;
        cell.subtitleLabel.textAlignment = NSTextAlignmentLeft;
        cell.kkLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return cell;
}

-(float)rgbToHSBWithR:(float)red G:(float)green B:(float)blue
{
    // assuming values are in 0 - 1 range, if they are byte representations, divide them by 255
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    float h, s, b;
    [color getHue:&h saturation:&s brightness:&b alpha:NULL];
  
    return b;
}


-(UIColor *)reverseColorOf :(UIColor *)oldColor
{
    CGColorRef oldCGColor = oldColor.CGColor;
    
    int numberOfComponents = CGColorGetNumberOfComponents(oldCGColor);
    // can not invert - the only component is the alpha
    if (numberOfComponents == 1) {
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat *oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    
    int i = numberOfComponents - 1;
    newComponentColors[i] = oldComponentColors[i]; // alpha
    while (--i >= 0) {
        newComponentColors[i] = 1 - oldComponentColors[i];
    }
    
    CGColorRef newCGColor = CGColorCreate(CGColorGetColorSpace(oldCGColor), newComponentColors);
    UIColor *newColor = [UIColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    
    //=====For the GRAY colors 'Middle level colors'
    CGFloat white = 0;
    [oldColor getWhite:&white alpha:nil];
    
    if(white>0.3 && white < 0.67)
    {
        if(white >= 0.5)
            newColor = [UIColor darkGrayColor];
        else if (white < 0.5)
            newColor = [UIColor blackColor];
        
    }
    return newColor;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get visible cells on table view.
    NSArray *visibleCells = [self.tableView visibleCells];

    for (JBParallaxCell *cell in visibleCells) {
    
        [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling:scrollView];
    }
}

- (void)stoppedScrolling:(UIScrollView *)scrollView
{
    // Get visible cells on table view.
    NSArray *visibleCells = [self.tableView visibleCells];
    
    JBParallaxCell *cell = [visibleCells objectAtIndex:0];
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    NSLog(@"scrollViewDidScroll ==> row(%d)", path.row);
    
    // 儲存資訊至本地端
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:path.row forKey:@"table_index"];
    [userDefaults synchronize];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 不提供語音播放
    /*
    NSInteger row = [indexPath row] + 1;
    //NSLog(@"row(%d)", row);
    
    NSArray *temp = [_words objectForKey:[NSString stringWithFormat:@"%d", row]];
    NSString *word;
    if(isVoiceFemale == 1) {
    
        word = [NSString stringWithFormat:@"female_%@", [temp objectAtIndex:0]];
    } else {
        word = [NSString stringWithFormat:@"male_%@", [temp objectAtIndex:0]];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:word ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    //NSLog(@"word(%@) url(%@)", word, url);
    
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url  error:&error];
    [_audioPlayer play];
    */
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state==UIGestureRecognizerStateBegan) {

        CGPoint p = [gestureRecognizer locationInView:self.tableView];

        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];

        JBParallaxCell *cell = (JBParallaxCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if(cell) {

            int index = indexPath.row;
            NSString *file_name = [NSString stringWithFormat:@"%04.4d", index % 396];
            UIImage *img = [UIImage imageNamed:file_name];
            UIColor *fontColor = [UIColor whiteColor];

            // 有圖片時
            if(cell.parallaxImage.image != nil) {

                // 刪除圖片並設背景色為圖片的平均色
                UIColor *most = [img mostColor];
                [cell.parallaxImage setImage:nil];
                [cell.parallaxImage setBackgroundColor:most];

                // 如果背景色為高明度時，設定文字顏色為黑色
                CGFloat h, s, b;
                [most getHue:&h saturation:&s brightness:&b alpha:NULL];
                if( b > 0.8)    fontColor = [UIColor blackColor];
                
                /*
                int index = indexPath.row;
                NSString *key = [NSString stringWithFormat:@"%d", index];
                NSString *favorite = [favoriteArray objectForKey:key];
                if(favorite == nil) {
                
                    // 顯示 favorite 按鈕
                    [cell.favoriteCellBtn setHidden:NO];
                    [cell.favoriteCellBtn setTag:indexPath.row];
                }
                */
            // 沒有圖片時
            } else {

                // 設定圖片
                [cell.parallaxImage setImage:img];
                
                [cell.favoriteCellBtn setHidden:YES];
            }

            // 設定文字顏色
            cell.titleLabel.textColor = fontColor;
            cell.subtitleLabel.textColor = fontColor;
            cell.kkLabel.textColor = fontColor;
        }
    }
}









- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"好心情單字";
    page1.desc = @"一起來環遊世界背單字吧";
    page1.bgImage = [UIImage imageNamed:@"1.jpg"];
    page1.titleImage = [UIImage imageNamed:@"original"];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"真人發音";
    page2.desc = @"點擊單字卡，即可聆聽單字的唸法";
    page2.bgImage = [UIImage imageNamed:@"2.jpg"];
    page2.titleImage = [UIImage imageNamed:@"supportcat"];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"切換顏色";
    page3.desc = @"長按單字卡，可切換文字顏色";
    page3.bgImage = [UIImage imageNamed:@"3.jpg"];
    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)introDidFinish {
    NSLog(@"Intro callback");
}





-(void)handlePan:(UIPanGestureRecognizer*) panParam
{
    if(isLeftShow)
    {
        //isLeftDragging = YES;
    }
    else if(isRightShow)
    {
        isRightDragging = YES;
    }
    else if(!isLeftDragging&&!isRightDragging)
    {
        float v_X = [panParam velocityInView:panParam.view].x;
        if(v_X>0)
        {
            //isLeftDragging = YES;
        }
        else
        {
            isRightDragging = YES;
        }
    }
    CGPoint point = [panParam translationInView:panParam.view];
    [panParam setTranslation:CGPointZero inView:panParam.view];
    
    int v1 = 160; //250;
    
    
    
    float contentX = self.view_content.frame.origin.x;
    if(isLeftDragging)
    {
        contentX +=point.x;
        if(contentX > v1)
        {
            contentX = v1;
        }
        else if(contentX < 0)
        {
            contentX = 0;
        }
    }
    else if(isRightDragging)
    {
        contentX += point.x;
        if(contentX < -v1)
        {
            contentX = -v1;
        }
        else if(contentX > 0)
        {
            contentX = 0;
        }
    }
    
    CGRect frame = self.view_content.frame;
    frame.origin.x = contentX;
    self.view_content.frame= frame;
    
    if(panParam.state == UIGestureRecognizerStateCancelled || panParam.state == UIGestureRecognizerStateEnded)
    {
        float v_X = [panParam velocityInView:panParam.view].x;
        float diff = 0;
        float finishedX = 0;
        if(isLeftDragging)
        {
            if(v_X > 0)
            {
                diff = v1 - contentX;
                finishedX = v1;
                isLeftShow = YES;
            }
            else
            {
                diff = contentX;
                finishedX = 0;
                isLeftShow = isRightShow = NO;
                
            }
        }
        else if(isRightDragging)
        {
            if(v_X > 0)
            {
                diff = contentX;
                finishedX = 0;
                isLeftShow = isRightShow = NO;
            }
            else
            {
                diff = contentX + v1;
                finishedX = -v1;
                isRightShow = YES;
            }
        }
        //防止出现 抖动
        NSTimeInterval duration = MIN(0.3f,ABS(diff/v_X));
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect frame = self.view_content.frame;
                             frame.origin.x = finishedX;
                             self.view_content.frame= frame;
                         }
                         completion:^(BOOL finished) {
                             isPaning = NO;
                             isLeftDragging = NO;
                             isRightDragging = NO;
                         }];
    }
}

/*
- (IBAction)favoriteSwitch:(id)sender {

    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {

        NSLog(@"yes");
        isFavoriteStatus = 1;
    }else {

        NSLog(@"no");
        isFavoriteStatus = 0;
    }
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}
*/
- (IBAction)layoutSwitch:(id)sender {

    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        
        NSLog(@"yes");
        isLayoutRight = 1;
        
    }else {
        
        NSLog(@"no");
        isLayoutRight = 0;
    }

    [self.tableView reloadData];
    
    // 儲存資訊至本地端
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:isLayoutRight forKey:@"isLayoutRight"];
    [userDefaults synchronize];
}

- (IBAction)voiceSwitch:(id)sender {

    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        
        NSLog(@"yes");
        isVoiceFemale = 1;
        
    }else {
        
        NSLog(@"no");
        isVoiceFemale = 0;
    }

    // 儲存資訊至本地端
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:isVoiceFemale forKey:@"isVoiceFemale"];
    [userDefaults synchronize];
}

- (IBAction)aboutBtnPress:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.facebook.com/music4sport"]];
}




@end
