/*******************************************************************************
* LiveDataManager.swift
*
* Title:			IoG Infrastructure
* Description:		IoG Mobile App Infrastructure Framework
*						This file contains the live implementation of the class
*						for the manager for retrieving remote data
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	10/01/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation

class LiveDataManager : DataManager
{

	// MARK: Business Logic

	@discardableResult override func transmitRequest(request: URLRequest, type: DataRequestType) -> Int?
	{
		let reqID = requestID
		let requestResponse = DataRequestResponse(withRequestID: reqID, type: type, request: request, callback: dataRequestResponse)
		outstandingRequests[reqID] = requestResponse
		requestID += 1
		requestResponse.processRequest()
		return reqID
	}

	override func continueMultiPartRequest(multiPartResponse: DataRequestResponse)
	{
		multiPartResponse.continueMultiPartRequest()
	}

	// MARK: Data Request Callback

	func dataRequestResponse(_ response: DataRequestResponse)
	{
		delegateList.compact()
		for nextDelegate in delegateList.allObjects
			{
			let delegate = nextDelegate as! DataManagerDelegate
			let responseData = response.responseData
			if let responseInfo = response.responseInfo, let err = responseInfo[IoGConfigurationManager.requestResponseKeyError] as? Error
				{
				delegate.dataRequestResponseReceived(requestID: response.requestID, requestType: response.getRequestInfo()[IoGConfigurationManager.requestResponseKeyRequestType] as! DataManager.DataRequestType, responseData: responseData, error: err, response: response)
				}
			else
				{
				delegate.dataRequestResponseReceived(requestID: response.requestID, requestType: response.getRequestInfo()[IoGConfigurationManager.requestResponseKeyRequestType] as! DataManager.DataRequestType, responseData: responseData, error: nil, response: response)
				}
			}
	}
}
