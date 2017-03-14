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

extension ReplaySubject {
  static func single() -> ReplaySubject<Element> {
    return ReplaySubject.create(bufferSize: 1)
  }
}

/**
This class holds the state (entities) of the app. Interested code (e.g. Directors) will subscribe to the state
observables exposed by this class in order to be automatically notified when the state changes for some reason
(e.g. network request, filesystem cache restore).

This class supports persisting state to the disk. Use the persistToDisk() method to save the state to disk
and the restoreFromDisk() to restore the state.

NOTE: Only ever instantiate one instance of this class. This instance is expected to live for the whole
lifetime of the app.

Implementation notes:

State uses ReplaySubjects with a buffer size of 1 and not Variable or BehaviorSubject. The reason for this is that
Variable and BehaviorSubject requires an initial value (seed) when created. If an initial value is given
it is impossible to identify a state that doesn't yet have a value (e.g. it has not been loaded from the
server yet). In some cases it is important to be able to tell if a state has received a value or not.
For example when we want to show a spinner if there is no state, but hide the spinner as soon as we have any
state to show.
*/
public final class State {

  let _gists = ReplaySubject<[GistEntity]>.single().persist(filename: "gists.cache")
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

fileprivate extension ReplaySubject {
  
  func archive(_ value: E) -> Data? {

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

fileprivate extension ReplaySubject where Element: Archivable {
  
  func persist(filename: String) -> ReplaySubject<Element> {
    marshalClosures.append {
      _ = self.take(1).subscribe(onNext: { [unowned self] value in
        guard let data = self.archive(value) else {
          fatalError("Value cannot be archived")
        }
        let fileUrl = cacheUrl(forFilename: filename)
        self.write(data: data, to: fileUrl)
      })
    }
    unmarshalClosures.append {
      guard let data = try? Data(contentsOf: cacheUrl(forFilename: filename)) else {
        print("Could not read data for file `\(filename)`")
        return
      }
      self.onNext(Element.init(data: data))
    }
    return self
  }
}

fileprivate extension ReplaySubject where Element: Collection, Element.Iterator.Element: Archivable {
  
  func persist(filename: String) -> ReplaySubject<Element> {
    marshalClosures.append {
      _ = self.take(1).subscribe(onNext: { [unowned self] value in
        guard let data = self.archive(value) else { fatalError("Value cannot be archived") }
        let fileUrl = cacheUrl(forFilename: filename)
        self.write(data: data, to: fileUrl)
      })
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
      self.onNext(elements)
    }
    return self
  }
}
