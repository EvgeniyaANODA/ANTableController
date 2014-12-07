//
//  DTSectionModel+SectionHeadersFooters.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel.h"
#import "DTMemoryStorage+ANTableController.h"
#import "DTMemoryStorage.h"

/**
 Category, providing getters and setters for section headers and footers
 */
@interface DTSectionModel (SectionHeadersFooters)

- (id)tableHeaderModel;
- (id)tableFooterModel;

- (void)setTableSectionHeader:(id)headerModel;
- (void)setTableSectionFooter:(id)footerModel;

@end
