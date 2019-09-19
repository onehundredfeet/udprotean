package udprotean;

import sys.net.UdpSocket;
import udprotean.shared.UDProteanSocket;

class UDProteanServer
{
    var socket: UDProteanSocket;

    public function new(host: String, port: Int) 
    {
        socket = new UDProteanSocket(host, port);
    }

    public function start()
    {
        socket.bind();
    }

    public function stop()
    {
        socket.close();
    }
}

