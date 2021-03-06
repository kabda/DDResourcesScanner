/*
 * 感知哈希算法(PHA)是哈希算法的一类, 主要用来做相似图片的搜索工作.
 * PHA是一类比较哈希方法的统称, 图片所包含的特征被用来生成一组指纹(非唯一), 而这些指纹是可以进行比较的.
 * 下面是简单的步骤, 来说明对图像进行PHA的运算过程:
 * 1. 获取图片的主色调;
 * 2. 缩小尺寸, 快速去除高频和细节, 只保留结构明暗;
 * 3. 简化色彩, 将图片转为64级灰度;
 * 4. 计算平均值, 比较像素的灰度(大于或等于平均值, 记为1; 小于平均值, 记为0), 获取图片形状;
 * 5. 计算主色差异;
 * 6. 计算哈希值并比较相似度(理论上, 不相同的数据位不超过5, 就说明两张图片很相似; 如果大于10, 就说明这是两张不同的图片);
 */

#import <Cocoa/Cocoa.h>

@interface NSImage (PHA)

- (NSString *)fingerprint;

- (NSColor *)mainColor;

+ (NSInteger)differentBetweenFingerprint:(NSString *)fingerprint1 andFingerprint:(NSString *)fingerprint2;

+ (CGFloat)differentBetweenColor:(NSColor *)color1 andColor:(NSColor *)color2;

@end
