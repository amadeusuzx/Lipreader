//
//  Queue.swift
//  StreamIt
//
//  Created by Thibault Wittemberg on 14/04/2016.
//  Copyright © 2016 Thibault Wittemberg. All rights reserved.
//
import Foundation
import CocoaAsyncSocket

private class QueueItem<T> {

    fileprivate let value: T!
    fileprivate var next: QueueItem?

    init(_ newvalue: T?) {
        self.value = newvalue
    }
}

open class Queue<T> {

    fileprivate var _front: QueueItem<T>
    fileprivate var _back: QueueItem<T>
    var maxCapacity: Int
    var currentSize = 0

    public init(maxCapacity: Int) {
        // Insert dummy item. Will disappear when the first item is added.
        _back = QueueItem(nil)
        _front = _back
        self.maxCapacity = maxCapacity
    }

    /// Add a new item to the back of the queue.
    open func enqueue(_ value: T) {
        if self.currentSize >= maxCapacity {
            _back = QueueItem(value)
        } else {
            _back.next = QueueItem(value)
            _back = _back.next!
            self.currentSize += 1
        }
    }

    /// Return and remove the item at the front of the queue.
    open func dequeue() -> T? {
        if let newhead = _front.next {
            _front = newhead
            self.currentSize -= 1
            return newhead.value
        } else {
            self.currentSize = 0
            return nil
        }
    }

    open func isEmpty() -> Bool {
        return _front === _back
    }
}


func getIpAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                } else if (name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3") {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(1), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }


class StreamingSession {
    
    var client: GCDAsyncSocket
    fileprivate var headersSent = false
    fileprivate var queue: DispatchQueue
    fileprivate let footersData = ["", ""].joined(separator: "\r\n").data(using: String.Encoding.utf8)
    var dataStack = Queue<Data>(maxCapacity: 10)
    
    var userName: String
    var connected = true
    var dataToSend: Data? {
        didSet {
            guard let dataToSend = self.dataToSend else { return }
            
            self.dataStack.enqueue(dataToSend)
        }
    }
    
    // MARK: - Lifecycle
    
    init (client: GCDAsyncSocket, queue: DispatchQueue, userName: String) {
        self.client = client
        self.queue = queue
        self.userName = userName
    }
    
    // MARK: - Methods
    
    func close() {
        self.connected = false
    }
    
    
    func socketStartStreaming(){
        
        self.queue.async(execute: { [unowned self] in
            let userNameData = [
                "\(self.userName)",
                ""
            ].joined(separator: "\r\n").data(using: String.Encoding.utf8)
            self.client.write(userNameData, withTimeout: -1, tag: 0)
            
            while self.connected {
                if (self.client.connectedPort().hashValue == 0 || !self.client.isConnected()) {
                    // y a personne en face ... on arrête d'envoyer des données
                    self.close()
                    break
                }
                
                
                if let data = self.dataStack.dequeue() {
                    let frameHeaders = [
                        "\(data.count)",
                        ""
                    ]
                    
                    guard let frameHeadersData = frameHeaders.joined(separator: "\r\n").data(using: String.Encoding.utf8) else { return }
                    
                    self.client.write(frameHeadersData, withTimeout: -1, tag: 0)
                    self.client.write(data, withTimeout: -1, tag: 0)
                }
            }
        })
    }
}
