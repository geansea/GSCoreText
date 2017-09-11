//
//  ViewController.m
//  GSCoreTextDemo_iOS
//
//  Created by geansea on 2017/8/13.
//
//

#import "ViewController.h"
#import "GSCTFrameView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"\u2600\U0001F602习近平1985年访问艾奥瓦州时，aaaaaaaaaaaaaa曾受到一户人家的招待。2012年故地重游时，时任中国国家副主席的习近平接受献花。\n中国国家主席习近平即将于下周抵达美国，展开对美国的首次国事访问。中国驻美国大使崔天凯表示，习近平主席本次访美行程跨度广、亮点多，习主席此次访美将是与美国政治、商业以及社会各领域充分交流的良机。\n这些活动包括在西雅图会见美国企业高管、白宫草坪上鸣21响礼炮，并在白宫举行国宴。之后，习近平还将前往纽约，首次在联合国发表讲话。\n（括号），测试：《书名》"];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(1, 10)];
    
    GSCTFrameView *gsView = [[GSCTFrameView alloc] initWithFrame:self.view.bounds];
    gsView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:gsView];
    GSCTTypesetter *gsTypesetter = [[GSCTTypesetter alloc] initWithString:string];
    gsTypesetter.font = [UIFont systemFontOfSize:16];
    gsTypesetter.alignment = NSTextAlignmentJustified;
    gsTypesetter.puncCompressRate = 0.4;
    gsTypesetter.lineSpacing = 0.2;
    gsTypesetter.paragraphSpacing = 0.4;
    GSCTFrame *gsFrame = [gsTypesetter createFrameWithRect:CGRectInset(gsView.bounds, 10, 10) startIndex:0];
    //for (int i = 0; i < 1000; ++i) {
    //    gsFrame = [gsTypesetter createFrameWithRect:CGRectInset(gsView.bounds, 10, 10) startIndex:0];
    //}
    gsView.gsFrame = gsFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
