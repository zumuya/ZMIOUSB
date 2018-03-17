/*
Observing.swift
ZMIOUSB

Created by zumuya on 2018/03/17.

Copyright 2018 zumuya

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
APARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation

//MARK: Device Interface Extension

public typealias USBDeviceListObservingHandler = (_ notificationName: String, _ service: io_service_t) -> Void
extension UnsafeMutablePointer where Pointee == UnsafeMutablePointer<USBDeviceInterfaceStruct>?
{
	public static func observeDeviceList(notificationNames: Set<String> = [kIOFirstMatchNotification, kIOTerminatedNotification], queue: DispatchQueue = DispatchQueue.main, handler: @escaping USBDeviceListObservingHandler) throws -> Any
	{
		return try observeDeviceList(matchingDictionary: USBDeviceInterface.matchingDictionary(vendorIdentifier: nil, productIdentifier: nil), notificationNames: notificationNames, queue: queue, handler: handler)
	}
	public static func observeDeviceList(vendorIdentifier: Int, productIdentifier: Int, notificationNames: Set<String> = [kIOFirstMatchNotification, kIOTerminatedNotification], queue: DispatchQueue = DispatchQueue.main, handler: @escaping USBDeviceListObservingHandler) throws -> Any
	{
		return try observeDeviceList(matchingDictionary: USBDeviceInterface.matchingDictionary(vendorIdentifier: vendorIdentifier, productIdentifier: productIdentifier), notificationNames: notificationNames, queue: queue, handler: handler)
	}
	public static func observeDeviceList(matchingDictionary: [String: AnyObject], notificationNames: Set<String> = [kIOFirstMatchNotification, kIOTerminatedNotification], queue: DispatchQueue = DispatchQueue.main, handler: @escaping USBDeviceListObservingHandler) throws -> Any
	{
		return try _USBDeviceListObserver(matchingDictionary: matchingDictionary, notificationNames: notificationNames, callbackQueue: queue, handler: handler)
	}
}

//MARK: - Observer

@objc private class _USBDeviceListObserver: NSObject
{
	var observingQueue = DispatchQueue(label: (_USBDeviceListObserver.className() + "_observing"))
	var observingPort: IONotificationPortRef
	var callbackQueue: DispatchQueue
	var iteratorsForNotifications: [String: io_iterator_t] = [:]
	
	init(matchingDictionary: [String: AnyObject], notificationNames: Set<String>, callbackQueue: DispatchQueue, handler: @escaping USBDeviceListObservingHandler) throws
	{
		self.handler = handler
		self.callbackQueue = callbackQueue
		
		observingPort = IONotificationPortRef.create()
		observingPort.setDispatchQueue(observingQueue)
		
		super.init()
		
		for notificationName in notificationNames {
			var iterator = IO_OBJECT_NULL as io_iterator_t
			try IOReturn(IOServiceAddMatchingNotification(observingPort, notificationName, (matchingDictionary as CFDictionary), { (contextRef, iterator) in
				let context = Unmanaged<ObservingContext>.fromOpaque(contextRef!).takeUnretainedValue()
				context.observer?.handleNotification(name: context.notificationName, iterator: iterator)
			}, Unmanaged.passRetained(ObservingContext(notificationName: notificationName, observer: self)).toOpaque(), &iterator)).throwIfNotSuccess()
			iteratorsForNotifications[notificationName] = iterator
			handleNotification(name: notificationName, iterator: iterator)
		}
	}
	deinit
	{
		observingPort.release()
		for iterator in iteratorsForNotifications.values {
			iterator.release()
		}
	}
	
	var handler: USBDeviceListObservingHandler
	func handleNotification(name notificationName: String, iterator: io_iterator_t)
	{
		let handler = self.handler
		callbackQueue.async {
			iterator.enumerateServices { (service, stop) in
				handler(notificationName, service)
			}
		}
	}
	
	@objc private class ObservingContext: NSObject
	{
		weak var observer: _USBDeviceListObserver?
		let notificationName: String
		init(notificationName: String, observer: _USBDeviceListObserver)
		{
			self.observer = observer
			self.notificationName = notificationName
			super.init()
		}
	}
}
