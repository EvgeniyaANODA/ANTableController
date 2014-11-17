//
//  DTCellFactory.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
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

#import "DTTableViewFactory.h"
#import "DTModelTransfer.h"
#import "DTRuntimeHelper.h"

@interface DTTableViewFactory ()

@property (nonatomic,strong) NSMutableDictionary * cellMappingsDictionary;
@property (nonatomic,strong) NSMutableDictionary * headerMappingsDictionary;
@property (nonatomic,strong) NSMutableDictionary * footerMappingsDictionary;

@end

@implementation DTTableViewFactory

- (NSMutableDictionary *)cellMappingsDictionary
{
    if (!_cellMappingsDictionary)
        _cellMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _cellMappingsDictionary;
}

-(NSMutableDictionary *)headerMappingsDictionary
{
    if (!_headerMappingsDictionary)
        _headerMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _headerMappingsDictionary;
}

-(NSMutableDictionary *)footerMappingsDictionary
{
    if (!_footerMappingsDictionary)
        _footerMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _footerMappingsDictionary;
}

#pragma mark - class mapping

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    NSString * reuseIdentifier = [DTRuntimeHelper classStringForClass:cellClass];
    [[self.delegate tableView] registerClass:cellClass
                      forCellReuseIdentifier:reuseIdentifier];
    
    [self.cellMappingsDictionary setObject:[DTRuntimeHelper classStringForClass:cellClass]
                                    forKey:[DTRuntimeHelper modelStringForClass:modelClass]];
}

- (void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass
{
    NSAssert(([headerClass isSubclassOfClass:[UITableViewHeaderFooterView class]]), @"Class must be UITableViewHeaderFooterView object");
    [[self.delegate tableView] registerClass:headerClass
          forHeaderFooterViewReuseIdentifier:NSStringFromClass(headerClass)];
    
    [self.headerMappingsDictionary setObject:NSStringFromClass(headerClass)
                                      forKey:[DTRuntimeHelper modelStringForClass:modelClass]];
}


- (void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass
{
    NSAssert(([footerClass isSubclassOfClass:[UITableViewHeaderFooterView class]]), @"Class must be UITableViewHeaderFooterView object");
    [[self.delegate tableView] registerClass:footerClass
          forHeaderFooterViewReuseIdentifier:NSStringFromClass(footerClass)];
    
    [self.footerMappingsDictionary setObject:NSStringFromClass(footerClass)
                                      forKey:[DTRuntimeHelper modelStringForClass:modelClass]];
}

#pragma mark - View creation

- (UITableViewCell *)cellForModel:(id)model atIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseIdentifier = [self cellReuseIdentifierForModel:model];
    UITableViewCell <DTModelTransfer> * cell = [[self.delegate tableView] dequeueReusableCellWithIdentifier:reuseIdentifier
                                                                                               forIndexPath:indexPath];
    [cell updateWithModel:model];
    return cell;
}

- (UIView *)headerFooterViewForViewClass:(Class)viewClass
{
    NSString * reuseIdentifier = [DTRuntimeHelper classStringForClass:viewClass];
    UIView * view = [[self.delegate tableView] dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];

    return view;
}

- (UIView *)headerViewForModel:(id)model
{
    Class headerClass = [self headerClassForModel:model];
    
    UIView <DTModelTransfer> * view = (id)[self headerFooterViewForViewClass:headerClass];
    [view updateWithModel:model];

    return view;
}

- (UIView *)footerViewForModel:(id)model
{
    Class footerClass = [self footerClassForModel:model];
    
    UIView <DTModelTransfer> * view = (id)[self headerFooterViewForViewClass:footerClass];
    [view updateWithModel:model];
    
    return view;
}

- (NSString *)cellReuseIdentifierForModel:(id)model
{
    NSString* modelClassName = [DTRuntimeHelper modelStringForClass:[model class]];
    NSString* cellClassString = [self.cellMappingsDictionary objectForKey:modelClassName];
    NSAssert(cellClassString, @"DTCellFactory does not have cell mapping for model class: %@",[model class]);
    
    return cellClassString;
}

- (Class)headerClassForModel:(id)model
{
    NSString* modelClassName = [DTRuntimeHelper modelStringForClass:[model class]];
    NSString* headerClassString = [self.headerMappingsDictionary objectForKey:modelClassName];
    NSAssert(headerClassString, @"DTCellFactory does not have header mapping for model class: %@",[model class]);
    
    return NSClassFromString(headerClassString);
}

- (Class)footerClassForModel:(id)model
{
    NSString* modelClassName = [DTRuntimeHelper modelStringForClass:[model class]];
    NSString* footerClassString = [self.footerMappingsDictionary objectForKey:modelClassName];
    NSAssert(footerClassString, @"DTCellFactory does not have footer mapping for model class: %@",[model class]);
    
    return NSClassFromString(footerClassString);
}

@end
