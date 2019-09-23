package udprotean;

import sys.net.Address;
import sys.net.Host;
import udprotean.shared.UDProteanSocket;

class UDProteanClient
{
    var socket: UDProteanSocket;
    var serverAddr: Address;
    

    public function new(host: String, port: Int) 
    {
        socket = new UDProteanSocket(host, port);
        serverAddr = new Address();
        serverAddr.host = new Host(host).ip;
        serverAddr.port = port;
    }


    public function connect()
    {
        socket.bind();
        socket.connect();
    }
}
