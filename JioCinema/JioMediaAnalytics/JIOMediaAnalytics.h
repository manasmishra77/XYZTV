/*
 File: JIOMediaAnalytics.h
 Abstract: Library API File, which application can integrate with library.
 Version: 0.9.18
 Date: 18 July 2016
 Disclaimer: IMPORTANT:  This RJIL software is supplied to you by RJIL in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this RJIL software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this RJIL software.
 The RJIL Software is provided by RJIL on an "AS IS" basis.  RJIL MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE RJIL SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 IN NO EVENT SHALL RJIL BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE RJIL SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF RJIL HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 Copyright (C) 2014 Reliance Jio Infocomm Ltd. All Rights Reserved.
 Program Head        : Mukesh.D.Jain@ril.com
 Program Manager : Sourabh.Jain@ril.com
 
 */

#import <Foundation/Foundation.h>

@protocol JIOMediaAnalyticsDelegate <NSObject>

- (void)displayLog:(NSString *)log;

@end

@interface JIOMediaAnalytics : NSObject

@property (nonatomic, unsafe_unretained) id <JIOMediaAnalyticsDelegate> delegate;
@property (nonatomic, strong) NSString *libraryName;
@property (nonatomic, strong) NSString *libraryVersion;
@property (nonatomic, strong) NSString *serverURL;

+ (JIOMediaAnalytics *)sharedInstance;

- (void)initializeSessionWithServerName : (NSString *) serverName
                     appRegistrationKey : (NSString *) applicationKey
                                 userID : (NSString *) userId
                  onlineTimeOutInMinute : (double) onlineTimeOutInMinute
                       clearHistoryDays : (NSInteger) clearHistoryDays
                       environmentType  : (NSString *)environmentType
                    idleTimeOutInMinute : (double) idleTimeOutInMinute;

- (void)recordPriorityEventWithName:(NSString *)eventName properties:(NSDictionary *)properties;

- (void)startSessionWithUserID : (NSString *) userId idamIdentifier:(NSString *)idamIdentifier crmIdentifier:(NSString *)crmIdentifier profileIdentifier:(NSString *)profileIdentifier;

- (void)recordEventWithEventName:(NSString *)eventName andEventProperties:(NSDictionary *)eventProperties;

- (void)handleCrashLogsWithExceptionName:(NSString *)exceptionName callStackSymbols:(NSArray *)callStackSymbols andReason:(NSString *)reason;

- (void)endSession;

void JioMeidaAnalyticsUncaughtExceptionHandler(NSException * exception);

@end
