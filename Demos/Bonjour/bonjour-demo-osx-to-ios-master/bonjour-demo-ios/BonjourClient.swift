//
//  BonjourController.swift
//  bonjour-demo-ios
//
//  Created by James Zaghini on 12/05/2015.
//  Copyright (c) 2015 James Zaghini. All rights reserved.
//

import UIKit

enum PacketTag: Int {
    case header = 1
    case body = 2
}

protocol BonjourClientDelegate {
    func connectedTo(_ socket: GCDAsyncSocket!)
    func disconnected()
    func handleBody(_ body: String?)
}

class BonjourClient: NSObject, NetServiceDelegate, NetServiceBrowserDelegate, GCDAsyncSocketDelegate {
   
    var delegate: BonjourClientDelegate!
    var service: NetService!
    var socket: GCDAsyncSocket!
    
    override init() {
        super.init()
        startBroadCasting()
    }

    func startBroadCasting() {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket.accept(onPort: 0)
            service = NetService(domain: "local.", type: "_probonjore._tcp.", name: UIDevice.current.name, port: Int32(socket.localPort))
            service.delegate = self
            service.publish()
        } catch let error1 as NSError {
            print("Unable to create socket. Error \(error1)")
        }
    }

    func parseHeader(_ data: Data) -> UInt {
        var out: UInt8 = 0
        data.copyBytes(to: &out, count: data.count)
        return UInt(out)
    }

    func handleResponseBody(_ data: Data) -> String? {
        return String(data: data, encoding: .utf8)
    }

    func send(_ data: Data) {
        var header = data.count
        let headerData = Data(bytes: &header, count: MemoryLayout<UInt>.size)
        socket.write(headerData, withTimeout: -1.0, tag: PacketTag.header.rawValue)
        socket.write(data, withTimeout: -1.0, tag: PacketTag.body.rawValue)
    }
    
    /// MARK: NSNetService Delegates
    
    func netServiceDidPublish(_ sender: NetService) {
        print("Bonjour service published. domain: \(sender.domain), type: \(sender.type), name: \(sender.name), port: \(sender.port)")
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("Unable to create socket. domain: \(sender.domain), type: \(sender.type), name: \(sender.name), port: \(sender.port), Error \(errorDict)")
    }
    
    /// MARK: GCDAsyncSocket Delegates
    
    func socket(_ sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        print("Did accept new socket")
        socket = newSocket
        socket.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: 0)
        delegate.connectedTo(newSocket)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: Error!) {
        print("socket did disconnect: error \(err)")
        if self.socket == socket {
            self.delegate.disconnected()
        }
    }
    
    func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {
        print("did read data")

        if data.count == MemoryLayout<UInt>.size {
            let bodyLength: UInt = parseHeader(data)
            sock.readData(toLength: bodyLength, withTimeout: -1, tag: PacketTag.body.rawValue)
        } else {
            let body = handleResponseBody(data)
            delegate.handleBody(body)
            sock.readData(toLength: UInt(MemoryLayout<UInt>.size), withTimeout: -1, tag: PacketTag.header.rawValue)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        print("did write data with tag: \(tag)")
    }
}
