/**
*  ServerCrypto
*  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
*/

import Foundation
import CTLS

/**
* A key of an asymmetric signature key pair, such as an ECDSA or an RSA key pair. Can represent
* either a public or a private key.
*/

public enum AsymmetricKey {
	
	/// A public key used for signature verification.
	case publicKey(EVPKeyContainer)
	
	/// A private key used for signing.
	case privateKey(EVPKeyContainer)
	
	/// The instance containing the raw EVP_PKEY pointer.
	public var keyContainer: EVPKeyContainer {
		
		switch self {
		case .publicKey(let container):
			return container
		case .privateKey(let container):
			return container
		}
		
	}
	
	//Only expose public key component
	public var keyData: Data {
		switch self {
		case .publicKey(let container):
			return container.keyData
		case .privateKey:
			return Data()
		}
	}
	
}

/**
* An object that contains an EVP_PKEY pointer and deallocates it on disposal.
* Modified on 13.4.2018 by @vkoskiv - Expose public key as Data()
*/

public class EVPKeyContainer {
	
	/// The pointer to the raw EVP_PKEY wrapped by the instance.
	public let underlyingKeyPointer: UnsafeMutablePointer<EVP_PKEY>
	
	public init(wrapping underlyingKeyPointer: UnsafeMutablePointer<EVP_PKEY>) {
		self.underlyingKeyPointer = underlyingKeyPointer
	}
	
	public var keyData: Data {
		return pubKeyToData(key: underlyingKeyPointer)
	}
	
	func pubKeyToData(key: UnsafeMutablePointer<EVP_PKEY>) -> Data {
		let count = i2d_PublicKey(key, nil)
		//var ptr: UnsafeMutablePointer<UInt8>? = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(count))
		let ptr = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 1)
		i2d_PublicKey(key, &ptr.pointee)
		//Get data
		let data = Data(bytes: ptr.pointee!, count: Int(count))
		//Then deallocate ptr
		free(ptr)
		return data
	}
	
	deinit {
		EVP_PKEY_free(underlyingKeyPointer)
	}
	
}

// MARK: - Public Key Factories

extension AsymmetricKey {
	
	/**
	* Create a public key by reading its PEM-encoded version on disk.
	* - parameter path: The path to the key to read.
	* - throws: In case of failure, this factory method throws a `CryptoError` object.
	* - returns: The public key associated with its OpenSSL representation.
	*/
	
	public static func makePublicKey(readingPEMAtPath path: String) throws -> AsymmetricKey {
		let keyBio = try self.readBio(at: path)
		return try makePublicKey(reading: keyBio)
	}
	
	/**
	* Create a public key by reading its PEM-encoded version in memory.
	* - parameter data: The data buffer containing the PEM key to read.
	* - throws: In case of failure, this factory method throws a `CryptoError` object.
	* - returns: The public key associated with its OpenSSL representation.
	*/
	
	public static func makePublicKey(readingPEMData data: Data) throws -> AsymmetricKey {
		let keyBio = try self.readBio(in: data)
		return try makePublicKey(reading: keyBio)
	}
	
	private static func makePublicKey(reading keyBio: UnsafeMutablePointer<BIO>) throws -> AsymmetricKey {
		
		guard let pubKey = PEM_read_bio_PUBKEY(keyBio, nil, nil, nil) else {
			throw CryptoError.latest
		}
		
		let container = EVPKeyContainer(wrapping: pubKey)
		return .publicKey(container)
		
	}
	
}

// MARK: - Private Key Factories

extension AsymmetricKey {
	
	/**
	* Create a private key by reading its PEM-encoded version on disk.
	* - parameter path: The path to the key to read.
	* - parameter passphrase: The passphrase of the key, if it is encrypted.
	* - throws: In case of failure, this factory method throws a `CryptoError` object.
	* - returns: The private key associated with its OpenSSL representation.
	*/
	
	public static func makePrivateKey(readingPEMAtPath path: String, passphrase: String?) throws -> AsymmetricKey {
		let keyBio = try self.readBio(at: path)
		return try makePrivateKey(reading: keyBio, passphrase: passphrase)
	}
	
	/**
	* Create a private key by reading its PEM-encoded version in memory.
	* - parameter data: The data buffer containing the PEM key to read.
	* - parameter passphrase: The passphrase of the key, if it is encrypted.
	* - throws: In case of failure, this factory method throws a `CryptoError` object.
	* - returns: The public key associated with its OpenSSL representation.
	*/
	
	public static func makePrivateKey(readingPEMData data: Data, passphrase: String?) throws -> AsymmetricKey {
		let keyBio = try self.readBio(in: data)
		return try makePrivateKey(reading: keyBio, passphrase: passphrase)
	}
	
	private static func makePrivateKey(reading keyBio: UnsafeMutablePointer<BIO>, passphrase: String?) throws -> AsymmetricKey {
		
		let passphraseBytes = passphrase?.withCString { UnsafeMutableRawPointer(mutating: $0) }
		
		guard let pkey = PEM_read_bio_PrivateKey(keyBio, nil, { AsymmetricKey.password_cb($0, $1, $2, $3) }, passphraseBytes) else {
			throw CryptoError.latest
		}
		
		let container = EVPKeyContainer(wrapping: pkey)
		return .privateKey(container)
		
	}
	
}

// MARK: - Utilities

extension AsymmetricKey {
	
	static func readBio(at path: String) throws -> UnsafeMutablePointer<BIO> {
		
		CryptoProvider.load(.digests, .ciphers, .cryptoErrorStrings)
		
		guard let bio = BIO_new_file(path, "r") else {
			throw CryptoError.latest
		}
		
		return bio
		
	}
	
	static func readBio(in pemData: Data) throws -> UnsafeMutablePointer<BIO> {
		
		CryptoProvider.load(.digests, .ciphers, .cryptoErrorStrings)
		
		let optionalBio = pemData.withUnsafeRawBytes {
			BIO_new_mem_buf($0, Int32(pemData.count))
		}
		
		guard let bio = optionalBio else {
			throw CryptoError.latest
		}
		
		return bio
		
	}
	
	static func password_cb(_ buf: UnsafeMutablePointer<Int8>?, _ bufferSize: Int32, _ rwflag: Int32, _ password: UnsafeMutableRawPointer?) -> Int32 {
		
		guard buf != nil else {
			return 0
		}
		
		guard password != nil else {
			strcpy(buf!, "")
			return 0
		}
		
		let ptr = password!.assumingMemoryBound(to: Int8.self)
		
		var n = Int32(strlen(ptr))
		
		if n >= bufferSize {
			n = bufferSize - 1
		}
		
		memcpy(buf!, password!, Int(n))
		
		return n
		
	}
	
}

