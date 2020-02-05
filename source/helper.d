module helper;
import std.traits; 
import std.algorithm;
import std.string;
import std.array;

import ast : Symbol, Field;


/// Symbol stub
Symbol!T symbol(T)(string s)
{
    return new Symbol!T(s);
}

/// Symbols factory
Symbol!T[] symbols(T)(string[] s)
{
    return s.map!(symbol!T).array;
}

/// Symbols factory
Symbol!T[] symbols(T)(string s)
{
    return s.split(",").map!strip.symbols!T;
}

/// Field stub
Field!T field(T)(string s, size_t dim, size_t[] size = [])
{
    if(size.length)
        return new Field!T(s, dim, size);
    else
        return new Field!T(s, dim);
}


Field!T[] fields(T)(string[] s, size_t dim, size_t[] size = [])
{
    return s.map!(a => field!T(a, dim, size)).array;
}


/// Fields factory
//Field!T[] fields(T)(string s, size_t dim, size_t[] size = [])
//{
//    return s.split(",").map!strip.array.fields!T(dim, size);
//}