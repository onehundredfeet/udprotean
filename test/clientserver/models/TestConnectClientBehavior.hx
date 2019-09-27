package clientserver.models;

import udprotean.server.UDProteanClientBehavior;


class TestConnectClientBehavior extends UDProteanClientBehavior
{
    public var initializeCalled: Bool = false;
    public var onConnectCaled: Bool = false;


    override function initialize() 
    {
        initializeCalled = true;
    }


    override function onConnect() 
    {
        onConnectCaled = true;
    }
}
