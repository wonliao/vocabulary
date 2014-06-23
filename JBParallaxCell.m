//
//  JBParallaxCell.m
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

#import "JBParallaxCell.h"

@implementation JBParallaxCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{

    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
    
    float distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
    float difference = CGRectGetHeight(self.parallaxImage.frame) - CGRectGetHeight(self.frame);
    float move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
    
    CGRect imageRect = self.parallaxImage.frame;
    imageRect.origin.y = -(difference/2)+move;
    self.parallaxImage.frame = imageRect;

}

- (IBAction)favoriteCellBtnPress:(id)sender {

    UIButton* button = (UIButton*)sender ;
    int row = button.tag;
    [button setHidden:YES];

    NSLog(@"press ==> row(%d)", row);

    /*
    // 載入本地端儲存的資訊
    NSMutableDictionary *favoriteArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favorite"] mutableCopy];
    if(favoriteArray == nil) {

        favoriteArray = [[NSMutableDictionary alloc] init];
        NSLog(@"favoriteArray init ==>");
    }

    NSString *key = [NSString stringWithFormat:@"%d", row];
    NSLog(@"count(%d) key(%@)", [favoriteArray count], key);
    [favoriteArray setValue:key forKey:key];
    NSLog(@"count 2 => %d", [favoriteArray count]);
    
    // 儲存資訊至本地端
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:favoriteArray forKey:@"favorite"];
    [userDefaults synchronize];
    */
}


@end
