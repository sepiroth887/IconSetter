//
//  main.m
//  IconSetter
//
//  Created by Tobias Haag on 16/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@interface IconManager : NSObject

- (NSImage*) getBadgeForState: (NSString*) state AndIconPath: (NSString*) path;
- (NSImage*) getIconWithBadge: (NSImage*)icon AndState: (NSString*)state AndIconPath:(NSString*) path;
- (NSImage*) getCurrentIcon: (NSString*) file;

- (BOOL) setIconForFile: (NSString*) file AndIconPath: (NSString*) path AndState: (NSString*) state;

- (BOOL) replaceIconOfFile: (NSString*) file AndImageFile: (NSString*) imageFile;
@end

@implementation IconManager{
    
}

- (BOOL) replaceIconOfFile:(NSString *)file AndImageFile:(NSString *)imageFile{
    
    if([[NSFileManager defaultManager] fileExistsAtPath:imageFile]){
        NSImage *newIcon = [[NSImage new] initWithContentsOfFile:imageFile];
        
        [[NSWorkspace sharedWorkspace] setIcon:newIcon forFile:file options:0];

        [newIcon release];
         return YES;
    }
         
         return NO;
    
    
}

- (BOOL) setIconForFile:(NSString *)file AndIconPath:(NSString *)path AndState:(NSString *)state{
    
    NSImage* oldIcon = [self getCurrentIcon:file];
    
    NSImage *finalIcon = [self getIconWithBadge: oldIcon AndState: state
                                  AndIconPath:path];
    
    
    if(finalIcon == nil) return NO;
    
    [[NSWorkspace sharedWorkspace] setIcon:finalIcon forFile:file options:0];
    
    return YES;
}

- (NSImage*) getCurrentIcon:(NSString *)file{

    if(![[NSFileManager defaultManager] fileExistsAtPath:file]) return nil;

    [[NSWorkspace sharedWorkspace] setIcon:nil forFile:file options:0];
    NSImage *iconImg = [[NSWorkspace sharedWorkspace] iconForFile:file];
    
    [iconImg setScalesWhenResized:YES];
    
    NSImageRep *biggestRep = [[iconImg representations] objectAtIndex:0];
    
    
    [iconImg setSize:NSMakeSize(biggestRep.size.width,biggestRep.size.height)];
    
    return iconImg;
}

- (NSImage*) getBadgeForState: (NSString*) state AndIconPath: (NSString*) path{
    NSString *badge = [NSString alloc];

    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        return nil;
    }

    if([@"notSynced" isEqualToString:state]){
        badge = [path stringByAppendingString:@"/notSynced.png"];
    }else if([@"synced" isEqualToString:state]){
        badge = [path stringByAppendingString:@"/synced.png"];
    }else if([@"syncing" isEqualToString:state]){
        badge = [path stringByAppendingString:@"/syncing.png"];
    }

    if(badge == nil || ![[NSFileManager defaultManager] fileExistsAtPath:badge]) return nil;

    NSImage *badgeImg = [[[NSImage new] initWithContentsOfFile:badge] autorelease];

    [badge release];

    return badgeImg;
    
}


- (NSImage*) getIconWithBadge: (NSImage*)icon AndState: (NSString*)state AndIconPath:(NSString*) path
{
    
    NSImage *badge = [self getBadgeForState:state AndIconPath:path];
    
    if(badge == nil) return nil;
    
    NSSize newBadgeSize = NSMakeSize(icon.size.width/2, icon.size.height/2);
    
    [badge setSize:newBadgeSize];

    [icon lockFocus];
    [badge drawInRect:NSMakeRect(icon.size.width - badge.size.width, 0, badge.size.width, badge.size.height) 
             fromRect:NSZeroRect 
             operation:NSCompositeSourceOver
             fraction:1.0];
    [icon unlockFocus];

    return icon;
}

@end


int main(int argc, const char * argv[])
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSString *file;
    NSString *iconPath;
    
        if(argc == 4){
        
        
            file = [NSString stringWithUTF8String:argv[1]];
            iconPath = [NSString stringWithUTF8String:argv[2]];
            NSString *state = [NSString stringWithUTF8String:argv[3]];
            
        //NSLog(@"filename: %@ icon: %@",file,icon);
        
        
            if([[[IconManager new] autorelease] setIconForFile:file AndIconPath:iconPath AndState:state]){
                return 0;
            }else{
                printf("Icon could not be set\n");
                exit(3);
            
            }
            
        }else if(argc == 3){
            
            if(strcmp(argv[1], "-r") == 0){
                
                file = [NSString stringWithUTF8String:argv[2]];
                
                if([[NSFileManager defaultManager]fileExistsAtPath:file]){
                    [[NSWorkspace sharedWorkspace] setIcon:nil forFile:file options:0];
                    [pool release];
                    return 0;
                }else{
                    printf("File not found: %s\n",argv[2]);
                    exit(4);
                }

            }else{
                file = [NSString stringWithUTF8String:argv[1]];
                iconPath = [NSString stringWithUTF8String:argv[2]];
                
                if([[NSFileManager defaultManager] fileExistsAtPath:file] && [[NSFileManager defaultManager] fileExistsAtPath:iconPath]){
                    
                    if([[[IconManager new] autorelease] replaceIconOfFile:file AndImageFile:iconPath]){
                        [pool release];
                        return 0;
                    }else{
                        printf("Could not set new icon\n");
                        exit(3);
                    }
                }else{
                    printf("File not found!\n");
                    exit(4);
                }
                
                
            }
        }else{
            printf("Usage: IconSetter < < -r > <pathToFile> > | < <pathToFile> <pathToImage> > | \n\t< <pathToFile> <pathToIcons> <state> > \n\n ");
            printf("pathToFile : name of the file to change the icon for\n");
            printf("-r : remove the current icon from the given file and revert to default\n");                  
            printf("pathToImage : name of the image file to replace the icon with\n");
            printf("pathToIcons : location of the icons for individual states\n");
            printf("state : state of the file: synced,notSynced,syncing\n");
            exit(1);
        }
}


