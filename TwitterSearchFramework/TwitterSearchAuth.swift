//
//  TwitterSearchAuth.swift
//  TwitterSearchFramework
//
//  Created by Einav Sitton on 04/01/2017.
//  Copyright © 2017 EinavSitton. All rights reserved.
//

import Foundation

class TwitterSearchAuth {
	private let oauthURL = "https://api.twitter.com/oauth2/token"
	private let searchURL = "https://api.twitter.com/1.1/search/tweets.json?q="
	private let consumerKey = "g56MQuGwq5W5WssAf2hE4etfj"
	private let consumerSecret = "sOMTzwPBNQJI9SG8JQzIWjF69IFQYrjrDVcO7Mv9XyoKFWzBfX"
	private let dataEncoding : String.Encoding = .utf8
	private var bearerToken : String?
	
	
	private func getBearerToken() -> String?
	{
		//step 1 - encode
		guard let escapedConsumerKey = self.consumerKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let escapedConsumerSecret = self.consumerSecret.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
		
		//step 2 - concat both with ':'
		let bearerToken = "\(escapedConsumerKey):\(escapedConsumerSecret)"
		
		//step 3 - bearer token base64 encoding
		if let base64Bearer = bearerToken.data(using: dataEncoding)?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) {
			print(base64Bearer)
		return base64Bearer
		}
		
		return nil
	}
	
	func postAuth(completionHanlder: @escaping ()->(), errorHandler: @escaping ()->()) {
		guard let url = URL(string: self.oauthURL) else { return }
		var request = URLRequest(url: url)
		
		request.setValue("Basic \(self.getBearerToken()!)", forHTTPHeaderField: "Authorization")
		request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
		request.httpBody = "grant_type=client_credentials".data(using: dataEncoding)
		request.httpMethod = "POST"
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let responseData = data, responseData.count > 0, let parsedDictionary = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
				if let tokenType = parsedDictionary?["token_type"] as? String, tokenType == "bearer", let accessToken = parsedDictionary?["access_token"] as? String {
					self.bearerToken = accessToken.data(using: self.dataEncoding)?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
					completionHanlder()
					return
				}
			}
			
			errorHandler()
		}.resume()
	}
	
	func search(searchString : String) {
		guard let encodedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
		guard let searchUrl = URL(string: "\(self.searchURL)\(encodedSearchString)") else { return }
		guard let bearerToken = self.bearerToken else { return }
		var searchRequest = URLRequest(url: searchUrl)
		searchRequest.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
		searchRequest.httpMethod = "GET"
		
		URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
			print(response)
			print(String(data: data!, encoding: self.dataEncoding))
		}.resume()
	}
	
	
}
