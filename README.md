UDProtean - Haxe
[![pipeline status](https://gitlab.com/haath/udprotean/badges/master/pipeline.svg)](https://gitlab.com/haath/udprotean/pipelines/latest)
[![coverage report](https://gitlab.com/haath/udprotean/badges/master/coverage.svg)](https://gitlab.com/haath/udprotean/pipelines/latest)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://gitlab.com/haath/udprotean/blob/master/LICENSE)
====================


### Features

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

#### Server

```haxe
import udprotean.server.UDProteanClientBehavior;

class MyClientBehavior extends UDProteanClientBehavior
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
var server = new UDProteanServer("0.0.0.0", 9000, MyClientBehavior);

server.start();

while (running)
{
    // Synchronously read and process incoming datagrams.
    server.update();
}

server.stop();
```


#### Client

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

The `update()` method only returns when there is no data left to read on the socket.
For continuous communication, the `updateTimeout()` method may be preferable.

```haxe
// Process incoming data for 16ms.
client.updateTimeout(0.016);
```
