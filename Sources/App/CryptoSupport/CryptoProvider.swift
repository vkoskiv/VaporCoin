/**
 *  ServerCrypto
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import CTLS

/**
 * An object that loads components from OpenSSL on demand.
 */

public class CryptoProvider {

    public enum Component: Int {

        /// The OpenSSL digests.
        case digests

        /// The OpenSSL ciphers.
        case ciphers

        /// The error descriptions for the Crypto APIs.
        case cryptoErrorStrings

        /// Loads the component.
        func load() {

            switch self {
            case .digests: OpenSSL_add_all_digests()
            case .ciphers: OpenSSL_add_all_ciphers()
            case .cryptoErrorStrings: ERR_load_crypto_strings()
            }

        }

    }

    private static var loadedComponents: Set<Component> = []

    /**
     * Loads the specified OpenSSL components if they are not already loaded.
     *
     * - parameter components: The components to load.
     */

    public static func load(_ components: Component...) {

        for component in components {

            guard !loadedComponents.contains(component) else {
                continue
            }

            component.load()
            loadedComponents.insert(component)

        }

    }

}
