module helper;
import std.traits; 
import std.algorithm;
import std.string;
import std.array;

import ast : Symbol;


/// Symbol factory
Symbol!T symbol(T)(string s)
{
    return new Symbol!T(s);
}

/// Symbols factory
Symbol!T[] symbols(T)(string[] s)
{
    return s.map!(symbol!T).array;
}

Symbol!T[] symbols(T)(string s)
{
    return s.split(",").map!strip.symbols!T;
}
