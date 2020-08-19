//
//  MapMarkerView.m
//  Runner
//
//  Created by Mihail Varbanov on 7/15/19.
//  Copyright 2020 Board of Trustees of the University of Illinois.
    
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MapMarkerView.h"

#import "NSDictionary+InaTypedValue.h"
#import "UIColor+InaParse.h"
#import "NSDictionary+UIUCExplore.h"
#import "InaSymbols.h"

#import <GoogleMaps/GoogleMaps.h>

@interface MapExploreMarkerView : MapMarkerView
- (instancetype)initWithExplore:(NSDictionary*)explore;
@end

@interface MapExploresMarkerView : MapMarkerView
- (instancetype)initWithExplore:(NSDictionary*)explore;
@end

/////////////////////////////////
// MapMarkerView

@interface MapMarkerView() {}
@property (nonatomic) NSDictionary *explore;
@end

@implementation MapMarkerView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
	}
	return self;
}

+ (instancetype)createFromExplore:(NSDictionary*)explore {
	return (1 < explore.uiucExplores.count) ?
		[[MapExploresMarkerView alloc] initWithExplore:explore] :
		[[MapExploreMarkerView alloc] initWithExplore:explore];
}

- (void)setDisplayMode:(MapMarkerDisplayMode)displayMode {
	if (_displayMode != displayMode) {
		_displayMode = displayMode;
		[self updateDisplayMode];
	}
}

- (void)updateDisplayMode {
}

- (void)setBlurred:(bool)blurred {
	if (_blurred != blurred) {
		_blurred = blurred;
		[self updateBlurred];
	}
}

- (void)updateBlurred {
}

+ (UIImage*)markerImageWithHexColor:(NSString*)hexColor {

	static NSMutableDictionary *gMarkerImageMap = nil;
	if (gMarkerImageMap == nil) {
		gMarkerImageMap = [[NSMutableDictionary alloc] init];
	}
	
	UIImage *image = [gMarkerImageMap objectForKey:hexColor];
	if (image == nil) {
		UIColor *color = [UIColor inaColorWithHex:hexColor];
		image = [GMSMarker markerImageWithColor:color];
		if (image != nil) {
			[gMarkerImageMap setObject:image forKey:hexColor];
		}
	}
	return image;
}

@end


/////////////////////////////////
// MapExploreMarkerView

CGFloat const kExploreMarkerIconSize0 = 20;
CGFloat const kExploreMarkerIconSize1 = 30;
CGFloat const kExploreMarkerIconSize2 = 40;
CGFloat const kExploreMarkerIconSize[3] = { kExploreMarkerIconSize0, kExploreMarkerIconSize1, kExploreMarkerIconSize2 };

CGFloat const kExploreMarkerIconGutter = 3;
CGFloat const kExploreMarkerTitleFontSize = 12;
CGFloat const kExploreMarkerDescrFontSize = 12;
CGSize  const kExploreMarkerViewSize = { 180, kExploreMarkerIconSize2 + kExploreMarkerIconGutter + kExploreMarkerTitleFontSize + kExploreMarkerDescrFontSize };

@interface MapExploreMarkerView() {
	UIImageView *iconView;
	UILabel     *titleLabel;
	UILabel     *descrLabel;
}
@end

@implementation MapExploreMarkerView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
	
		//self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
	
		//UIImage *markerImage = [UIImage imageNamed:@"maps-icon-marker-circle-40"];
		iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self addSubview:iconView];

		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.font = [UIFont boldSystemFontOfSize:kExploreMarkerTitleFontSize];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.textColor = [UIColor inaColorWithHex:@"13294b"]; // darkSlateBlueTwo
		titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		titleLabel.shadowOffset = CGSizeMake(1, 1);
		[self addSubview:titleLabel];

		descrLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		descrLabel.font = [UIFont boldSystemFontOfSize:kExploreMarkerDescrFontSize];
		descrLabel.textAlignment = NSTextAlignmentCenter;
		descrLabel.textColor = [UIColor inaColorWithHex:@"244372"]; // darkSlateBlue
		descrLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		descrLabel.shadowOffset = CGSizeMake(1, 1);
		[self addSubview:descrLabel];

		[self updateDisplayMode];
	}
	return self;
}

- (instancetype)initWithExplore:(NSDictionary*)explore {
	if (self = [self initWithFrame:CGRectMake(0, 0, kExploreMarkerViewSize.width, kExploreMarkerViewSize.height)]) {
		self.explore = explore;
		iconView.image = [self.class markerImageWithHexColor:explore.uiucExploreMarkerHexColor];
		titleLabel.text = explore.uiucExploreTitle;
		descrLabel.text = explore.uiucExploreDescription;
	}
	return self;
}

- (void)layoutSubviews {
	CGSize contentSize = self.frame.size;

	CGFloat y = 0;
	NSInteger maxIconIndex = _countof(kExploreMarkerIconSize) - 1;
	
	CGSize iconSize = iconView.image.size;

	CGFloat iconH = kExploreMarkerIconSize[MIN(MAX(self.displayMode, 0), maxIconIndex)];
	CGFloat iconW = (0 < iconSize.height) ? (iconSize.width * iconH / iconSize.height) : 0;

	CGFloat iconMaxH = kExploreMarkerIconSize[maxIconIndex];

	iconView.frame = CGRectMake((contentSize.width - iconW) / 2, iconMaxH - iconH, iconW, iconH);
	y += iconMaxH + kExploreMarkerIconGutter;

	CGFloat titleH = titleLabel.font.pointSize;
	titleLabel.frame = CGRectMake(0, y, contentSize.width, titleH);
	y += titleH;

	CGFloat descrH = descrLabel.font.pointSize;
	descrLabel.frame = CGRectMake(0, y, contentSize.width, descrH);
	y += descrH;
}

- (void)updateDisplayMode {
	titleLabel.hidden = (self.displayMode < MapMarkerDisplayMode_Title);
	descrLabel.hidden = (self.displayMode < MapMarkerDisplayMode_Extended);
	[self setNeedsLayout];
}

- (void)updateBlurred {
	iconView.image = [self.class markerImageWithHexColor:self.blurred ? @"#a0a0a0" : self.explore.uiucExploreMarkerHexColor];
	titleLabel.textColor = self.blurred ? [UIColor grayColor] : [UIColor inaColorWithHex:@"13294b"]; // darkSlateBlueTwo
	descrLabel.textColor = self.blurred ? [UIColor grayColor] : [UIColor inaColorWithHex:@"244372"]; // darkSlateBlue
}

- (NSString*)title {
	return titleLabel.text;
}

- (NSString*)descr {
	return descrLabel.text;
}

- (CGPoint)anchor {
	return CGPointMake(0.5, kExploreMarkerIconSize[_countof(kExploreMarkerIconSize) - 1] / kExploreMarkerViewSize.height);
}

@end

/////////////////////////////////
// MapExploresMarkerView

CGFloat const kExploresMarkerIconSize0 = 16;
CGFloat const kExploresMarkerIconSize1 = 20;
CGFloat const kExploresMarkerIconSize2 = 24;
CGFloat const kExploresMarkerIconSize[3] = { kExploresMarkerIconSize0, kExploresMarkerIconSize1, kExploresMarkerIconSize2 };

CGFloat const kExploresMarkerCountFontSize0 = 10;
CGFloat const kExploresMarkerCountFontSize1 = 12.5;
CGFloat const kExploresMarkerCountFontSize2 = 15;
CGFloat const kExploresMarkerCountFontSize[3] = { kExploresMarkerCountFontSize0, kExploresMarkerCountFontSize1, kExploresMarkerCountFontSize2 };

CGFloat const kExploresMarkerIconGutter = 3;
CGFloat const kExploresMarkerTitleFontSize = 12;
CGFloat const kExploresMarkerDescrFontSize = 12;
CGSize  const kExploresMarkerViewSize = { 180, kExploresMarkerIconSize2 + kExploresMarkerIconGutter + kExploresMarkerTitleFontSize + kExploresMarkerDescrFontSize };

@interface MapExploresMarkerView() {
	UIView		*circleView;
	UILabel     *countLabel;
	UILabel     *titleLabel;
	UILabel     *descrLabel;
}
@end

@implementation MapExploresMarkerView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
	
		//self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
		
		circleView = [[UIView alloc] initWithFrame:CGRectZero];
		[self addSubview:circleView];
		
		countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		//countLabel.font = [UIFont boldSystemFontOfSize:kExploresMarkerCountFontSize0];
		countLabel.textAlignment = NSTextAlignmentCenter;
		countLabel.textColor = [UIColor whiteColor];
		[self addSubview:countLabel];

		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.font = [UIFont boldSystemFontOfSize:kExploresMarkerTitleFontSize];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.textColor = [UIColor inaColorWithHex:@"13294b"]; // darkSlateBlueTwo
		titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		titleLabel.shadowOffset = CGSizeMake(1, 1);
		[self addSubview:titleLabel];

		descrLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		descrLabel.font = [UIFont boldSystemFontOfSize:kExploresMarkerDescrFontSize];
		descrLabel.textAlignment = NSTextAlignmentCenter;
		descrLabel.textColor = [UIColor inaColorWithHex:@"244372"]; // darkSlateBlue
		descrLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		descrLabel.shadowOffset = CGSizeMake(1, 1);
		[self addSubview:descrLabel];

		[self updateDisplayMode];
	}
	return self;
}

- (instancetype)initWithExplore:(NSDictionary*)explore {
	if (self = [self initWithFrame:CGRectMake(0, 0, kExploresMarkerViewSize.width, kExploresMarkerViewSize.height)]) {
		self.explore = explore;

		circleView.backgroundColor = [UIColor inaColorWithHex:explore.uiucExploreMarkerHexColor];
		circleView.layer.borderColor = [[UIColor blackColor] CGColor];
		circleView.layer.borderWidth = 0.5;

		countLabel.text = [NSString stringWithFormat:@"%d", (int)explore.uiucExplores.count];
		titleLabel.text = explore.uiucExploreTitle;
		descrLabel.text = explore.uiucExploreDescription;
	}
	return self;
}

- (void)layoutSubviews {
	CGSize contentSize = self.frame.size;

	CGFloat y = 0;
	NSInteger maxIconIndex = _countof(kExploresMarkerIconSize) - 1;
	CGFloat iconSize = kExploresMarkerIconSize[MIN(MAX(self.displayMode, 0), maxIconIndex)];
	CGFloat iconMaxSize = kExploresMarkerIconSize[maxIconIndex];
	CGFloat iconY = (iconMaxSize - iconSize) / 2;
	CGFloat iconX = (contentSize.width - iconSize) / 2;

	circleView.frame = CGRectMake(iconX, iconY, iconSize, iconSize);
	if (circleView.layer.cornerRadius != iconSize/2) {
		circleView.layer.cornerRadius = iconSize/2;
	}

	CGFloat countH = countLabel.font.pointSize;
	countLabel.frame = CGRectMake(iconX, iconY + (iconSize - countH) / 2 , iconSize, countH);

	y += iconMaxSize + kExploresMarkerIconGutter;

	CGFloat titleH = titleLabel.font.pointSize;
	titleLabel.frame = CGRectMake(0, y, contentSize.width, titleH);
	y += titleH;

	CGFloat descrH = descrLabel.font.pointSize;
	descrLabel.frame = CGRectMake(0, y, contentSize.width, descrH);
	y += descrH;
}

- (void)updateDisplayMode {
	countLabel.font = [UIFont boldSystemFontOfSize:kExploresMarkerCountFontSize[MIN(MAX(self.displayMode, 0), _countof(kExploresMarkerCountFontSize) - 1)]];
	titleLabel.hidden = (self.displayMode < MapMarkerDisplayMode_Title);
	descrLabel.hidden = (self.displayMode < MapMarkerDisplayMode_Extended);
	[self setNeedsLayout];
}

- (void)updateBlurred {
	circleView.backgroundColor = [UIColor inaColorWithHex:self.blurred ? @"#a0a0a0" : self.explore.uiucExploreMarkerHexColor];
	titleLabel.textColor = self.blurred ? [UIColor grayColor] : [UIColor inaColorWithHex:@"13294b"]; // darkSlateBlueTwo
	descrLabel.textColor = self.blurred ? [UIColor grayColor] : [UIColor inaColorWithHex:@"244372"]; // darkSlateBlue
}

- (NSString*)title {
	return titleLabel.text;
}

- (NSString*)descr {
	return descrLabel.text;
}

- (CGPoint)anchor {
	return CGPointMake(0.5, kExploresMarkerIconSize[_countof(kExploresMarkerIconSize) - 1] / 2 / kExploreMarkerViewSize.height);
}


@end
