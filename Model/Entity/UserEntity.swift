//
//  UserEntity.swift
//  DeHub
//
//  Created by Kalle Lindström on 19/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import Gloss

public struct UserEntity : Decodable {
  
  public let username: String
  public let name: String?
  public let id: Int
  public let avatarUrl: String?
  public let publicRepos: Int
  public let publicGists: Int
  public let following: Int
  public let followers: Int
  
  public init?(json: JSON) {
    guard let
      username: String = "login" <~~ json,
      id: Int = "id" <~~ json,
    	publicRepos: Int = "public_repos" <~~ json,
    	publicGists: Int = "public_gists" <~~ json,
    	following: Int = "following" <~~ json,
    	followers: Int = "followers" <~~ json

    else { return nil }
    
    self.username = username
    self.id = id
    self.name = "name" <~~ json
    self.publicRepos = publicRepos
    self.publicGists = publicGists
    self.avatarUrl = "avatar_url" <~~ json
    self.followers = followers
    self.following = following
  }
}

/*
 
 {
 "login": "octocat",
 "id": 1,
 "avatar_url": "https://github.com/images/error/octocat_happy.gif",
 "gravatar_id": "",
 "url": "https://api.github.com/users/octocat",
 "html_url": "https://github.com/octocat",
 "followers_url": "https://api.github.com/users/octocat/followers",
 "following_url": "https://api.github.com/users/octocat/following{/other_user}",
 "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
 "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
 "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
 "organizations_url": "https://api.github.com/users/octocat/orgs",
 "repos_url": "https://api.github.com/users/octocat/repos",
 "events_url": "https://api.github.com/users/octocat/events{/privacy}",
 "received_events_url": "https://api.github.com/users/octocat/received_events",
 "type": "User",
 "site_admin": false,
 "name": "monalisa octocat",
 "company": "GitHub",
 "blog": "https://github.com/blog",
 "location": "San Francisco",
 "email": "octocat@github.com",
 "hireable": false,
 "bio": "There once was...",
 "public_repos": 2,
 "public_gists": 1,
 "followers": 20,
 "following": 0,
 "created_at": "2008-01-14T04:33:35Z",
 "updated_at": "2008-01-14T04:33:35Z",
 "total_private_repos": 100,
 "owned_private_repos": 100,
 "private_gists": 81,
 "disk_usage": 10000,
 "collaborators": 8,
 "plan": {
 "name": "Medium",
 "space": 400,
 "private_repos": 20,
 "collaborators": 0
 }
 }
 
 */