# RageMode lua

Simple implementation of RageMode (basically One In The Chamber with exploding arrows) using Lua.
Goal was to make a PoC showcasing the simplicity of using Lua to write plugins instead of having to step
into the heavyweight Java/Kotlin ecosystem.

### Requirements

For this to work we need a specific plugin called [LuaLink](https://github.com/LuaLink/LuaLink). With LuaLink we can use Paper and Spigot APIs like in Java. Under the hood it uses the luaj interpreter to run user supplied scripts. Also provides useful utility.

It is important to note that we have to add `JAVA_TOOL_OPTIONS="-add-opens=java.base/java.util=ALL-UNNAMED"` when running the server, otherwise some methods on classes living in `java.util` could not be called. This is due to reflection trickery luaj does I suppose.

### Conclusion

Everything works as expected (except the strange reflection issues I encountered) and requires a lot less code to
achieve the same thing in Java. 

But there are a few things that could be improved: 

* There has to be auto-completion when interacting with Minecraft APIs. Current worklfow had me browsing the Javadocs to get information about functions, params etc. (big PITA). One possible solution for this could be generating definitions for a [Lua LSP](https://github.com/luals/lua-language-server) based on Spigot Javadocs.

* It could be useful investigating if LuaJIT can be used instead of luaj. LuaJIT provides a more performant interpreter and is actively maintained unlike luaj which seems abandoned. See https://github.com/gudzpoz/luajava

### Running

```
./run.sh
```