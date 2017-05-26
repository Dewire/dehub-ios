//
//  File.swift
//  DeHub
//
//  Created by Kalle Lindström on 02/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Utils

extension ObservableType {
  
  public func doOnNextAndError(callback: @escaping () -> Void) -> Observable<Self.E> {
    return self.do(onNext: { _ in callback() }, onError: { _ in callback() })
  }
  
  public func doOnErrorAndCompleted(callback: @escaping () -> Void) -> Observable<Self.E> {
    return self.do(onError: { _ in callback() }, onCompleted: { _ in callback() })
  }

  func asDriverOrDie() -> Driver<Self.E> {
    return self.asDriver(onErrorRecover: { _ in fatalError("error on asDriverOrDie") })
  }
}

// MARK: Spin and error

extension ObservableType {

  func error() -> Observable<Self.E> {
    return self.do(onError: { error in
      EventChannel.shared.events.onNext(.displayError(error: error))
    })
  }

  func spin() -> Observable<Self.E> {
    return self.do(onNext: { _ in EventChannel.shared.events.onNext(.hideSpinner) },
      onError: { _ in EventChannel.shared.events.onNext(.hideSpinner) },
      onSubscribe: { EventChannel.shared.events.onNext(.showSpinner) })
  }
}

// MARK: Operator unwrap

//
//  unwrap.swift
//  RxSwiftExt
//
//  Created by Marin Todorov on 4/7/16.
//  Copyright (c) 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity
//

public protocol Optionable {
  associatedtype WrappedType
  func withoutNils() -> WrappedType
  func isEmpty() -> Bool
}

extension Optional : Optionable {
  public typealias WrappedType = Wrapped
  
  /**
   Force unwraps the contained value and returns it. Will crash if there's no value stored.
   
   - returns: Value of the contained type
   */
  public func withoutNils() -> WrappedType {
    return self!
  }
  
  /**
   Returns `true` if the Optional element is `nil` (if it does not contain a value)
   or `false` if the element *does* contain a value
   
   - returns: `true` if the Optional element is `nil`; false if it *does* have a value
   */
  public func isEmpty() -> Bool {
    return self == nil
  }
}

extension ObservableType where E : Optionable {
  
  /**
   Takes a sequence of optional elements and returns a sequence of non-optional elements,
   filtering out any nil values.
   
   - returns: An observable sequence of non-optional elements
   */
  public func withoutNils() -> Observable<E.WrappedType> {
    return self
      .filter { value in
        return !value.isEmpty()
      }
      .map { value -> E.WrappedType in
        value.withoutNils()
    }
  }
}

extension SharedSequence where S == DriverSharingStrategy, E : Optionable {
  /**
   Takes a sequence of optional elements and returns a sequence of non-optional elements,
   filtering out any nil values.

   - returns: An observable sequence of non-optional elements
   */
  public func withoutNils() -> Driver<E.WrappedType> {
    return self
      .filter { value in
        return !value.isEmpty()
      }
      .map { value -> E.WrappedType in
        value.withoutNils()
      }
  }
}
