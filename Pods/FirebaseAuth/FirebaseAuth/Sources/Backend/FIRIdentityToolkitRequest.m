/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FirebaseAuth/Sources/Backend/FIRIdentityToolkitRequest.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kFirebaseAuthAPIURLFormat =
    @"https://%@/identitytoolkit/v3/relyingparty/%@?key=%@";
static NSString *const kIdentityPlatformAPIURLFormat = @"https://%@/v2/%@?key=%@";

static NSString *gAPIHost = @"www.googleapis.com";

static NSString *kFirebaseAuthAPIHost = @"www.googleapis.com";
static NSString *kIdentityPlatformAPIHost = @"identitytoolkit.googleapis.com";

static NSString *kFirebaseAuthStagingAPIHost = @"staging-www.sandbox.googleapis.com";
static NSString *kIdentityPlatformStagingAPIHost =
    @"staging-identitytoolkit.sandbox.googleapis.com";

@implementation FIRIdentityToolkitRequest {
  FIRAuthRequestConfiguration *_requestConfiguration;

  BOOL _useIdentityPlatform;

  BOOL _useStaging;
}

- (nullable instancetype)initWithEndpoint:(NSString *)endpoint
                     requestConfiguration:(FIRAuthRequestConfiguration *)requestConfiguration {
  self = [super init];
  if (self) {
    _APIKey = [requestConfiguration.APIKey copy];
    _endpoint = [endpoint copy];
    _requestConfiguration = requestConfiguration;
    _useIdentityPlatform = NO;
    _useStaging = NO;
  }
  return self;
}

- (nullable instancetype)initWithEndpoint:(NSString *)endpoint
                     requestConfiguration:(FIRAuthRequestConfiguration *)requestConfiguration
                      useIdentityPlatform:(BOOL)useIdentityPlatform
                               useStaging:(BOOL)useStaging {
  self = [self initWithEndpoint:endpoint requestConfiguration:requestConfiguration];
  if (self) {
    _useIdentityPlatform = useIdentityPlatform;
    _useStaging = useStaging;
  }
  return self;
}

- (BOOL)containsPostBody {
  return YES;
}

- (NSURL *)requestURL {
  NSString *apiURLFormat;
  NSString *apiHost;
  if (_useIdentityPlatform) {
    apiURLFormat = kIdentityPlatformAPIURLFormat;
    if (_useStaging) {
      apiHost = kIdentityPlatformStagingAPIHost;
    } else {
      apiHost = kIdentityPlatformAPIHost;
    }
  } else {
    apiURLFormat = kFirebaseAuthAPIURLFormat;
    if (_useStaging) {
      apiHost = kFirebaseAuthStagingAPIHost;
    } else {
      apiHost = kFirebaseAuthAPIHost;
    }
  }
  NSString *URLString = [NSString stringWithFormat:apiURLFormat, apiHost, _endpoint, _APIKey];
  NSURL *URL = [NSURL URLWithString:URLString];
  return URL;
}

- (FIRAuthRequestConfiguration *)requestConfiguration {
  return _requestConfiguration;
}

#pragma mark - Internal API for development

+ (NSString *)host {
  return gAPIHost;
}

+ (void)setHost:(NSString *)host {
  gAPIHost = host;
}

NS_ASSUME_NONNULL_END

@end