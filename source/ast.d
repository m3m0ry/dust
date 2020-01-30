module ast;
import std.traits;
import std.conv;
import std.format;
import std.algorithm;
import std.string;

// TODO check https://wiki.dlang.org/Defining_custom_print_format_specifiers for cooler toString methods

///Base class for all nodes
abstract class Node{
    abstract override string toString() const;
        // TODO implement opBinary
        // TODO auto morph numerics to constants
}

///Bace class for all arithmetic nodes
abstract class Arithmetic : Node{
    auto opBinary(string op)(const Arithmetic rhs) const
    {
        return new Expression(op, [this, rhs]);
    }
    auto opBinary(string op, N)(const N rhs) const if (isNumeric!N)
    {
        return new Expression(op, [this, Constant(rhs)]);
    }
    auto opBinaryRight(string op, N)(const N lhs) const if (isNumeric!N)
    {
        return new Expression(op, [lhs, this]);
    }
}



/// Symbol node
class Symbol(T) : Arithmetic  if (isNumeric!T)
{
    /// Symbol's name
    const string name;
    /// Constructor
    this(const string s)
    {
        name = s;
    }
    override string toString() const
    {
        return name;
    }
    auto opAssign(T)(T value) if (isNumeric!T)
    {
        auto assign = new Assignment(this, new Constant!T(value));
        return assign;
    }
    auto opAssign(const Arithmetic value)
    {
        auto assign = new Assignment(this, value);
        return assign;
    }
    auto opOpAssign(string op, T)(T value) if (isNumeric!T || T == Arithmetic)
    {
        return this = opBinary!op(value);
    }
}

/// Constant node
class Constant(T) : Arithmetic
{
    /// Constant's value
    const T value;
    /// Constructor
    this(T)(const T v) if (isNumeric!T)
    {
        value = v;
    }
    override string toString() const
    {
        return format!"%s"(value);
    }
}

/// Field node
class Field(T) : Arithmetic
{

}

/// Loop node
class Loop : Node
{

}

/// Expressions
class Expression : Arithmetic
{
    /// Expression's string
    const string expr;
    /// Expression's args
    const Node[] args;
    /// Constructor
    this(const string e, const Node[] a)
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
class FunctionCall : Arithmetic
{
    /// Function
    const string func;
    /// Arguments
    const Node[] args;
    /// Constructor
    this(const string f, const Node[] a)
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
    const Node[] nodes;
    /// Constructor
    this(const Node[] n)
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
    const Node stat;
    /// Constructor
    this(const Node s)
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
    const Node lhs;
    /// Right-hand side
    const Node rhs;
    /// Constructor
    this(const Node l, const Node r)
    {
        lhs = l;
        rhs = r;
    }
    override string toString() const
    {
        return format!"%s = %s;"(lhs, rhs);
    }
}