package udprotean.shared;


/**
 * Configures the base socket type which will be used by `UdpSocketEx`.
 *
 * This is to avoid using an intermediate interface for custom socket types
 * for targets like Lua.
 */
typedef BaseSocketType =

#if lua
    udprotean.shared.platform.lua.LuaUdpSocket
#else
    sys.net.UdpSocket
#end

;
