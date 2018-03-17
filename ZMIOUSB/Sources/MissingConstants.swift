/*
MissingConstants.swift
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

import IOKit

//MARK: ID Constants

public let kIOHIDDeviceUserClientTypeID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0xFA, 0x12, 0xFA, 0x38, 0x6F, 0x1A, 0x11, 0xD4, 0xBA, 0x0C, 0x00, 0x05, 0x02, 0x8F, 0x18, 0xD5)
public let kIOUSBDeviceUserClientTypeID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0x9d, 0xc7, 0xb7, 0x80, 0x9e, 0xc0, 0x11, 0xD4, 0xa5, 0x4f, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)
public let kIOUSBInterfaceUserClientTypeID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0x2d, 0x97, 0x86, 0xc6, 0x9e, 0xf3, 0x11, 0xD4, 0xad, 0x51, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)

public let kIOHIDDeviceInterfaceID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0x78, 0xBD, 0x42, 0x0C, 0x6F, 0x14, 0x11, 0xD4, 0x94, 0x74, 0x00, 0x05, 0x02, 0x8F, 0x18, 0xD5)
public let kIOHIDDeviceInterfaceID122 = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0xb7, 0xa, 0xbf, 0x31, 0x16, 0xd5, 0x11, 0xd7, 0xab, 0x35, 0x0, 0x3, 0x93, 0x99, 0x2e, 0x38)
public let kIOHIDQueueInterfaceID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0x81, 0x38, 0x62, 0x9E, 0x6F, 0x14, 0x11, 0xD4, 0x97, 0x0E, 0x00, 0x05, 0x02, 0x8F, 0x18, 0xD5)
public let kIOHIDOutputTransactionInterfaceID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0x80, 0xCD, 0xCC, 0x00, 0x75, 0x5D, 0x11, 0xD4, 0x80, 0xEF, 0x00, 0x05, 0x02, 0x8F, 0x18, 0xD5)

public let kIOCFPlugInInterfaceID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0xC2, 0x44, 0xE8, 0x58, 0x10, 0x9C, 0x11, 0xD4, 0x91, 0xD4, 0x00, 0x50, 0xE4, 0xC6, 0x42, 0x6F)
public let kIOUSBDeviceInterfaceID650 = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0x4A, 0xAC, 0x1B, 0x2E, 0x24, 0xC2, 0x47, 0x6A, 0x96, 0x4D, 0x91, 0x33, 0x35, 0x34, 0xF2, 0xCC)
public let kIOUSBInterfaceInterfaceID700 = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault, 0x17, 0xF9, 0xE5, 0x9C, 0xB0, 0xA1, 0x40, 0x1D, 0x9A, 0xC0, 0x8D, 0xE2, 0x7A, 0xC6, 0x04, 0x7E)

//MARK: - USB Error Constants

public func iokit_usb_err(_ value: Int) -> IOReturn
{
	return IOReturn(Int32(bitPattern: 0xe0004000) | Int32(value))
}
public let kIOUSBUnknownPipeErr = iokit_usb_err(0x61)
public let kIOUSBTooManyPipesErr = iokit_usb_err(0x60)
public let kIOUSBNoAsyncPortErr = iokit_usb_err(0x5f)
public let kIOUSBNotEnoughPipesErr = iokit_usb_err(0x5e)
public let kIOUSBNotEnoughPowerErr = iokit_usb_err(0x5d)
public let kIOUSBEndpointNotFound = iokit_usb_err(0x57)
public let kIOUSBConfigNotFound = iokit_usb_err(0x56)
public let kIOUSBTransactionTimeout = iokit_usb_err(0x51)
public let kIOUSBTransactionReturned = iokit_usb_err(0x50)
public let kIOUSBPipeStalled = iokit_usb_err(0x4f)
public let kIOUSBInterfaceNotFound = iokit_usb_err(0x4e)
public let kIOUSBLowLatencyBufferNotPreviouslyAllocated = iokit_usb_err(0x4d)
public let kIOUSBLowLatencyFrameListNotPreviouslyAllocated = iokit_usb_err(0x4c)
public let kIOUSBHighSpeedSplitError = iokit_usb_err(0x4b)
public let kIOUSBSyncRequestOnWLThread = iokit_usb_err(0x4a)
public let kIOUSBDeviceNotHighSpeed = iokit_usb_err(0x49)
public let kIOUSBDeviceTransferredToCompanion = iokit_usb_err(0x49)
public let kIOUSBClearPipeStallNotRecursive  = iokit_usb_err(0x48)
public let kIOUSBDevicePortWasNotSuspended  = iokit_usb_err(0x47)
public let kIOUSBEndpointCountExceeded = iokit_usb_err(0x46)
public let kIOUSBDeviceCountExceeded = iokit_usb_err(0x45)
public let kIOUSBStreamsNotSupported = iokit_usb_err(0x44)
public let kIOUSBInvalidSSEndpoint = iokit_usb_err(0x43)
public let kIOUSBTooManyTransactionsPending = iokit_usb_err(0x42)

