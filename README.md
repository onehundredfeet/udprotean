<div align="center">

[![ ](https://gitlab.com/haath/udprotean/-/raw/master/assets/logo.png)](https://gitlab.com/haath/udprotean)

[![pipeline status](https://gitlab.com/haath/udprotean/badges/master/pipeline.svg)](https://gitlab.com/haath/udprotean/pipelines/latest)
[![coverage report](https://gitlab.com/haath/udprotean/badges/master/coverage.svg)](https://gitlab.com/haath/udprotean/pipelines/latest)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://gitlab.com/haath/udprotean/blob/master/LICENSE)
[![release](https://img.shields.io/badge/release-haxelib-informational)](https://lib.haxe.org/p/udprotean/)

</div>

---


- Low-latency communication over **UDP**.
- **Reliable** delivery, regardless of packet loss on the network.
- Messages are handled **in-order**, as they were sent.
- Under-the-hood **fragmentation** handling: send up to 137KB or more in a single message.
- Virtual **TCP-like connection** established with a handshake.
- Minimal and **efficient API**, similar to WebSockets.
- **Synchronous** single-threaded processing. Make it run in parallel any way you wish.
- **Dependency-free** native Haxe code, compile and use on any target that supports UDP.


## Benchmark

- Samples: `1000`
- Ping time: `40-50ms`
- Transmission every: `16ms`
- Target: `Neko`

<table><tr><th></th><th colspan='3'>Round-Trip Time</th></tr><tr><th>Packet Loss</th><th>Min</th><th>Mean</th><th>Max</th></tr><tr><td>0%</td><td>37ms</td><td>41ms</td><td>56ms</td></tr><tr><td>5%</td><td>32ms</td><td>42ms</td><td>144ms</td></tr><tr><td>10%</td><td>36ms</td><td>52ms</td><td>196ms</td></tr><tr><td>20%</td><td>30ms</td><td>66ms</td><td>240ms</td></tr><tr><td>40%</td><td>38ms</td><td>122ms</td><td>451ms</td></tr><tr><td>60%</td><td>35ms</td><td>241ms</td><td>701ms</td></tr></table>


## Install

```
$ haxelib install udprotean
```


## Usage

### Server

```haxe
import udprotean.server.UDProteanClientBehavior;

class EchoClientBehavior extends UDProteanClientBehavior
{
    // Called after the constructor.
    override function initialize() { }

    // Called after the connection handshake.
    override function onConnect() { }

    override function onMessage(message: Bytes) {
        // Repeat all messages back to the client.
        send(message);
    }

    override function onDisconnect() { }
}
```

```haxe
var server = new UDProteanServer("0.0.0.0", 9000, EchoClientBehavior);

server.start();

while (running)
{
    // Synchronously read and process incoming datagrams.
    server.update();
}

server.stop();
```


### Client

```haxe
import udprotean.server.UDProteanClient;

class MyClient extends UDProteanClient
{
    // Called after the constructor.
    override function initialize() { }

    // Called after the connection handshake.
    override function onConnect() { }

    override function onMessage(message: Bytes) { }

    override function onDisconnect() { }
}
```

```haxe
var client = new MyClient("127.0.0.1", 9000);

client.connect();

while (running)
{
    // Synchronously read and process incoming datagrams.
    client.update();

    client.send(bytes);
}

client.disconnect();
```


### Synchronous or with a Timeout

The `update()` method only returns when there is no data left to read on the socket.
For continuous communication, the `updateTimeout()` method may be preferable.

```haxe
// Process incoming data for up to 16ms.
client.updateTimeout(0.016);
```

This method is useful, when the load on the incoming buffer is not enough to cause a growing backlog, because it lets you synchronously handle the networking, and with a more-or-less fixed interval execute the rest of the application logic, all on a single thread. For example, a game loop could look like the following:

```haxe
while (gameIsRunning)
{
    // Process incoming data for up to 10ms.
    udproteanClient.updateTimeout(0.010);

    var input = getUserInput();

    // Send the user's input to the server.
    udproteanClient.send(input);

    // Update things in the game, like moving the player, physics etc.
    updateGame(input);
    render();
}
```


### The `send()` method

By default, the `send()` method will write the necessary datagrams to the UDP socket immediately.

```haxe
// Will block for a few ms.
client.send(Bytes.alloc(1024));
```

The alternative is to provide it with `false` as its second argument. This way, outgoing datagrams will only be stored in the underlying buffers and the method will return immediately without writing anything on the socket.

```haxe
// Will retun immediately.
client.send(Bytes.alloc(1024), false);

// Now update will transmit the previous message for the first time.
client.update();
```


### Unreliable Sending

The option to send unreliable UDP messages is still available through the `sendUnreliable()` method. Messages sent this way will bypass the sequential communication protocol, will not be stored in the local buffers, and instead will just be transmitted immediately as plain UDP datagrams.

```haxe
udproteanClient.sendUnreliable(bytes);
```

This can be useful for certain types of messages, such as for example position updates sent by the server to the clients, as this could significantly lower the server's memory usage. Additionally, loss of such messages is generally acceptable, since newer more recent position updates are more or less sent out continuously.

