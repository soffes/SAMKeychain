//
//  KeychainTests.swift
//  SSKeychain
//
//  Created by Sam Soffes on 3/10/16.
//  Copyright © 2010-2016 Sam Soffes. All rights reserved.
//

import XCTest
import SSKeychain

class KeychainTests: XCTestCase {

	// MARK: - Properties

	let testService = "SSToolkitTestService"
	let testAccount = "SSToolkitTestAccount"
	let testPassword = "SSToolkitTestPassword"
	let testLabel = "SSToolkitLabel"


	// MARK: - XCTestCase

	override func tearDown() {
		SSKeychain.deletePasswordForService(testService, account: testAccount)
		super.tearDown()
	}


	// MARK: - Tests

	func testNewItem() {
		// New item
		let newQuery = SSKeychainQuery()
		newQuery.password = testPassword
		newQuery.service = testService
		newQuery.account = testAccount
		newQuery.label = testLabel
		try! newQuery.save()

		// Look up
		let lookupQuery = SSKeychainQuery()
		lookupQuery.service = testService
		lookupQuery.account = testAccount
		try! lookupQuery.fetch()

		XCTAssertEqual(newQuery.password, lookupQuery.password)

		// Search for all accounts
		let allQuery = SSKeychainQuery()
		var accounts = try! allQuery.fetchAll()
		XCTAssertTrue(self.accounts(accounts, containsAccountWithName: testAccount), "Matching account was not returned")

		// Check accounts for service
		allQuery.service = testService
		accounts = try! allQuery.fetchAll()
		XCTAssertTrue(self.accounts(accounts, containsAccountWithName: testAccount), "Matching account was not returned")

		// Delete
		let deleteQuery = SSKeychainQuery()
		deleteQuery.service = testService
		deleteQuery.account = testAccount
		try! deleteQuery.deleteItem()
	}

	func testPasswordObject() {
		let newQuery = SSKeychainQuery()
		newQuery.service = testService
		newQuery.account = testAccount

		let dictionary: [String: NSObject] = [
			"number": 42,
			"string": "Hello World"
		]

		newQuery.passwordObject = dictionary
		try! newQuery.save()

		let lookupQuery = SSKeychainQuery()
		lookupQuery.service = testService
		lookupQuery.account = testAccount
		try! lookupQuery.fetch()

		let readDictionary = lookupQuery.passwordObject as! [String: NSObject]
		XCTAssertEqual(dictionary, readDictionary)
	}

	func testCreateWithMissingInformation() {
		var query = SSKeychainQuery()
		query.service = testService
		query.account = testAccount
		XCTAssertThrowsError(try query.save())

		query = SSKeychainQuery()
		query.account = testAccount
		query.password = testPassword
		XCTAssertThrowsError(try query.save())

		query = SSKeychainQuery()
		query.service = testService
		query.password = testPassword
		XCTAssertThrowsError(try query.save())
	}

	func testDeleteWithMissingInformation() {
		var query = SSKeychainQuery()
		query.account = testAccount
		XCTAssertThrowsError(try query.deleteItem())

		query = SSKeychainQuery()
		query.service = testService
		XCTAssertThrowsError(try query.deleteItem())

		query = SSKeychainQuery()
		query.account = testAccount
		XCTAssertThrowsError(try query.deleteItem())
	}

	func testFetchWithMissingInformation() {
		var query = SSKeychainQuery()
		query.account = testAccount
		XCTAssertThrowsError(try query.fetch())

		query = SSKeychainQuery()
		query.service = testService
		XCTAssertThrowsError(try query.fetch())
	}

	func testSynchronizable() {
		let createQuery = SSKeychainQuery()
		createQuery.service = testService
		createQuery.account = testAccount
		createQuery.password = testPassword
		createQuery.synchronizationMode = .Yes
		try! createQuery.save()

		let noFetchQuery = SSKeychainQuery()
		noFetchQuery.service = testService
		noFetchQuery.account = testAccount
	    noFetchQuery.synchronizationMode = .No
		XCTAssertThrowsError(try noFetchQuery.fetch())
		XCTAssertNotEqual(createQuery.password, noFetchQuery.password)

		let anyFetchQuery = SSKeychainQuery()
		anyFetchQuery.service = testService
		anyFetchQuery.account = testAccount
		anyFetchQuery.synchronizationMode = .Any
		try! anyFetchQuery.fetch()
		XCTAssertEqual(createQuery.password, anyFetchQuery.password)
	}

	func testConvenienceMethods() {
		// Create a new item
		SSKeychain.setPassword(testPassword, forService: testService, account: testAccount)

		// Check password
		XCTAssertEqual(testPassword, SSKeychain.passwordForService(testService, account: testAccount))

		// Check all accounts
		XCTAssertTrue(accounts(SSKeychain.allAccounts(), containsAccountWithName: testAccount))

		// Check account
		XCTAssertTrue(accounts(SSKeychain.accountsForService(testService), containsAccountWithName: testAccount))

		#if !os(OSX)
			SSKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
			XCTAssertEqual(String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly), String(SSKeychain.accessibilityType().takeRetainedValue()))
		#endif
	}

	func testUpdateAccessibilityType() {
		SSKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)

		// Create a new item
		SSKeychain.setPassword(testPassword, forService: testService, account: testAccount)

		// Check all accounts
		XCTAssertTrue(accounts(SSKeychain.allAccounts(), containsAccountWithName: testAccount))

		// Check account
		XCTAssertTrue(accounts(SSKeychain.accountsForService(testService), containsAccountWithName: testAccount))

		SSKeychain.setAccessibilityType(kSecAttrAccessibleAlwaysThisDeviceOnly)
		SSKeychain.setPassword(testPassword, forService: testService, account: testAccount)

		// Check all accounts
		XCTAssertTrue(accounts(SSKeychain.allAccounts(), containsAccountWithName: testAccount))

		// Check account
		XCTAssertTrue(accounts(SSKeychain.accountsForService(testService), containsAccountWithName: testAccount))
	}
	

	// MARK: - Private

	private func accounts(accounts: [[String: AnyObject]], containsAccountWithName name: String) -> Bool {
		for account in accounts {
			if let acct = account["acct"] as? String where acct == name {
				return true
			}
		}

		return false
	}
}
