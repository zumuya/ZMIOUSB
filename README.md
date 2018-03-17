# ZMIOUSB

ZMIOUSB is a framework that bridges IOKit USB APIs to Swift.

- Requirements: OS X 10.9 or later
- Swift version: 4.0

## Installation

### Carthage

To install this framework using [Carthage](https://github.com/Carthage/Carthage), add the following line to your Cartfile.

```
github "zumuya/ZMIOUSB"
```

## General usage

### Getting the device interface and interface interface

```swift
let deviceInterface = try USBDeviceInterface.create(vendorIdentifier: VENDOR_ID, productIdentifier: PRODUCT_ID)
defer { deviceInterface.release() }

let interfaceInterface = try deviceInterface.createInterfaceInterface()
defer { interfaceInterface.release() }
```
You must call `release()` after using interfaces. We recommend to use `defer {}` since many functions in this framework throw errors.

### Opening & closing devices

```swift
try deviceInterface.openAndPerform {
	...
}
try interfaceInterface.openAndPerform {
	...
}
```

### Sending data

```swift
try interfaceInterface.write(someData, pipe: PIPE_WRITE)
```

### Receiving data

```swift
let result = try interfaceInterface.readBytes(pipe: PIPE_READ)
```

### Example: Sending `[0x01, 0x02, 0x03]` command and receiving 16 bytes answer data in background

```swift
DispatchQueue.global().async {
	do {
		let deviceInterface = try USBDeviceInterface.create(vendorIdentifier: VENDOR_ID, productIdentifier: PRODUCT_ID)
		defer { deviceInterface.release() }

		let interfaceInterface = try deviceInterface.createInterfaceInterface()
		defer { interfaceInterface.release() }

		try interfaceInterface.openAndPerform {
			try interfaceInterface.write([0x01, 0x02, 0x03], pipe: PIPE_WRITE)
			let result = try interfaceInterface.readBytes(minCount: 16, pipe: PIPE_READ)
			
			DispatchQueue.main.async {
				self.displayText("Received: " + result.description)
			}
		}
	} catch let error {
		DispatchQueue.main.async {
			self.presentError(error)
		}
	}
}
```

## Observing

### Example: Observing the device list

Use `USBDeviceInterface.observeDeviceList(...)` to get callbacks when USB devices are connected or disconnected.

```swift
let observer = try USBDeviceInterface.observeDeviceList(vendorIdentifier: VENDOR_ID, productIdentifier: PRODUCT_ID) { (notification, service) in
	do {
		switch notification {
		case kIOFirstMatchNotification:
			print("device is connected!")
		
			let deviceInterface = try USBDeviceInterface.create(service: service)
			defer { deviceInterface.release() }
			...
			
		case kIOTerminatedNotification:
			print("device is disconnected!")
			
			...
		default:
			break
		}
	} catch let error {
		print("error: \(error)")
	}
}
self.deviceListObserver = observer //keep it!
```

## Using original APIs

Since this framework just extends original types, you can use original APIs without casting.

```swift
let ioReturn = interfaceInterface.pointee?.pointee.ResetPipe(interfaceInterface, 1)
```

## Error

This framework extends `IOReturn` with `LocalizedError` protocol.

### Throwing

You can throw an `IOReturn` as a Swift error.

```swift
let ioReturn = interfaceInterface.pointee?.pointee.ResetPipe(interfaceInterface, 1)
if (ioReturn != .success) {
	throw ioReturn
}
```

### Throwing with method

By using `IOReturn.throwIfNotSuccess()` method, you can call existing functions with `try` keyword.

```swift
try interfaceInterface.pointee?.pointee.ResetPipe(interfaceInterface, 1).throwIfNotSuccess()
```

### Localizing messages

This framework doesn't contain any localization for error messages. But you can provide and customize messages.

```swift
IOReturn.localizedDescriptionHandlers.append { error in
	NSLocalizedString(String(format: "IOReturn_description_%i", error.rawValue), comment: "")
}
IOReturn.recoverySuggestionHandlers.append { error in
	NSLocalizedString(String(format: "IOReturn_recoverySuggestion_%i", error.rawValue), comment: "")
}
```

## License

This framework is distributed under the terms of the [MIT License](LICENSE).

