module ast;
import std.traits;
import std.conv;
import std.format;
import std.algorithm;
import std.string;

// TODO check https://wiki.dlang.org/Defining_custom_print_format_specifiers for cooler toString methods

///Base class for all nodes
class Node{
    abstract override string toString() const;
        // TODO implement opBinary
        // TODO auto morph numerics to constants
}

/// Symbol node
class Symbol(T) : Node  if (isNumeric!T)
{
    /// Symbol's name
    string name;
    /// Constructor
    this(string s)
    {
        name = s;
    }
    override string toString() const
    {
        return name;
    }
}

/// Constant node
class Constant(T) : Node
{
    /// Constant's value
    T value;
    /// Constructor
    this(T)(T v) if (isNumeric!T)
    {
        value = v;
    }
    override string toString() const
    {
        return format!"%s"(value);
    }
}

/// Field node
class Field(T) : Node
{

}

/// Loop node
class Loop : Node
{

}

/// Expressions
class Expression : Node
{
    /// Expression's string
    string expr;
    /// Expression's args
    Node[] args;
    /// Constructor
    this(string e, Node[] a)
    {
        expr = e;
        args = a;
    }
    override string toString() const 
    {
        return args.map!(to!string).join(" " ~ expr ~ " ").format!"(%s)";
    }
}

/// FunctionCall node
class FunctionCall : Node
{
    /// Function
    string func;
    /// Arguments
    Node[] args;
    /// Constructor
    this(string f, Node[] a)
    {
        func = f;
        args = a;
    }
    override string toString() const
    {
        return format!"%s(%(%s,%))"(func, args);
    }
}

/// Block node
class Block : Node
{
    /// Nodes in the block
    Node[] nodes;
    /// Constructor
    this(Node[] n)
    {
        nodes = n;
    }
    override string toString() const
    {
        return nodes.map!(a => a.to!string.wrap(120, "\t", "\t\t")).format!("{\n%-(%s%)}\n");
    }
}


/// Statement node
class Statement : Node
{
    /// Statement
    Node stat;
    /// Constructor
    this(Node s)
    {
        stat = s;
    }
    override string toString() const
    {
        return format!"%s;\n"(stat);
    }
}

/// Assignment node
class Assignment : Node
{
    /// Left-hand side
    Node lhs;
    /// Right-hand side
    Node rhs;
    /// Constructor
    this(Node l, Node r)
    {
        lhs = l;
        rhs = r;
    }
    override string toString() const
    {
        return format!"%s = %s;"(lhs, rhs);
    }
}