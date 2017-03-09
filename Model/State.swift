//
//  State.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-01-23.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation
import RxSwift

fileprivate let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

fileprivate var marshalClosures = [() -> Void]()
fileprivate var unmarshalClosures = [() -> Void]()

fileprivate func cacheUrl(forFilename filename: String) -> URL {
  return URL(fileURLWithPath: documentsPath + "/" + filename)
}

public final class State {
  
  let _gists = Variable<[GistEntity]>([]).persist(filename: "gists.cache")
  public let gists: Observable<[GistEntity]>
  
  init() {
    gists = _gists.asObservable()
  }
  
  public func persistToDisk() {
    for marshal in marshalClosures {
      marshal()
    }
  }
  
  public func restoreFromDisk() {
    for unmarshal in unmarshalClosures {
      unmarshal()
    }
  }
}

// MARK: Marshalling

fileprivate extension Variable {
  
  func archive() -> Data? {
    if let archivable = value as? Archivable {
      return archivable.archive()
    }
    
    if let archivableArray = value as? [Archivable] {
      let dataArray = archivableArray.map { $0.archive() }
      return NSKeyedArchiver.archivedData(withRootObject: dataArray)
    }
    
    return nil
  }
  
  func write(data: Data, to fileUrl: URL) {
    do {
      try data.write(to: fileUrl)
    } catch let e {
      print("Error writing data to \(fileUrl)")
      print(e)
    }
  }
}

fileprivate extension Variable where Element: Archivable {
  
  func persist(filename: String) -> Variable<Element> {
    marshalClosures.append {
      guard let data = self.archive() else { fatalError("Variable value cannot be archived") }
      let fileUrl = cacheUrl(forFilename: filename)
      self.write(data: data, to: fileUrl)
    }
    unmarshalClosures.append {
      guard let data = try? Data(contentsOf: cacheUrl(forFilename: filename)) else {
        print("Could not read data for file `\(filename)`")
        return
      }
      self.value = Element.init(data: data)
    }
    return self
  }
}

fileprivate extension Variable where Element: Collection, Element.Iterator.Element: Archivable {
  
  func persist(filename: String) -> Variable<Element> {
    marshalClosures.append {
      guard let data = self.archive() else { fatalError("Variable value cannot be archived") }
      let fileUrl = cacheUrl(forFilename: filename)
      self.write(data: data, to: fileUrl)
    }
    unmarshalClosures.append {
      guard let data = try? Data(contentsOf: cacheUrl(forFilename: filename)) else {
        print("Could not read data for file `\(filename)`")
        return
      }
      let dataArray = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Data]
      let unarchived = dataArray.map { Element.Iterator.Element.init(data: $0) }
      
      guard let elements = unarchived as? E else {
        fatalError("only Arrays of Archivable can be unarchived")
      }
      self.value = elements
    }
    return self
  }
}
