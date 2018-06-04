/*
ZMIOUSB.swift
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
import IOKit
import IOKit.usb

//MARK: Struct Versions

public typealias USBDeviceInterfaceStruct = IOUSBDeviceInterface650 //OS X 10.9 and later
public typealias USBInterfaceInterfaceStruct = IOUSBInterfaceInterface700 //OS X 10.9 and later
public let USBDeviceInterfaceID = kIOUSBDeviceInterfaceID650
public let USBInterfaceInterfaceID = kIOUSBInterfaceInterfaceID700

//MARK: - Plugin Interface

public typealias PluginInterface = UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>
extension UnsafeMutablePointer where Pointee == UnsafeMutablePointer<IOCFPlugInInterface>?
{
	public static func create(service: io_service_t, pluginType: CFUUID!) throws -> (pluginInterface: PluginInterface, score: Int)
	{
		var pluginInterface: PluginInterface? = nil
		var score: Int32 = 0
		
		try IOCreatePlugInInterfaceForService(service, pluginType, kIOCFPlugInInterfaceID, &pluginInterface, &score).throwIfNotSuccess()
		if let pluginInterface = pluginInterface {
			return (pluginInterface: pluginInterface, score: Int(score))
		} else {
			throw ZMIOError.noPluginInterface
		}
	}
	
	//MARK: - Query
	
	public func queryAndCreateInterface<InterfaceStruct>(interfaceType: CFUUID!) throws -> UnsafeMutablePointer<UnsafeMutablePointer<InterfaceStruct>?>
	{
		var interface: UnsafeMutablePointer<UnsafeMutablePointer<InterfaceStruct>?>? = nil
		let result = withUnsafeMutablePointer(to: &interface) {
			$0.withMemoryRebound(to: Optional<LPVOID>.self, capacity: 1) {
				pointee?.pointee.QueryInterface(self, CFUUIDGetUUIDBytes(interfaceType), $0)
			}
		}
		if (result == S_OK), let interface = interface {
			return interface
		} else {
			throw ZMIOError.couldNotQueryInterface
		}
	}
	
	//MARK: - Retain & Release
	
	@discardableResult public func retain() -> PluginInterface
	{
		_ = pointee?.pointee.AddRef(self)
		return self
	}
	public func release()
	{
		_ = pointee?.pointee.Release(self)
	}
}

//MARK: - IOObject (io_object_t)

extension io_object_t
{
	@discardableResult public func retain() -> io_object_t
	{
		IOObjectRetain(self)
		return self
	}
	public func release()
	{
		IOObjectRelease(self)
	}
}

//MARK: - Iterator

public typealias USBDeviceInterfaceEnumerationHandler = ((_ interface: USBDeviceInterface, _ stop: inout Bool) -> Void)
public typealias USBInterfaceInterfaceEnumerationHandler = ((_ interface: USBInterfaceInterface, _ stop: inout Bool) -> Void)

extension io_iterator_t
{
	func enumerateServices(clearRemainingServices: Bool = true, handler: ((io_service_t, inout Bool) throws -> Void)) rethrows
	{
		var shouldClearRemainingServices = clearRemainingServices
		defer {
			if shouldClearRemainingServices {
				//Clear all services.
				while case let service = IOIteratorNext(self), (service != 0) { service.release() }
			}
		}
		while case let service = IOIteratorNext(self), (service != 0) {
			defer { service.release() }
			var stop = false
			
			try handler(service, &stop)
			if stop {
				return
			}
		}
		shouldClearRemainingServices = false
	}
}

//MARK: - Device Interface

public typealias USBDeviceInterface = UnsafeMutablePointer<UnsafeMutablePointer<USBDeviceInterfaceStruct>?>
extension UnsafeMutablePointer where Pointee == UnsafeMutablePointer<USBDeviceInterfaceStruct>?
{
	public static func matchingDictionary(deviceClassName: String, vendorIdentifier: Int?, productIdentifier: Int?) -> [String: AnyObject]
	{
		var matchingDictionary: [String: AnyObject] = [:]
		deviceClassName.withCString {
			matchingDictionary = IOServiceMatching($0) as NSMutableDictionary as! [String: AnyObject]
			if let vendorIdentifier = vendorIdentifier {
				matchingDictionary[String(cString: kUSBVendorID, encoding: .ascii)!] = vendorIdentifier as AnyObject
			}
			if let productIdentifier = productIdentifier {
				matchingDictionary[String(cString: kUSBProductID, encoding: .ascii)!] = productIdentifier as AnyObject
			}
		}
		return matchingDictionary
	}
	public static func matchingDictionary(vendorIdentifier: Int?, productIdentifier: Int?) -> [String: AnyObject]
	{
		var deviceClassName = kIOUSBDeviceClassName
		if #available(macOS 10.11, *) {
			deviceClassName = "IOUSBHostDevice"
		}
		return matchingDictionary(deviceClassName: deviceClassName, vendorIdentifier: vendorIdentifier, productIdentifier: productIdentifier)
	}
	
	public static func create(vendorIdentifier: Int, productIdentifier: Int) throws -> USBDeviceInterface
	{
		let matchingDictionary = self.matchingDictionary(vendorIdentifier: vendorIdentifier, productIdentifier: productIdentifier)
		return try create(matchingDictionary: matchingDictionary)
	}
	public static func create(matchingDictionary: [String: AnyObject]) throws -> USBDeviceInterface
	{
		var deviceInterface: USBDeviceInterface? = nil; do {
			var services: io_iterator_t = 0;
			try IOReturn(IOServiceGetMatchingServices(kIOMasterPortDefault, (matchingDictionary as CFDictionary), &services)).throwIfNotSuccess()
			defer { services.release() }
			
			try services.enumerateServices(handler: { (service, stop) in
				deviceInterface = try create(service: service)
				stop = true
			})
		}
		if let deviceInterface = deviceInterface {
			return deviceInterface
		} else {
			throw ZMIOError.pluginHasNoUsbDeviceInterface
		}
	}
	public static func create(service: io_service_t) throws -> USBDeviceInterface
	{
		let pluginInterface = try PluginInterface.create(service: service, pluginType: kIOUSBDeviceUserClientTypeID).pluginInterface
		defer { pluginInterface.release() }
		
		if let deviceInterface = try? pluginInterface.queryAndCreateInterface(interfaceType: USBDeviceInterfaceID) as USBDeviceInterface {
			return deviceInterface
		} else {
			throw ZMIOError.couldNotQueryUsbDeviceInterface
		}
	}
	
	//MARK: - Information
	
	public func getVendorIdentifier() throws -> Int
	{
		var vendorIdentifier: UInt16 = 0
		try pointee?.pointee.GetDeviceVendor(self, &vendorIdentifier).throwIfNotSuccess()
		return Int(vendorIdentifier)
	}
	public func getProductIdentifier() throws -> Int
	{
		var productIdentifier: UInt16 = 0
		try pointee?.pointee.GetDeviceProduct(self, &productIdentifier).throwIfNotSuccess()
		return Int(productIdentifier)
	}
	
	//MARK: - Interface Interface
	
	//ex. interfaceClass: kUSBPrintingInterfaceClass
	public func createInterfaceInterface(interfaceClass: Int = kIOUSBFindInterfaceDontCare, interfaceSubClass: Int = kIOUSBFindInterfaceDontCare, interfaceProtocol: Int = kIOUSBFindInterfaceDontCare, alternateSetting: Int = kIOUSBFindInterfaceDontCare) throws -> USBInterfaceInterface
	{
		var interfaceRequest = IOUSBFindInterfaceRequest(); do {
			interfaceRequest.bInterfaceClass = UInt16(interfaceClass)
			interfaceRequest.bInterfaceSubClass = UInt16(interfaceSubClass)
			interfaceRequest.bInterfaceProtocol = UInt16(interfaceProtocol)
			interfaceRequest.bAlternateSetting = UInt16(alternateSetting)
		}
		return try createInterfaceInterface(request: interfaceRequest)
	}
	public func createInterfaceInterface(request: IOUSBFindInterfaceRequest) throws -> USBInterfaceInterface
	{
		var interfaceInterface: USBInterfaceInterface? = nil; do {
			var request = request
			
			var services: io_iterator_t = 0
			try pointee?.pointee.CreateInterfaceIterator(self, &request, &services).throwIfNotSuccess()
			defer { services.release() }
			
			try services.enumerateServices { (service, stop) in
				interfaceInterface = try USBInterfaceInterface.create(service: service)
				stop = true
			}
		}
		if let interfaceInterface = interfaceInterface {
			return interfaceInterface
		} else {
			throw ZMIOError.pluginHasNoUsbInterfaceInterface
		}
	}
	
	//MARK: - Open & Close
	
	public func open(seize: Bool = false) throws
	{
		if seize {
			try pointee?.pointee.USBDeviceOpenSeize(self).throwIfNotSuccess()
		} else {
			try pointee?.pointee.USBDeviceOpen(self).throwIfNotSuccess()
		}
	}
	public func close() throws
	{
		try? pointee?.pointee.USBDeviceClose(self).throwIfNotSuccess()
	}
	
	public func openAndPerform(seize: Bool = false, handler: () throws -> ()) throws
	{
		try open(seize: seize)
		defer { try? close() }
		
		try handler()
	}
	
	//MARK: - Reset
	
	public func reset() throws
	{
		try pointee?.pointee.ResetDevice(self).throwIfNotSuccess()
	}
	
	//MARK: - Retain & Release
	
	@discardableResult public func retain() -> USBDeviceInterface
	{
		_ = pointee?.pointee.AddRef(self)
		return self
	}
	public func release()
	{
		_ = pointee?.pointee.Release(self)
	}
}

//MARK: - Interface Interface

public typealias USBInterfaceInterface = UnsafeMutablePointer<UnsafeMutablePointer<USBInterfaceInterfaceStruct>?>
extension UnsafeMutablePointer where Pointee == UnsafeMutablePointer<USBInterfaceInterfaceStruct>?
{
	public static func create(service: io_service_t) throws -> USBInterfaceInterface
	{
		let pluginInterface = try PluginInterface.create(service: service, pluginType: kIOUSBInterfaceUserClientTypeID).pluginInterface
		defer { pluginInterface.release() }
		
		if let interfaceInterface = try? pluginInterface.queryAndCreateInterface(interfaceType: USBInterfaceInterfaceID) as USBInterfaceInterface {
			return interfaceInterface
		} else {
			throw ZMIOError.couldNotQueryUsbDeviceInterface
		}
	}
	
	//MARK: - Open & Close
	
	public func open(seize: Bool = false) throws
	{
		if seize {
			try pointee?.pointee.USBInterfaceOpenSeize(self).throwIfNotSuccess()
		} else {
			try pointee?.pointee.USBInterfaceOpen(self).throwIfNotSuccess()
		}
	}
	public func close() throws
	{
		try? pointee?.pointee.USBInterfaceClose(self).throwIfNotSuccess()
	}
	
	public func openAndPerform(seize: Bool = false, handler: () throws -> ()) throws
	{
		try open(seize: seize)
		defer { try? close() }
		
		try handler()
	}
	
	//MARK: - Read
	
	public func readBytes(minCount: Int? = nil, maxCount: Int = 64, pipe: Int, noDataTimeout: TimeInterval = 0.3, completionTimeout: TimeInterval = 0.3) throws -> [UInt8]
	{
		var buffer = [UInt8](repeating: 0x0, count: maxCount)
		var readCount = UInt32(maxCount)
		try pointee?.pointee.ReadPipeTO(self, UInt8(pipe), &buffer, &readCount, UInt32(noDataTimeout * 1000.0), UInt32(completionTimeout * 1000.0)).throwIfNotSuccess()
		if let minCount = minCount, (readCount < minCount) {
			throw ZMIOError.couldNotGetEnoughData
		}
		return [UInt8](buffer.prefix(upTo: min(maxCount, Int(readCount))))
	}
	
	//MARK: - Write
	
	public func write(_ bytes: [UInt8], pipe: Int, noDataTimeout: TimeInterval = 0.3, completionTimeout: TimeInterval = 0.3) throws
	{
		var bytes = bytes
		try pointee?.pointee.WritePipeTO(self, UInt8(pipe), &bytes, UInt32(bytes.count), UInt32(noDataTimeout * 1000), UInt32(completionTimeout * 1000)).throwIfNotSuccess()
	}
	
	//MARK: - Control Request
	
	public func sendControlRequest(_ request: IOUSBDevRequestTO, pipe: Int) throws
	{
		var request = request
		try pointee?.pointee.ControlRequestTO(self, UInt8(pipe), &request).throwIfNotSuccess()
	}
	
	//MARK: - Pipe Utilities
	
	public func clearPipeStall(bothEnds: Bool = false, pipe: Int) throws
	{
		if bothEnds {
			try pointee?.pointee.ClearPipeStallBothEnds(self, UInt8(pipe)).throwIfNotSuccess()
		} else {
			try pointee?.pointee.ClearPipeStall(self, UInt8(pipe)).throwIfNotSuccess()
		}
	}
	
	//MARK: - Reset
	
	public func resetPipe(_ pipe: Int) throws
	{
		try pointee?.pointee.ResetPipe(self, UInt8(pipe)).throwIfNotSuccess()
	}
	
	//MARK: - Retain & Release
	
	@discardableResult public func retain() -> USBInterfaceInterface
	{
		_ = pointee?.pointee.AddRef(self)
		return self
	}
	public func release()
	{
		_ = pointee?.pointee.Release(self)
	}
	
	//MARK: - Read & Write Data Objects
	
	public func write(_ data: Data, pipe: Int, noDataTimeout: TimeInterval = 0.3, completionTimeout: TimeInterval = 0.3) throws
	{
		try write([UInt8](data), pipe: pipe, noDataTimeout: noDataTimeout, completionTimeout: completionTimeout)
	}
	public func read(minCount: Int? = nil, maxCount: Int = 64, pipe: Int, noDataTimeout: TimeInterval = 0.3, completionTimeout: TimeInterval = 0.3) throws -> Data
	{
		let bytes = try readBytes(minCount: minCount, maxCount: maxCount, pipe: pipe, noDataTimeout: noDataTimeout, completionTimeout: completionTimeout)
		return Data(bytes)
	}
}

//MARK: - Notification Port

extension IONotificationPortRef
{
	static func create(masterPort: mach_port_t = kIOMasterPortDefault) -> IONotificationPortRef!
	{
		return IONotificationPortCreate(masterPort)
	}
	
	//MARK: - Retain & Release
	
	func release()
	{
		IONotificationPortDestroy(self)
	}
	
	//MARK: - Dispatch Queue
	
	func setDispatchQueue(_ dispatchQueue: DispatchQueue)
	{
		IONotificationPortSetDispatchQueue(self, dispatchQueue)
	}
}
