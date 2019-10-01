package clientserver.models;

import utest.Assert;
import udprotean.client.UDProteanClient;
import udprotean.shared.UDProteanPeer;


class TestConnectClient extends UDProteanClient
{
    public var initializeCalled: Bool = false;
    public var onConnectCaled: Bool = false;
    public var onDisconnectCalled: Bool = false;


    override function initialize() 
    {
        initializeCalled = true;
    }


    override function onConnect() 
    {
        onConnectCaled = true;
    }


    override function onDisconnect() 
    {
        onDisconnectCalled = true;
    }
}
