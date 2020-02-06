module ast;
import fpconv_ctfe;

import std.traits;
import std.conv;
import std.format;
import std.algorithm;
import std.string;
import std.exception;
import std.range;
import core.vararg;


// TODO check https://wiki.dlang.org/Defining_custom_print_format_specifiers for cooler toString methods

///Base class for all nodes
abstract class Node{
    abstract override string toString() const;
}

///Bace class for all arithmetic nodes
abstract class Arithmetic : Node{
    auto opBinary(string op)(const Arithmetic rhs) const
    {
        return new Expression(op, [this, rhs]);
    }
    auto opBinary(string op, N)(const N rhs) const if (isNumeric!N)
    {
        return new Expression(op, [this, new Constant!N(rhs)]);
    }
    auto opBinaryRight(string op, N)(const N lhs) const if (isNumeric!N)
    {
        return new Expression(op, [new Constant!N(lhs), this]);
    }
}

/// Symbol node
class Symbol(T) : Arithmetic  if (isNumeric!T)
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
    auto opAssign(T)(const T value) if (isNumeric!T)
    {
        auto assign = new Assignment(this, new Constant!T(value)); // TODO does this work without !T
        return assign;
    }
    auto opAssign(const Arithmetic value)
    {
        auto assign = new Assignment(this, value);
        return assign;
    }
    auto opOpAssign(string op, T)(const T value) if (isNumeric!T)
    {
        return this = opBinary!op(value);
    }
    auto opOpAssign(string op)(const Arithmetic value)
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
        static if(isFloatingPoint!T)
            return fpconv_dtoa(value);
        else
            return value.to!string;
    }
}

/// Field node
class Field(T) : Node
{
    string name;
    const size_t dim;
    const size_t[] size = [0,0,0];
    this(string n, const size_t d)
    {
        name = n;
        dim = d;
    }
    this(string n, const size_t d, const size_t[] s)
    {
        assert(d == s.length);
        name = n;
        dim = d;
        size = s;
    }
    override string toString() const
    {
        return format!"%s%s"(name, dim);
    }
    FieldAccess!T opIndex(int[] access...) const
    {
        return new FieldAccess!T(this, access);
    }
}

/// Field access node
class FieldAccess(T) : Symbol!T
{
    const Field!T field;
    const int[] access;
    this(const Field!T f, const int[] a)
    {
        field = f;
        access = a;
        super(field.name);
    }
    override string toString() const
    {
        return format!"%s%s"(field.name, access);
    }
}

/// Loop node
class Loop(T) : Node
{
    const Symbol!T iter;
    const Node block;
    const size_t start;
    const size_t end;
    const size_t step = 1;
    override string toString() const
    {
        return format!"for(%s %s = %s; %s < %s; %s=%s + %s)\n%s"(T, iter, start, iter, end, iter, iter, step, block);
    }
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