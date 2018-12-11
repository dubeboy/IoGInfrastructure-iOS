/*******************************************************************************
* IoGDataManager.swift
*
* Title:			IoG Infrastructure
* Description:		IoG Mobile App Infrastructure Framework
*						This file contains the base class for the manager for
*						retrieving remote data
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	09/27/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation

protocol IoGDataManagerDelegate : class
{
	func dataRequestResponseReceived(requestID: Int, requestType: IoGDataManager.IoGDataRequestType, responseData: Data?, error: Error?, response: IoGDataRequestResponse)
}

class IoGDataManager
{

	enum IoGDataManagerType
	{
		case IoGDataManagerTypeLive
		case IoGDataManagerTypeMock
	}

	enum IoGDataRequestType
	{
		case Register
		case Login
	}

	private static var sharedManager : IoGDataManager!

	var delegateList = NSPointerArray.weakObjects()
	var outstandingRequests = [Int: IoGDataRequestResponse]()
	var requestID = 0

	// MARK: Class Methods

	class func dataManagerOfType(type: IoGDataManagerType) -> IoGDataManager
	{
		switch (type)
			{
			case .IoGDataManagerTypeLive:
				if sharedManager == nil || !(sharedManager is IoGLiveDataManager)
					{
					sharedManager = IoGLiveDataManager()
					}
			case .IoGDataManagerTypeMock:
				if sharedManager == nil || !(sharedManager is IoGMockDataManager)
					{
					sharedManager = IoGMockDataManager()
					}
			}
		return sharedManager
	}

	class func dataManagerOfDefaultType() -> IoGDataManager
	{
		return IoGDataManager.dataManagerOfType(type: IoGConfigurationManager.defaultDataManagerType)
	}

	// MARK: Instance Methods

	init()
	{
	}

	func registerDelegate(delegate: IoGDataManagerDelegate)
	{
		for nextDelegate in delegateList.allObjects
			{
			let del = nextDelegate as! IoGDataManagerDelegate
			if del === delegate
				{
				return
				}
			}
		let pointer = Unmanaged.passUnretained(delegate as AnyObject).toOpaque()
		delegateList.addPointer(pointer)
	}

	func unregisterDelegate(delegate: IoGDataManagerDelegate)
	{
		var index = 0
		for nextDelegate in delegateList.allObjects
			{
			let del = nextDelegate as! IoGDataManagerDelegate
			if del === delegate
				{
				break
				}
			index += 1
			}
		if index < delegateList.count
			{
			delegateList.removePointer(at: index)
			}
	}

	// MARK: "Abstract" Client Methods to be overridden

	@discardableResult func transmitRequest(request: URLRequest, type: IoGDataRequestType) -> Int?
	{
		return nil
	}

	func continueMultiPartRequest(multiPartResponse: IoGDataRequestResponse)
	{
	}
}