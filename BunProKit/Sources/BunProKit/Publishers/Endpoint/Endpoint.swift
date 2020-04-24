//
//  Endpoint.swift
//  
//
//  Created by Andreas Braun on 26.02.20.
//

import Foundation

struct Endpoint {
    enum Version: String {
        case v3
        case v4
    }
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    let path: String
    let version: Version
    let queryItems: [URLQueryItem]?
    
    let httpMethod: HttpMethod
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "https://bunpro.jp"
        components.path = "/api/\(version.rawValue)/\(path)"
        components.queryItems = queryItems

        return components.url
    }
    
    var request: URLRequest? {
        guard let url = self.url else { return nil }
        
        var _request = URLRequest(url: url)
        _request.httpMethod = httpMethod.rawValue
        
        return _request
    }
}

extension Endpoint {
    static func login(email: String, password: String) -> Endpoint {
        let percentEscapedPassword: String = password.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
        return Endpoint(
            path: "login/",
            version: .v3,
            queryItems: [
                URLQueryItem(name: "user_login[email]", value: email),
                URLQueryItem(name: "user_login[password]", value: percentEscapedPassword)
            ],
            httpMethod: .post
        )
    }
}
