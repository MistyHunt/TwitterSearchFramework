//
//  TwitterSearchAuth.swift
//  TwitterSearchFramework
//
//  Created by Einav Sitton on 04/01/2017.
//  Copyright © 2017 EinavSitton. All rights reserved.
//

import Foundation

class TwitterSearchAuth {
	
	let consumerKey = "zQLWA4nEkMCeFEaa5XBYmMh83"
	let consumerSecret = "PuIEr5v4ADFMJZZNfjX8V4rn1COjiOaXGaniW5a4FJfIwK8MPC"
	let dataEncoding : String.Encoding = .utf8
	
	
	func getBearerToken() -> String?
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
	
	func postAuth() {
		guard let url = URL(string: "https://api.twitter.com/oauth2/token") else { return }
		var request = URLRequest(url: url)
		request.setValue("Basic \(self.getBearerToken()!)", forHTTPHeaderField: "Authorization")
		request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
		request.httpBody = "grant_type=client_credentials".data(using: dataEncoding)
		request.httpMethod = "POST"
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			print(response)
			print(String(data: data!, encoding: self.dataEncoding))
		}.resume()
	}
}
