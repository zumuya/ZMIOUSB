/*
Errors.swift
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

//MARK: Framework Error

public enum ZMIOError: Int, LocalizedError
{
	case noPluginInterface
	case pluginHasNoUsbDeviceInterface
	case pluginHasNoUsbInterfaceInterface
	case couldNotQueryInterface
	case couldNotQueryUsbDeviceInterface
	case couldNotQueryUsbInterfaceInterface
	case couldNotGetEnoughData
	
	public static var errorDescriptionHandlers: [((ZMIOError) -> String?)] = []
	public static var recoverySuggestionHandlers: [((ZMIOError) -> String?)] = []
	
	public var recoverySuggestion: String?
	{
		for recoverySuggestionHandler in ZMIOError.recoverySuggestionHandlers {
			if let recoverySuggestion = recoverySuggestionHandler(self) {
				return recoverySuggestion
			}
		}
		return nil
	}
	
	public var errorDescription: String?
	{
		for errorDescriptionHandler in ZMIOError.errorDescriptionHandlers {
			if let errorDescription = errorDescriptionHandler(self) {
				return errorDescription
			}
		}
		switch self {
		case .noPluginInterface:
			return "I/O: No plugin interface."
		case .pluginHasNoUsbDeviceInterface:
			return "USB: Plugin has no device interface."
		case .pluginHasNoUsbInterfaceInterface:
			return "USB: Plugin has no interface interface."
		case .couldNotQueryInterface:
			return "I/O: Could not query interface."
		case .couldNotQueryUsbDeviceInterface:
			return "USB: Could not query device interface."
		case .couldNotQueryUsbInterfaceInterface:
			return "USB: Could not query interface interface."
		case .couldNotGetEnoughData:
			return "Could not get enough data."
		}
	}
}

//MARK: - IOKit Error (IOReturn)

extension IOReturn: LocalizedError
{
	public func throwIfNotSuccess() throws
	{
		if (self != .success) {
			throw self
		}
	}
	public func throwIfNotSuccess(_ altError: @autoclosure ()->Error) throws
	{
		if (self != .success) {
			throw altError()
		}
	}
	
	public static let success = kIOReturnSuccess
	
	public static let aborted = kIOReturnAborted
	public static let badArgument = kIOReturnBadArgument
	public static let badMedia = kIOReturnBadMedia
	public static let badMessageId = kIOReturnBadMessageID
	public static let busy = kIOReturnBusy
	public static let cannotLock = kIOReturnCannotLock
	public static let cannotWire = kIOReturnCannotWire
	public static let dmaError = kIOReturnDMAError
	public static let deviceError = kIOReturnDeviceError
	public static let error = kIOReturnError
	public static let exclusiveAccess = kIOReturnExclusiveAccess
	public static let ioError = kIOReturnIOError
	public static let ipcError = kIOReturnIPCError
	public static let internalError = kIOReturnInternalError
	public static let invalid = kIOReturnInvalid
	public static let isoTooNew = kIOReturnIsoTooNew
	public static let isoTooOld = kIOReturnIsoTooOld
	public static let lockedRead = kIOReturnLockedRead
	public static let lockedWrite = kIOReturnLockedWrite
	public static let messageTooLarge = kIOReturnMessageTooLarge
	public static let noBandwidth = kIOReturnNoBandwidth
	public static let noChannels = kIOReturnNoChannels
	public static let noCompletion = kIOReturnNoCompletion
	public static let noDevice = kIOReturnNoDevice
	public static let noFrames = kIOReturnNoFrames
	public static let noInterrupt = kIOReturnNoInterrupt
	public static let noMedia = kIOReturnNoMedia
	public static let noMemory = kIOReturnNoMemory
	public static let noPower = kIOReturnNoPower
	public static let noResources = kIOReturnNoResources
	public static let noSpace = kIOReturnNoSpace
	public static let notAligned = kIOReturnNotAligned
	public static let notAttached = kIOReturnNotAttached
	public static let notFound = kIOReturnNotFound
	public static let notOpen = kIOReturnNotOpen
	public static let notPermitted = kIOReturnNotPermitted
	public static let notPrivileged = kIOReturnNotPrivileged
	public static let notReadable = kIOReturnNotReadable
	public static let notReady = kIOReturnNotReady
	public static let notResponding = kIOReturnNotResponding
	public static let notWritable = kIOReturnNotWritable
	public static let offline = kIOReturnOffline
	public static let overrun = kIOReturnOverrun
	public static let portExists = kIOReturnPortExists
	public static let rldError = kIOReturnRLDError
	public static let stillOpen = kIOReturnStillOpen
	public static let timeout = kIOReturnTimeout
	public static let underrun = kIOReturnUnderrun
	public static let unformattedMedia = kIOReturnUnformattedMedia
	public static let unsupported = kIOReturnUnsupported
	public static let unsupportedMode = kIOReturnUnsupportedMode
	public static let vmError = kIOReturnVMError
	
	public static let usbUnknownPipe = kIOUSBUnknownPipeErr
	public static let usbTooManyPipes = kIOUSBTooManyPipesErr
	public static let usbNoAsyncPort = kIOUSBNoAsyncPortErr
	public static let usbNotEnoughPipes = kIOUSBNotEnoughPipesErr
	public static let usbNotEnoughPower = kIOUSBNotEnoughPowerErr
	public static let usbEndpointNotFound = kIOUSBEndpointNotFound
	public static let usbConfigNotFound = kIOUSBConfigNotFound
	public static let usbTransactionTimeout = kIOUSBTransactionTimeout
	public static let usbTransactionReturned = kIOUSBTransactionReturned
	public static let usbPipeStalled = kIOUSBPipeStalled
	public static let usbInterfaceNotFound = kIOUSBInterfaceNotFound
	public static let usbLowLatencyBufferNotPreviouslyAllocated = kIOUSBLowLatencyBufferNotPreviouslyAllocated
	public static let usbLowLatencyFrameListNotPreviouslyAllocated = kIOUSBLowLatencyFrameListNotPreviouslyAllocated
	public static let usbHighSpeedSplit = kIOUSBHighSpeedSplitError
	public static let usbSyncRequestOnWlThread = kIOUSBSyncRequestOnWLThread
	public static let usbDeviceNotHighSpeed = kIOUSBDeviceNotHighSpeed
	public static let usbDeviceTransferredToCompanion = kIOUSBDeviceTransferredToCompanion
	public static let usbClearPipeStallNotRecursive  = kIOUSBClearPipeStallNotRecursive
	public static let usbDevicePortWasNotSuspended  = kIOUSBDevicePortWasNotSuspended
	public static let usbEndpointCountExceeded = kIOUSBEndpointCountExceeded
	public static let usbDeviceCountExceeded = kIOUSBDeviceCountExceeded
	public static let usbStreamsNotSupported = kIOUSBStreamsNotSupported
	public static let usbInvalidSsEndpoint = kIOUSBInvalidSSEndpoint
	public static let usbTooManyTransactionsPending = kIOUSBTooManyTransactionsPending
	
	public static var errorDescriptionHandlers: [((IOReturn) -> String?)] = []
	public static var recoverySuggestionHandlers: [((IOReturn) -> String?)] = []
	
	public var recoverySuggestion: String?
	{
		for recoverySuggestionHandler in IOReturn.recoverySuggestionHandlers {
			if let recoverySuggestion = recoverySuggestionHandler(self) {
				return recoverySuggestion
			}
		}
		return nil
	}
	
	public var errorDescription: String?
	{
		for errorDescriptionHandler in IOReturn.errorDescriptionHandlers {
			if let errorDescription = errorDescriptionHandler(self) {
				return errorDescription
			}
		}
		switch self {
		case .aborted:
			return "Aborted"
		case .badArgument:
			return "Invalid argument"
		case .badMedia:
			return "Media error"
		case .badMessageId:
			return "Sent/received messages had different msg_id"
		case .busy:
			return "Device busy"
		case .cannotLock:
			return "Can't acquire lock"
		case .cannotWire:
			return "Can't wire down physical memory"
		case .dmaError:
			return "DMA failure"
		case .deviceError:
			return "The device is not working properly"
		case .error:
			return "General error"
		case .exclusiveAccess:
			return "Exclusive access and device already open"
		case .ioError:
			return "General I/O error"
		case .ipcError:
			return "Error during IPC"
		case .internalError:
			return "Internal error"
		case .invalid:
			return "Should never be seen"
		case .isoTooNew:
			return "Isochronous I/O request for distant future"
		case .isoTooOld:
			return "Isochronous I/O request for distant past"
		case .lockedRead:
			return "Device read locked"
		case .lockedWrite:
			return "Device write locked"
		case .messageTooLarge:
			return "Oversized msg received on interrupt port"
		case .noBandwidth:
			return "Bus bandwidth would be exceeded"
		case .noChannels:
			return "No DMA channels left"
		case .noCompletion:
			return "A completion routine is required"
		case .noDevice:
			return "No such device"
		case .noFrames:
			return "No DMA frames enqueued"
		case .noInterrupt:
			return "No interrupt attached"
		case .noMedia:
			return "Media not present"
		case .noMemory:
			return "Can't allocate memory"
		case .noPower:
			return "No power to device"
		case .noResources:
			return "Resource shortage"
		case .noSpace:
			return "No space for data"
		case .notAligned:
			return "Alignment error"
		case .notAttached:
			return "Device not attached"
		case .notFound:
			return "Data was not found"
		case .notOpen:
			return "Device not open"
		case .notPermitted:
			return "Not permitted"
		case .notPrivileged:
			return "Privilege violation"
		case .notReadable:
			return "Read not supported"
		case .notReady:
			return "Not ready"
		case .notResponding:
			return "Device not responding"
		case .notWritable:
			return "Write not supported"
		case .offline:
			return "Device offline"
		case .overrun:
			return "Data overrun"
		case .portExists:
			return "Port already exists"
		case .rldError:
			return "RLD failure"
		case .stillOpen:
			return "Device(s) still open"
		case .timeout:
			return "I/O timeout"
		case .underrun:
			return "Data underrun"
		case .unformattedMedia:
			return "media not formatted"
		case .unsupported:
			return "Unsupported function"
		case .unsupportedMode:
			return "No such mode"
		case .vmError:
			return "Misc. VM failure"
			
		case .usbUnknownPipe:
			return "Pipe ref not recognized"
		case .usbTooManyPipes:
			return "Too many pipes"
		case .usbNoAsyncPort:
			return "no async port"
		case .usbNotEnoughPipes:
			return "not enough pipes in interface"
		case .usbNotEnoughPower:
			return "not enough power for selected configuration"
		case .usbEndpointNotFound:
			return "Endpoint Not found"
		case .usbConfigNotFound:
			return "Configuration Not found"
		case .usbTransactionTimeout:
			return "Transaction timed out"
		case .usbTransactionReturned:
			return "The transaction has been returned to the caller"
		case .usbPipeStalled:
			return "Pipe has stalled, error needs to be cleared"
		case .usbInterfaceNotFound:
			return "Interface ref not recognized"
		case .usbLowLatencyBufferNotPreviouslyAllocated:
			return "Attempted to use user land low latency isoc calls w/out calling PrepareBuffer (on the data buffer) first "
		case .usbLowLatencyFrameListNotPreviouslyAllocated:
			return "Attempted to use user land low latency isoc calls w/out calling PrepareBuffer (on the frame list) first"
		case .usbHighSpeedSplit:
			return "Error to hub on high speed bus trying to do split transaction"
		case .usbSyncRequestOnWlThread:
			return "A synchronous USB request was made on the workloop thread (from a callback?).  Only async requests are permitted in that case"
		case .usbDeviceNotHighSpeed:
			return "Name is deprecated, see below"
		case .usbDeviceTransferredToCompanion:
			return "The device has been tranferred to another controller for enumeration"
		case .usbClearPipeStallNotRecursive:
			return "IOUSBPipe::ClearPipeStall should not be called recursively"
		case .usbDevicePortWasNotSuspended:
			return "Port was not suspended"
		case .usbEndpointCountExceeded:
			return "The endpoint was not created because the controller cannot support more endpoints"
		case .usbDeviceCountExceeded:
			return "The device cannot be enumerated because the controller cannot support more devices"
		case .usbStreamsNotSupported:
			return "The request cannot be completed because the XHCI controller does not support streams"
		case .usbInvalidSsEndpoint:
			return "An endpoint found in a SuperSpeed device is invalid (usually because there is no Endpoint Companion Descriptor)"
		case .usbTooManyTransactionsPending:
			return "The transaction cannot be submitted because it would exceed the allowed number of pending transactions"
			
		default:
			return "IOError (" + description + ")"
		}
	}
}
