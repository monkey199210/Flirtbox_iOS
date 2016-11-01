import KeychainAccess
import Heimdallr

/// A persistent Keychain-based access token store.
@objc
public class ProtectedOAuthAccessTokenKeychainStore: NSObject, OAuthAccessTokenStore {
    private let keychain: Keychain
    
    /// Initializes a new Keychain-based access token store.
    ///
    /// - parameter service: The Keychain service.
    ///     Default: `de.flirtbox.heimdallr.oauth`.
    ///
    /// - returns: A new Keychain-based access token store initialized with the
    ///     the given service.
    private let lockQueue = dispatch_queue_create("de.flirtbox.heimdallr.oauth.AuthLockQueue", nil)
    public init(service: String = "de.flirtbox.heimdallr.oauth") {
        keychain = Keychain(service: service)
    }
    
    public func storeAccessToken(accessToken: OAuthAccessToken?) {
        dispatch_sync(lockQueue) {
            self.keychain["access_token"] = accessToken?.accessToken
            self.keychain["token_type"] = accessToken?.tokenType
            self.keychain["expires_at"] = accessToken?.expiresAt?.timeIntervalSince1970.description
            self.keychain["refresh_token"] = accessToken?.refreshToken
        }
    }
    
    public func retrieveAccessToken() -> OAuthAccessToken? {
        var accessToken: String?
        var tokenType: String?
        var refreshToken: String?
        dispatch_sync(lockQueue) {
            accessToken = self.keychain["access_token"]
            tokenType = self.keychain["token_type"]
            refreshToken = self.keychain["refresh_token"]
        }
        
        var expiresAt: NSDate?
        if let expiresAtInSeconds = keychain["expires_at"] as NSString? {
            expiresAt = NSDate(timeIntervalSince1970: expiresAtInSeconds.doubleValue)
        }
        
        if let accessToken = accessToken {
            if let tokenType = tokenType {
                return OAuthAccessToken(
                    accessToken: accessToken,
                    tokenType: tokenType,
                    expiresAt: expiresAt,
                    refreshToken: refreshToken)
            }
        }
        
        return nil
    }
}
